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

# Create installation directory and modules directory
mkdir -p $INSTALL_DIR
mkdir -p $INSTALL_DIR/modules

# Create the main script directly
cat > $INSTALL_DIR/sec-check.sh << 'EOL'
#!/bin/bash
# [Previous sec-check.sh content goes here]
EOL

# Set correct permissions
chmod +x $INSTALL_DIR/sec-check.sh

# Create the symbolic link
ln -sf $INSTALL_DIR/sec-check.sh /usr/local/bin/sec-check

# Verify installation
if [ -f "$INSTALL_DIR/sec-check.sh" ] && [ -x "$INSTALL_DIR/sec-check.sh" ]; then
    echo -e "${GREEN}[+] Installation completed successfully!${NC}"
    echo -e "${YELLOW}[*] You can run the tool using either:${NC}"
    echo -e "${BLUE}    - /root/sec-check/sec-check.sh${NC}"
    echo -e "${BLUE}    - sec-check${NC}"
else
    echo -e "${RED}[!] Installation failed${NC}"
    exit 1
fi 