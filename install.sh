#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Please run as root (use sudo)${NC}"
    exit 1
fi

# Create temporary directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download the script
echo -e "${YELLOW}Downloading Port Manager...${NC}"
curl -s https://raw.githubusercontent.com/ogbeh/sec-chek/main/port-manager.sh -o port-manager.sh

# Check if download was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to download Port Manager${NC}"
    rm -rf "$TMP_DIR"
    exit 1
fi

# Make the script executable
chmod +x port-manager.sh

# Move to system directory
mv port-manager.sh /usr/local/bin/port-manager

# Clean up
rm -rf "$TMP_DIR"

echo -e "${GREEN}Port Manager installed successfully!${NC}"
echo -e "You can now run it using: ${YELLOW}sudo port-manager${NC}" 