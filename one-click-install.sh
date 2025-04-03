#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] This script must be run as root${NC}"
    exit 1
fi

echo -e "${BLUE}[*] Starting SEC-CHEK installation...${NC}"

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}[*] Git not found. Installing git...${NC}"
    if command -v apt &> /dev/null; then
        apt update
        apt install -y git
    elif command -v dnf &> /dev/null; then
        dnf install -y git
    else
        echo -e "${RED}[!] Package manager not found. Please install git manually.${NC}"
        exit 1
    fi
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
cd $TEMP_DIR

# Clone the repository
echo -e "${BLUE}[*] Cloning SEC-CHEK repository...${NC}"
git clone https://github.com/ogbeh/sec-chek.git

# Check if clone was successful
if [ $? -ne 0 ]; then
    echo -e "${RED}[!] Failed to clone repository${NC}"
    rm -rf $TEMP_DIR
    exit 1
fi

# Copy files to root directory
echo -e "${BLUE}[*] Installing SEC-CHEK...${NC}"
cp sec-chek/sec-chek.sh /root/
chmod +x /root/sec-chek.sh

# Clean up
cd
rm -rf $TEMP_DIR

echo -e "${GREEN}[+] Installation completed successfully!${NC}"
echo -e "${YELLOW}[*] Starting SEC-CHEK...${NC}"

# Run the script
/root/sec-chek.sh 