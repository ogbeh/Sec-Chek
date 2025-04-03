#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Installation directory
INSTALL_DIR="/root/sec-check"

echo -e "${BLUE}[*] Installing SEC-CHECK Security Tool...${NC}"

# Create installation directory
mkdir -p $INSTALL_DIR

# Download main script
curl -s https://raw.githubusercontent.com/yourusername/sec-check/main/sec-check.sh -o $INSTALL_DIR/sec-check.sh
curl -s https://raw.githubusercontent.com/yourusername/sec-check/main/modules/* -o $INSTALL_DIR/modules/

# Set permissions
chmod +x $INSTALL_DIR/sec-check.sh
chmod +x $INSTALL_DIR/modules/*

# Create symbolic link
ln -sf $INSTALL_DIR/sec-check.sh /usr/local/bin/sec-check

echo -e "${GREEN}[+] Installation completed!${NC}"
echo -e "${YELLOW}[*] Run 'sec-check' to start the security check${NC}" 