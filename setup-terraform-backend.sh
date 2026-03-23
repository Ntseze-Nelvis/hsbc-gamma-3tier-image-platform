#!/bin/bash
# setup-terraform-backend.sh - Script to create Terraform backend infrastructure

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚀 Setting up Terraform Backend Infrastructure"
echo "==============================================="

# Check if AWS profile exists
if ! aws sts get-caller-identity --profile cloudreality &>/dev/null; then
    echo -e "${RED}❌ AWS profile 'cloudreality' not configured or invalid${NC}"
    echo "Please configure it first with: aws configure --profile cloudreality"
    exit 1
fi

echo -e "${GREEN}✅ AWS profile verified${NC}"

# Variables
BUCKET_NAME="hsbc-gamma-dev-terraform-state"
REGION="eu-north-1"
TABLE_NAME="terraform-locks"

echo ""
echo "📦 Creating S3 bucket: $BUCKET_NAME"

# Create S3 bucket
if aws s3 ls "s3://$BUCKET_NAME" --profile cloudreality 2>/dev/null; then
    echo -e "${YELLOW}⚠️  Bucket already exists, skipping creation${NC}"
else
    aws s3 mb "s3://$BUCKET_NAME" --region $REGION --profile cloudreality
    echo -e "${GREEN}✅ Bucket created${NC}"
fi

# Enable versioning
echo "📝 Enabling versioning..."
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled \
    --profile cloudreality
echo -e "${GREEN}✅ Versioning enabled${NC}"

# Enable encryption
echo "🔐 Enabling encryption..."
aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }' \
    --profile cloudreality
echo -e "${GREEN}✅ Encryption enabled${NC}"

# Block public access
echo "🚫 Blocking public access..."
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration '{
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }' \
    --profile cloudreality
echo -e "${GREEN}✅ Public access blocked${NC}"

# Create DynamoDB table for state locking
echo "🗄️  Creating DynamoDB table: $TABLE_NAME"

if aws dynamodb describe-table --table-name $TABLE_NAME --profile cloudreality &>/dev/null; then
    echo -e "${YELLOW}⚠️  Table already exists, skipping creation${NC}"
else
    aws dynamodb create-table \
        --table-name $TABLE_NAME \
        --attribute-definitions AttributeName=LockID,AttributeType=S \
        --key-schema AttributeName=LockID,KeyType=HASH \
        --billing-mode PAY_PER_REQUEST \
        --region $REGION \
        --profile cloudreality
    
    # Wait for table to be active
    echo "⏳ Waiting for table to be active..."
    aws dynamodb wait table-exists \
        --table-name $TABLE_NAME \
        --region $REGION \
        --profile cloudreality
    echo -e "${GREEN}✅ Table created and active${NC}"
fi

echo ""
echo -e "${GREEN}🎉 Terraform backend setup complete!${NC}"
echo ""
echo "📋 Summary:"
echo "   S3 Bucket: $BUCKET_NAME"
echo "   DynamoDB Table: $TABLE_NAME"
echo "   Region: $REGION"
echo ""
echo "Now update your providers.tf with these values:"
echo "   bucket = \"$BUCKET_NAME\""
echo "   key    = \"3tier-image-platform/terraform.tfstate\""
echo "   region = \"$REGION\""
echo "   dynamodb_table = \"$TABLE_NAME\""