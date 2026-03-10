#!/bin/bash
yum update -y
yum install -y httpd

# Create a proper web UI
cat << 'EOF' > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>HSBC-gamma-dev Image Platform</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #db0b5f; } /* HSBC red */
        .upload-area { border: 2px dashed #ccc; padding: 30px; text-align: center; margin: 20px 0; }
        .upload-area:hover { border-color: #db0b5f; }
        .btn { background: #db0b5f; color: white; padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; }
        .btn:hover { background: #b5094c; }
        .images { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; margin-top: 30px; }
        .image-card { border: 1px solid #ddd; padding: 10px; border-radius: 5px; }
        .image-card img { max-width: 100%; height: auto; }
        .status { padding: 10px; margin: 10px 0; border-radius: 5px; display: none; }
        .success { background: #d4edda; color: #155724; display: block; }
        .error { background: #f8d7da; color: #721c24; display: block; }
        .info { background: #d1ecf1; color: #0c5460; display: block; }
    </style>
</head>
<body>
    <div class="container">
        <h1>HSBC-gamma-dev Image Platform</h1>
        <p>Host: <span id="hostname">$(hostname)</span></p>
        
        <div id="status" class="status"></div>
        
        <div class="upload-area" id="dropArea">
            <h3>Drag & Drop or Click to Upload</h3>
            <p>Supported: JPG, PNG, GIF</p>
            <input type="file" id="fileInput" accept="image/*" style="display: none;">
            <button class="btn" onclick="document.getElementById('fileInput').click()">Select Image</button>
        </div>

        <h2>Processed Images</h2>
        <div class="images" id="imageGallery">
            <p>No images processed yet. Upload one above!</p>
        </div>
    </div>

    <script>
        const API_URL = '';  // Same host, different path
        const dropArea = document.getElementById('dropArea');
        const fileInput = document.getElementById('fileInput');
        const statusDiv = document.getElementById('status');
        const gallery = document.getElementById('imageGallery');

        // Handle drag & drop
        ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
            dropArea.addEventListener(eventName, preventDefaults, false);
        });

        function preventDefaults(e) {
            e.preventDefault();
            e.stopPropagation();
        }

        dropArea.addEventListener('drop', handleDrop, false);
        fileInput.addEventListener('change', handleFiles, false);

        function handleDrop(e) {
            const files = e.dataTransfer.files;
            handleFiles({ target: { files: files } });
        }

        function handleFiles(e) {
            const file = e.target.files[0];
            if (!file) return;

            showStatus('Uploading...', 'info');
            
            const formData = new FormData();
            formData.append('image', file);

            fetch('/upload', {
                method: 'POST',
                body: formData
            })
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    showStatus('Error: ' + data.error, 'error');
                } else {
                    showStatus('Success! Image processed.', 'success');
                    loadProcessedImages();
                }
            })
            .catch(error => {
                showStatus('Error: ' + error, 'error');
            });
        }

        function showStatus(message, type) {
            statusDiv.className = 'status ' + type;
            statusDiv.textContent = message;
        }

        function loadProcessedImages() {
            // In a real implementation, you'd have an API endpoint to list images
            // For now, we'll just show a placeholder
            gallery.innerHTML = '<p>Images are being processed and stored in S3. Check the processed bucket!</p>';
        }
    </script>
</body>
</html>
EOF

# Create a PHP proxy to handle API calls (optional, but simplifies things)
cat << 'EOF' > /var/www/html/upload-proxy.php
<?php
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_FILES['image'])) {
    $url = 'http://internal-hsbc-gamma-dev-alb-1872922200.eu-north-1.elb.amazonaws.com/upload';
    
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, $url);
    curl_setopt($ch, CURLOPT_POST, true);
    curl_setopt($ch, CURLOPT_POSTFIELDS, array('image' => new CURLFile($_FILES['image']['tmp_name'])));
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_HEADER, false);
    
    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    
    header('Content-Type: application/json');
    http_response_code($httpCode);
    echo $response;
    exit;
}

// List processed images (simplified - you'd need to list from S3)
if ($_SERVER['REQUEST_METHOD'] === 'GET' && isset($_GET['list'])) {
    // This would list from S3 - implement if needed
    echo json_encode(['images' => []]);
    exit;
}
?>
EOF

# Configure Apache to handle the proxy
cat << 'EOF' > /etc/httpd/conf.d/proxy.conf
<IfModule mod_proxy.c>
    ProxyRequests Off
    ProxyPreserveHost On
    
    <Location /upload>
        ProxyPass http://internal-hsbc-gamma-dev-alb-1872922200.eu-north-1.elb.amazonaws.com/upload
        ProxyPassReverse http://internal-hsbc-gamma-dev-alb-1872922200.eu-north-1.elb.amazonaws.com/upload
    </Location>
</IfModule>
EOF

# Enable proxy modules
sed -i 's/#LoadModule proxy_module/LoadModule proxy_module/' /etc/httpd/conf/httpd.conf
sed -i 's/#LoadModule proxy_http_module/LoadModule proxy_http_module/' /etc/httpd/conf/httpd.conf

# Set proper permissions
chown apache:apache /var/www/html/index.html
chown apache:apache /var/www/html/upload-proxy.php

# Restart Apache
systemctl restart httpd