#!/bin/bash

# RKE2 uses its own containerd socket
CTR_SOCK="/run/k3s/containerd/containerd.sock"

# Get a list of all images from containerd (k8s.io namespace)
# Using awk to get just the image name column (without -q to see full names)
images=$(ctr -a $CTR_SOCK -n k8s.io images list | awk 'NR>1 {print $1}')

# Check if there are any images
if [ -z "$images" ]; then
    echo "No images found."
    exit 1
fi

# Create a directory to save images
mkdir -p saved_images

# Loop through each image and save it
for image in $images; do
    # Generate a filename based on the image name (replace / and : with _)
    filename="saved_images/$(echo $image | tr '/:' '__').tar"
    
    # Export the image using ctr
    echo "Exporting $image..."
    ctr -a $CTR_SOCK -n k8s.io images export "$filename" "$image"
    
    if [ $? -eq 0 ]; then
        echo "✓ Saved $image to $filename"
    else
        echo "✗ Failed to save $image"
    fi
done

echo "All images exported to saved_images/"
