#!/bin/bash

# Script to generate WebP posters from the first frame of videos
# Usage: ./dev/scripts/poster-generator.sh

# Updated to scan all portfolio videos
VIDEO_DIR="/Users/danielreis/web/danrtzaq/public_html/assets/videos/portfolio/"

# Ensure the script exits if any command fails
set -e

echo "Starting WebP poster generation for all videos in portfolio directory..."
echo "Base directory: $VIDEO_DIR"

# Function to create WebP poster from video
create_poster() {
    local video="$1"
    local basename=$(basename "$video" .mp4)
    local poster_path="${video%.*}.webp"
    
    echo "Creating poster for $video..."
    
    # Extract first frame and convert to WebP with 85% quality
    ffmpeg -i "$video" -vframes 1 -q:v 1 -compression_level 6 -quality 85 -y "$poster_path"
    
    echo "✓ Created poster: $poster_path"
}

# Count total videos for progress tracking
total_videos=$(find "$VIDEO_DIR" -type f -name "*.mp4" | wc -l)
echo "Found $total_videos videos to process"

# Find all MP4 files in the video directory and subdirectories
count=0
find "$VIDEO_DIR" -type f -name "*.mp4" | while read video; do
    count=$((count + 1))
    echo "[$count/$total_videos] Processing..."
    create_poster "$video"
done

echo "All posters generated successfully!"
echo "Processed $total_videos videos across the portfolio directory."
