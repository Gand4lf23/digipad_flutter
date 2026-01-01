#!/bin/bash

# Define the directory
TARGET_DIR="/Volumes/KINGSTON/projects/digipad3/digipad_flutter/assets/images"

# Check if directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "Directory not found: $TARGET_DIR"
    exit 1
fi

echo "Scanning for PNGs in: $TARGET_DIR (and subfolders)"

# Find all PNG files recursively and process them one by one
# -print0 and -d '' handle filenames with spaces correctly
find "$TARGET_DIR" -type f -name "*.jpg" -print0 | while IFS= read -r -d '' file; do

    # Get filename without extension
    # "${file%.*}" removes the last extension (e.g., .png)
    filename_no_ext="${file%.*}"
    
    echo "Converting: $file"

    # Convert to WebP
    # -q 80 sets quality to 80%
    # -quiet suppresses huge output logs
    cwebp -q 80 "$file" -o "$filename_no_ext.webp" -quiet

    # Check if conversion was successful
    if [ $? -eq 0 ]; then
        # Delete the original PNG
        rm "$file"
        echo "✅ Converted & Deleted: $file"
    else
        echo "❌ Error converting: $file"
    fi

done

echo "🎉 All done!"