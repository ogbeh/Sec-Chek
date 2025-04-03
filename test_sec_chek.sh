#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== sec-chek Installation Test ===${NC}"

# Check if sec-chek exists
if [ -f /usr/local/bin/sec-chek ]; then
    echo -e "${GREEN}✓ sec-chek is installed${NC}"
else
    echo -e "${RED}✗ sec-chek is not installed${NC}"
    exit 1
fi

# Check permissions
PERMS=$(ls -l /usr/local/bin/sec-chek | awk '{print $1}')
if [[ $PERMS == *"x"* ]]; then
    echo -e "${GREEN}✓ sec-chek is executable${NC}"
else
    echo -e "${RED}✗ sec-chek is not executable${NC}"
    echo -e "${YELLOW}Running: chmod +x /usr/local/bin/sec-chek${NC}"
    sudo chmod +x /usr/local/bin/sec-chek
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}✗ Script must be run as root${NC}"
    echo -e "${YELLOW}Please run: sudo sec-chek${NC}"
    exit 1
else
    echo -e "${GREEN}✓ Running as root${NC}"
fi

# Test basic functionality
echo -e "\n${BLUE}Testing basic functionality...${NC}"
if command -v netstat >/dev/null 2>&1; then
    echo -e "${GREEN}✓ netstat is installed${NC}"
else
    echo -e "${RED}✗ netstat is not installed${NC}"
fi

if command -v nmap >/dev/null 2>&1; then
    echo -e "${GREEN}✓ nmap is installed${NC}"
else
    echo -e "${RED}✗ nmap is not installed${NC}"
fi

# Try to run sec-chek
echo -e "\n${BLUE}Attempting to run sec-chek...${NC}"
if /usr/local/bin/sec-chek; then
    echo -e "${GREEN}✓ sec-chek ran successfully${NC}"
else
    echo -e "${RED}✗ sec-chek failed to run${NC}"
    echo -e "${YELLOW}Checking script contents...${NC}"
    head -n 5 /usr/local/bin/sec-chek
fi

echo -e "\n${BLUE}=== Test Complete ===${NC}" 