#!/bin/bash

# RKE2 uses its own containerd socket
CTR_SOCK="/run/k3s/containerd/containerd.sock"

# Directory where images are saved
IMAGE_DIR="saved_images"

# Check if the directory exists
if [ ! -d "$IMAGE_DIR" ]; then
    echo "Error: Directory $IMAGE_DIR not found."
    exit 1
fi

# Find all tar files in the saved_images directory
tar_files=$(find "$IMAGE_DIR" -name "*.tar" -type f)

# Check if there are any tar files
if [ -z "$tar_files" ]; then
    echo "No image tar files found in $IMAGE_DIR"
    exit 1
fi

echo "Loading images from $IMAGE_DIR..."
echo ""

# Counter for statistics
total=0
success=0
failed=0

# Loop through each tar file and import it
for tarfile in $tar_files; do
    total=$((total + 1))
    echo "[$total] Importing $(basename $tarfile)..."
    
    # Import the image using ctr
    if ctr -a $CTR_SOCK -n k8s.io images import "$tarfile"; then
        echo "✓ Successfully loaded $(basename $tarfile)"
        success=$((success + 1))
    else
        echo "✗ Failed to load $(basename $tarfile)"
        failed=$((failed + 1))
    fi
    echo ""
done

# Print summary
echo "================================"
echo "Import Summary:"
echo "  Total:   $total"
echo "  Success: $success"
echo "  Failed:  $failed"
echo "================================"

# List loaded images
echo ""
echo "Current images in containerd:"
ctr -a $CTR_SOCK -n k8s.io images list
