#!/bin/bash

# Batch script to fix formatting issues across the entire codebase
# This script runs all the fix and format scripts in the correct order

# Exit on error
set -e

# Define colors for better readability
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Base directory
BASE_DIR="/Users/danielreis/web/danrtzaq"
PUBLIC_HTML_DIR="$BASE_DIR/public_html"
POSTS_DIR="$BASE_DIR/postsforpause.com"
SCRIPTS_DIR="$BASE_DIR/dev/scripts"

# Ensure scripts are executable
chmod +x "$SCRIPTS_DIR/fix-html-issues.sh" 
chmod +x "$SCRIPTS_DIR/fix-platform-asset-flexibility.sh"
chmod +x "$SCRIPTS_DIR/format-html.sh"
chmod +x "$SCRIPTS_DIR/format-files.sh"

echo -e "${BLUE}===== Comprehensive HTML and Code Fixing =====${NC}"

# Step 1: Fix specific known issues in problem files
echo -e "\n${YELLOW}Step 1: Fixing specific issues in platform-asset-flexibility...${NC}"
"$SCRIPTS_DIR/fix-platform-asset-flexibility.sh"

# Step 2: Fix common HTML issues in all files
echo -e "\n${YELLOW}Step 2: Fixing common HTML issues in all files...${NC}"
"$SCRIPTS_DIR/fix-html-issues.sh" "$PUBLIC_HTML_DIR"
"$SCRIPTS_DIR/fix-html-issues.sh" "$POSTS_DIR"

# Step 3: Fix indentation issues
echo -e "\n${YELLOW}Step 3: Standardizing HTML indentation...${NC}"
"$SCRIPTS_DIR/format-html.sh" "$PUBLIC_HTML_DIR"
"$SCRIPTS_DIR/format-html.sh" "$POSTS_DIR"

# Step 4: Apply prettier formatting to all files
echo -e "\n${YELLOW}Step 4: Applying prettier formatting...${NC}"
"$SCRIPTS_DIR/format-files.sh"

# Step 5: Rebuild portfolio data
echo -e "\n${YELLOW}Step 5: Rebuilding portfolio data...${NC}"
cd "$BASE_DIR"
npm run build:portfolio

echo -e "\n${GREEN}✅ All formatting and fixes complete!${NC}"
echo -e "${BLUE}You can now run a dry-run deployment to verify everything:${NC}"
echo "npm run deploy -- --dry-run"
