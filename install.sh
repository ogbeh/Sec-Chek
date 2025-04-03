#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}[*] Installing SEC-CHEK...${NC}"

# Copy script to root directory
cp sec-chek.sh /root/
chmod +x /root/sec-chek.sh

echo -e "${GREEN}[+] Installation completed!${NC}"
echo -e "${YELLOW}[*] Run '/root/sec-chek.sh' to start the security check${NC}" 