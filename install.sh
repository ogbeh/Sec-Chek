#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo -e "${RED}Please do not run as root${NC}"
    exit 1
fi

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python 3 is not installed. Installing...${NC}"
    
    # Detect distribution
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    else
        echo -e "${RED}Could not detect distribution${NC}"
        exit 1
    fi
    
    # Install Python 3 based on distribution
    case $OS in
        "Ubuntu"|"Debian GNU/Linux")
            sudo apt-get update
            sudo apt-get install -y python3
            ;;
        "CentOS Linux"|"Red Hat Enterprise Linux"|"Fedora")
            sudo dnf install -y python3
            ;;
        *)
            echo -e "${RED}Unsupported distribution: $OS${NC}"
            exit 1
            ;;
    esac
fi

echo -e "${GREEN}Installing Network Security Checker...${NC}"

# Create necessary directories
mkdir -p ~/.local/bin
mkdir -p ~/.local/share/network-security-checker

# Copy the script
cp src/security_checker.py ~/.local/share/network-security-checker/
chmod +x ~/.local/share/network-security-checker/security_checker.py

# Create wrapper script
cat > ~/.local/bin/security-checker << 'EOL'
#!/bin/bash
python3 ~/.local/share/network-security-checker/security_checker.py "$@"
EOL

chmod +x ~/.local/bin/security-checker

# Check if PATH includes ~/.local/bin
if ! grep -q "export PATH=\$PATH:\$HOME/.local/bin" ~/.bashrc; then
    echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
fi

# Check for required firewall tools
if ! command -v ufw &> /dev/null && ! command -v firewall-cmd &> /dev/null; then
    echo -e "${YELLOW}Warning: Neither UFW nor firewalld is installed. Firewall checks will not work.${NC}"
    echo -e "${YELLOW}To install UFW (Ubuntu/Debian): sudo apt-get install ufw${NC}"
    echo -e "${YELLOW}To install firewalld (CentOS/RHEL): sudo dnf install firewalld${NC}"
fi

echo -e "${GREEN}Installation complete!${NC}"
echo -e "You can now run the security checker by typing: ${GREEN}security-checker${NC}"
echo -e "Please restart your terminal or run: ${GREEN}source ~/.bashrc${NC}" 