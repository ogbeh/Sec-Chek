#!/bin/bash

# Installation script for sec-chek
# This script will download and install sec-chek to the system

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd "$TEMP_DIR"

# Download sec-chek script
echo -e "${BLUE}Downloading sec-chek...${NC}"
wget -q https://raw.githubusercontent.com/yourusername/sec-chek/main/sec-chek.sh -O sec-chek

# Make the script executable
chmod +x sec-chek

# Move to system directory
echo -e "${BLUE}Installing sec-chek to /usr/local/bin...${NC}"
mv sec-chek /usr/local/bin/

# Clean up
cd - > /dev/null
rm -rf "$TEMP_DIR"

echo -e "${GREEN}sec-chek has been installed successfully!${NC}"
echo -e "${YELLOW}You can now run 'sec-chek' from anywhere in your system${NC}" 