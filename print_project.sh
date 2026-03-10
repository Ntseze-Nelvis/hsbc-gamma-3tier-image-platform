#!/bin/bash

# show-all-files.sh

outputFile="complete-configuration.txt"
rootDir=$(pwd)

# Clear the output file if it exists
if [ -f "$outputFile" ]; then
    rm "$outputFile"
fi

# Function to write content to file
write_file_content() {
    local filePath=$1
    
    echo "" >> "$outputFile"
    printf '%0.s=' {1..80} >> "$outputFile"
    echo "" >> "$outputFile"
    echo "FILE: $filePath" >> "$outputFile"
    printf '%0.s=' {1..80} >> "$outputFile"
    echo "" >> "$outputFile"
    echo "" >> "$outputFile"
    
    cat "$filePath" >> "$outputFile"
    echo "" >> "$outputFile"
    echo "" >> "$outputFile"
}

# Write header
echo "COMPLETE TERRAFORM CONFIGURATION" >> "$outputFile"
echo "Generated on: $(date)" >> "$outputFile"
printf '%0.s=' {1..80} >> "$outputFile"
echo "" >> "$outputFile"
echo "" >> "$outputFile"

# Get all .tf files in root directory
echo "ROOT MODULE FILES" >> "$outputFile"
printf '%0.s-' {1..40} >> "$outputFile"
echo "" >> "$outputFile"

for file in $(ls *.tf 2>/dev/null); do
    if [ -f "$file" ]; then
        write_file_content "$rootDir/$file"
    fi
done

# Get terraform.tfvars if it exists
if [ -f "terraform.tfvars" ]; then
    write_file_content "$rootDir/terraform.tfvars"
fi

# Get all module files
modules=(
    "vpc"
    "security"
    "s3"
    "alb"
    "web"
    "app"
    "monitoring"
)

for module in "${modules[@]}"; do
    modulePath="$rootDir/modules/$module"
    
    if [ -d "$modulePath" ]; then
        echo "" >> "$outputFile"
        printf '%0.s=' {1..80} >> "$outputFile"
        echo "" >> "$outputFile"
        echo "MODULE: $module" >> "$outputFile"
        printf '%0.s=' {1..80} >> "$outputFile"
        echo "" >> "$outputFile"
        
        # Find all .tf files in the module directory
        for file in "$modulePath"/*.tf; do
            if [ -f "$file" ]; then
                write_file_content "$file"
            fi
        done
        
        # Include user_data.sh if it exists
        userDataPath="$modulePath/user_data.sh"
        if [ -f "$userDataPath" ]; then
            echo "" >> "$outputFile"
            printf '%0.s-' {1..40} >> "$outputFile"
            echo "" >> "$outputFile"
            echo "FILE: $userDataPath" >> "$outputFile"
            printf '%0.s-' {1..40} >> "$outputFile"
            echo "" >> "$outputFile"
            echo "" >> "$outputFile"
            cat "$userDataPath" >> "$outputFile"
            echo "" >> "$outputFile"
            echo "" >> "$outputFile"
        fi
    fi
done

echo -e "\033[0;32mConfiguration exported to: $outputFile\033[0m"
echo -e "\033[0;33mPlease share the contents of this file\033[0m"