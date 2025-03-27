#!/bin/bash

# Script to update cache busters in HTML files
# Usage: ./update-cache-busters.sh /path/to/directory [timestamp]

if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/directory [timestamp]"
    exit 1
fi

TARGET_DIR="$1"

# Use provided timestamp or generate a new one
if [ -n "$2" ]; then
    TIMESTAMP="$2"
    echo "Using provided timestamp: $TIMESTAMP"
else
    TIMESTAMP=$(date +"%Y%m%d-%H%M")
    echo "Generated new timestamp: $TIMESTAMP"
fi

UPDATED_FILES=0
CURRENT_DATE=$(date +'%A, %B %d, %Y at %I:%M%p')

echo "Updating cache busters and timestamps in $TARGET_DIR..."

# Update timestamp comment in HTML files (first match only)
find "$TARGET_DIR" -name "*.html" -exec sed -i '' "s/<!-- Last updated:.*-->/<!-- Last updated: $CURRENT_DATE -->/" {} \;

# Update cache buster query parameters in HTML files
for html_file in $(find "$TARGET_DIR" -name "*.html"); do
    # Update CSS files cache busters
    if grep -q "\.css?v=" "$html_file"; then
        sed -i '' "s/\.css?v=[0-9]\{8\}-[0-9]\{4\}/\.css?v=$TIMESTAMP/g" "$html_file"
        UPDATED_FILES=$((UPDATED_FILES+1))
    fi
    
    # Update JS files cache busters
    if grep -q "\.js?v=" "$html_file"; then
        sed -i '' "s/\.js?v=[0-9]\{8\}-[0-9]\{4\}/\.js?v=$TIMESTAMP/g" "$html_file"
        UPDATED_FILES=$((UPDATED_FILES+1))
    fi
    
    # Also update any files with older timestamp formats (YYYYMMDD)
    sed -i '' "s/\.css?v=[0-9]\{8\}/\.css?v=$TIMESTAMP/g" "$html_file"
    sed -i '' "s/\.js?v=[0-9]\{8\}/\.js?v=$TIMESTAMP/g" "$html_file"
    
    # Update favicon and image cache busters if they exist
    sed -i '' "s/favicon\.ico?v=[0-9]\{8\}/favicon.ico?v=${TIMESTAMP%%-*}/g" "$html_file"
    sed -i '' "s/\.png?v=[0-9]\{8\}-[0-9]\{4\}/\.png?v=$TIMESTAMP/g" "$html_file"
    sed -i '' "s/\.jpg?v=[0-9]\{8\}-[0-9]\{4\}/\.jpg?v=$TIMESTAMP/g" "$html_file"
    sed -i '' "s/\.webp?v=[0-9]\{8\}-[0-9]\{4\}/\.webp?v=$TIMESTAMP/g" "$html_file"
    
    # Ensure all cache busters are consistent
    if [ -n "$(grep -l "$TIMESTAMP" "$html_file")" ]; then
        echo "  ✓ $(basename "$html_file")"
    fi
done

echo "Done. Updated cache busters in $UPDATED_FILES files with timestamp $TIMESTAMP."
echo "Current date in HTML files: $CURRENT_DATE"
