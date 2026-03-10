#!/bin/bash
set -x
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting app tier user data script at $(date)"

# Update and install dependencies
yum update -y
yum install -y python3 python3-pip

# Install system dependencies for Pillow
yum install -y libjpeg-turbo-devel zlib-devel libtiff-devel freetype-devel lcms2-devel

# Install Python packages
pip3 install flask boto3 Pillow==9.5.0  # Use stable version

# Create the Flask app with proper image handling
cat << 'EOF' > /home/ec2-user/app.py
from flask import Flask, request, jsonify
from PIL import Image
import boto3
import os
import uuid
import logging
import socket
import time
from botocore.exceptions import ClientError

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

app = Flask(__name__)

# Get bucket names from environment variables
RAW_BUCKET = os.environ.get('RAW_BUCKET', 'hsbc-gamma-dev-raw-images')
PROCESSED_BUCKET = os.environ.get('PROCESSED_BUCKET', 'hsbc-gamma-dev-processed-images')

# Initialize S3 client
try:
    s3 = boto3.client('s3', region_name='eu-north-1')
    logger.info("S3 client initialized successfully")
except Exception as e:
    logger.error(f"Failed to initialize S3 client: {str(e)}")
    s3 = None

def process_image_sizes(img, base_filename):
    """Process image into multiple sizes and return list of generated files"""
    generated_files = []
    
    # Define sizes
    sizes = {
        'thumbnail': (150, 150),
        'small': (300, 300),
        'medium': (800, 800),
        'large': (1200, 1200)
    }
    
    # Convert to RGB if necessary (for JPEG compatibility)
    if img.mode in ('RGBA', 'LA', 'P'):
        # Create a white background for transparency
        rgb_img = Image.new('RGB', img.size, (255, 255, 255))
        if img.mode == 'P':
            img = img.convert('RGBA')
        rgb_img.paste(img, mask=img.split()[-1] if img.mode == 'RGBA' else None)
        img = rgb_img
    
    for size_name, dimensions in sizes.items():
        try:
            logger.info(f'Creating {size_name} size: {dimensions}')
            
            # Create a copy and resize
            img_copy = img.copy()
            img_copy.thumbnail(dimensions, Image.Resampling.LANCZOS)
            
            # Save to temp file
            temp_filename = f'/tmp/{size_name}-{base_filename}'
            
            # Determine format from original or default to JPEG
            if base_filename.lower().endswith('.png'):
                img_copy.save(temp_filename, 'PNG')
                s3_key = f'{size_name}-{base_filename.replace(".jpg", ".png")}'
            else:
                img_copy.save(temp_filename, 'JPEG', quality=85, optimize=True)
                s3_key = f'{size_name}-{base_filename}'
            
            generated_files.append({
                'path': temp_filename,
                's3_key': s3_key,
                'size_name': size_name
            })
            logger.info(f'Saved {size_name} to {temp_filename}')
            
        except Exception as e:
            logger.error(f'Failed to process {size_name}: {str(e)}')
            continue
    
    return generated_files

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint for load balancer"""
    health_status = {
        'status': 'healthy',
        'hostname': socket.gethostname(),
        'private_ip': socket.gethostbyname(socket.gethostname()),
        'timestamp': time.time(),
        's3_status': 'connected' if s3 else 'disconnected'
    }
    return jsonify(health_status), 200

@app.route('/', methods=['GET'])
def root():
    return jsonify({
        'service': 'app-tier',
        'hostname': socket.gethostname(),
        'private_ip': socket.gethostbyname(socket.gethostname()),
        'endpoints': {
            '/': 'GET - This info',
            '/health': 'GET - Health check',
            '/upload': 'POST - Upload image for processing'
        }
    }), 200

@app.route('/upload', methods=['POST'])
def upload():
    try:
        logger.info('Received upload request')
        
        if not s3:
            return jsonify({'error': 'S3 client not initialized'}), 500
        
        if 'image' not in request.files:
            logger.error('No image file in request')
            return jsonify({'error': 'No image file provided'}), 400
        
        file = request.files['image']
        if file.filename == '':
            logger.error('Empty filename')
            return jsonify({'error': 'No file selected'}), 400
        
        # Generate unique filename
        original_filename = file.filename
        file_ext = os.path.splitext(original_filename)[1].lower()
        base_filename = f"{uuid.uuid4()}{file_ext}"
        logger.info(f'Processing file: {base_filename} (original: {original_filename})')
        
        # Save temporarily
        temp_path = f'/tmp/{base_filename}'
        file.save(temp_path)
        logger.info(f'Saved to {temp_path}')
        
        # Verify file was saved and has content
        if not os.path.exists(temp_path) or os.path.getsize(temp_path) == 0:
            logger.error('File not saved properly or empty')
            return jsonify({'error': 'Failed to save file'}), 500
        
        # Upload original to raw bucket
        try:
            s3.upload_file(temp_path, RAW_BUCKET, base_filename)
            logger.info(f'Uploaded original to raw bucket: {base_filename}')
        except ClientError as e:
            logger.error(f'Failed to upload to raw bucket: {str(e)}')
            return jsonify({'error': f'Failed to upload to raw bucket: {str(e)}'}), 500
        
        # Open and process image
        try:
            img = Image.open(temp_path)
            logger.info(f'Image opened: mode={img.mode}, format={img.format}, size={img.size}')
            
            # Process image into multiple sizes
            processed_files = process_image_sizes(img, base_filename)
            
            if not processed_files:
                logger.error('No images were processed successfully')
                return jsonify({'error': 'Image processing failed'}), 500
            
            # Upload processed files
            uploaded_sizes = []
            for file_info in processed_files:
                try:
                    s3.upload_file(file_info['path'], PROCESSED_BUCKET, file_info['s3_key'])
                    logger.info(f'Uploaded {file_info["size_name"]} to processed bucket: {file_info["s3_key"]}')
                    uploaded_sizes.append(file_info['size_name'])
                    
                    # Clean up temp file
                    os.remove(file_info['path'])
                except ClientError as e:
                    logger.error(f'Failed to upload {file_info["size_name"]}: {str(e)}')
            
            # Clean up original temp file
            os.remove(temp_path)
            logger.info('Processing complete')
            
            return jsonify({
                'message': 'Image processed successfully',
                'original': base_filename,
                'sizes': uploaded_sizes,
                'raw_bucket': RAW_BUCKET,
                'processed_bucket': PROCESSED_BUCKET
            }), 200
            
        except Exception as e:
            logger.error(f'Failed to process image: {str(e)}')
            return jsonify({'error': f'Failed to process image: {str(e)}'}), 500
        
    except Exception as e:
        logger.error(f'Error processing upload: {str(e)}')
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    logger.info(f'Starting Flask app on port 5000')
    logger.info(f'Raw bucket: {RAW_BUCKET}')
    logger.info(f'Processed bucket: {PROCESSED_BUCKET}')
    app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
EOF

# Set permissions
chown ec2-user:ec2-user /home/ec2-user/app.py
chmod 755 /home/ec2-user/app.py

# Set environment variables
cat << EOF >> /etc/environment
RAW_BUCKET=hsbc-gamma-dev-raw-images
PROCESSED_BUCKET=hsbc-gamma-dev-processed-images
EOF

export RAW_BUCKET=hsbc-gamma-dev-raw-images
export PROCESSED_BUCKET=hsbc-gamma-dev-processed-images

# Kill any existing Flask processes
pkill -f "python3 /home/ec2-user/app.py" || true

# Start the Flask app
cd /home/ec2-user
nohup python3 /home/ec2-user/app.py > /home/ec2-user/app.log 2>&1 &

# Wait for app to start
sleep 5

# Check if app is running
if pgrep -f "python3 /home/ec2-user/app.py" > /dev/null; then
    echo "Flask app started successfully"
    echo "App logs:"
    tail -n 20 /home/ec2-user/app.log
else
    echo "Failed to start Flask app"
    echo "Last 50 lines of app.log:"
    tail -n 50 /home/ec2-user/app.log
fi

echo "App tier user data script completed at $(date)"