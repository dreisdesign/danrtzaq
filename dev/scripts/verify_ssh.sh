#!/bin/bash

# This script verifies if SSH key authentication is properly configured
# It attempts to connect to the server and read a test file using SSH key authentication
# If successful, it confirms the SSH key setup is working
# If it fails, it suggests running the setup script again
#
# Installation:
# 1. Save this script in your local machine
# 2. Change to the correct directory by running: cd /Users/danielreis/web/danrtzaq/dev/scripts
# 3. Make it executable by running: chmod +x verify_ssh.sh
#
# Usage:
# Option 1: Run directly if in the script's directory
#   ./verify_ssh.sh
#
# Option 2: Run with bash from any location
#   bash /path/to/verify_ssh.sh
#
# The script will:
# 1. Try to connect to danrtzaq@danreisdesign.com on port 21098
# 2. Attempt to read a test file from the home directory
# 3. Display success/failure message based on the result
# 4. Automatically accepts new host keys to avoid manual confirmation

# Simple script to verify SSH key authentication is working
echo "Verifying SSH key authentication to danrtzaq@danreisdesign.com:21098..."

# Try to get the content of the test file we created
if ssh -o StrictHostKeyChecking=accept-new -p 21098 danrtzaq@danreisdesign.com "cat ~/ssh_test_success.txt" 2>/dev/null; then
  echo -e "\n✅ Success! Your SSH key is correctly set up and working."
  echo "You can now use SSH without password authentication."
else
  echo -e "\n❌ SSH key authentication failed."
  echo "Please check that you've correctly set up your key on the server."
  echo "You can run './setup_ssh_key.sh' again to see the instructions."
fi
