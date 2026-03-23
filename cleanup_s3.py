#!/usr/bin/env python3
import boto3
import sys
from botocore.exceptions import ClientError

def empty_bucket(bucket_name, profile_name='cloudreality'):
    """Delete all objects from an S3 bucket using specified profile"""
    
    # Create session with specific profile
    session = boto3.Session(profile_name=profile_name)
    s3 = session.client('s3')
    
    try:
        # Check if bucket exists
        s3.head_bucket(Bucket=bucket_name)
        
        # List objects using paginator
        paginator = s3.get_paginator('list_objects_v2')
        
        deleted_count = 0
        
        for page in paginator.paginate(Bucket=bucket_name):
            if 'Contents' in page:
                objects = [{'Key': obj['Key']} for obj in page['Contents']]
                
                # Delete in batches of 1000
                for i in range(0, len(objects), 1000):
                    batch = objects[i:i+1000]
                    s3.delete_objects(
                        Bucket=bucket_name,
                        Delete={'Objects': batch}
                    )
                    deleted_count += len(batch)
                    print(f"   Deleted {deleted_count} objects...", end='\r')
        
        print(f"\n✅ Successfully deleted {deleted_count} objects from {bucket_name}")
        return True
        
    except ClientError as e:
        if e.response['Error']['Code'] == 'NoSuchBucket':
            print(f"📦 Bucket {bucket_name} does not exist")
            return True
        else:
            print(f"❌ Error emptying bucket {bucket_name}: {str(e)}")
            return False

if __name__ == "__main__":
    buckets = [
        "hsbc-gamma-dev-processed-images",
        "hsbc-gamma-dev-raw-images"
    ]
    
    profile = "cloudreality"
    
    print(f"🔑 Using AWS profile: {profile}")
    print(f"🧹 Cleaning up buckets...\n")
    
    success = True
    for bucket in buckets:
        if not empty_bucket(bucket, profile):
            success = False
            break
    
    if success:
        print("\n✨ All buckets have been emptied!")
        print("\nYou can now run: terraform destroy -auto-approve")
    else:
        print("\n❌ Cleanup failed. Check the errors above.")
        sys.exit(1)