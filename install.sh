#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Function to detect distribution
detect_distribution() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        # Fallback to older methods
        if [ -f /etc/redhat-release ]; then
            OS=$(cat /etc/redhat-release | awk '{print $1}' | tr '[:upper:]' '[:lower:]')
        elif [ -f /etc/debian_version ]; then
            OS="debian"
        elif [ -f /etc/arch-release ]; then
            OS="arch"
        elif [ -f /etc/SuSE-release ]; then
            OS="suse"
        else
            OS="unknown"
        fi
    fi
    echo $OS
}

# Function to install Python 3 based on distribution
install_python3() {
    local dist=$1
    case $dist in
        "ubuntu"|"debian"|"linuxmint")
            if [ "$EUID" -eq 0 ]; then
                apt-get update
                apt-get install -y python3
            else
                sudo apt-get update
                sudo apt-get install -y python3
            fi
            ;;
        "centos"|"rhel"|"fedora")
            if [ "$EUID" -eq 0 ]; then
                dnf install -y python3
            else
                sudo dnf install -y python3
            fi
            ;;
        "arch")
            if [ "$EUID" -eq 0 ]; then
                pacman -S --noconfirm python
            else
                sudo pacman -S --noconfirm python
            fi
            ;;
        "suse")
            if [ "$EUID" -eq 0 ]; then
                zypper install -y python3
            else
                sudo zypper install -y python3
            fi
            ;;
        *)
            echo -e "${RED}Unsupported distribution: $dist${NC}"
            exit 1
            ;;
    esac
}

# Function to check and install firewall tools
check_firewall() {
    local dist=$1
    case $dist in
        "ubuntu"|"debian"|"linuxmint")
            if ! command -v ufw &> /dev/null; then
                echo -e "${YELLOW}Installing UFW...${NC}"
                if [ "$EUID" -eq 0 ]; then
                    apt-get install -y ufw
                else
                    sudo apt-get install -y ufw
                fi
            fi
            ;;
        "centos"|"rhel"|"fedora")
            if ! command -v firewall-cmd &> /dev/null; then
                echo -e "${YELLOW}Installing firewalld...${NC}"
                if [ "$EUID" -eq 0 ]; then
                    dnf install -y firewalld
                else
                    sudo dnf install -y firewalld
                fi
            fi
            ;;
        "arch")
            if ! command -v iptables &> /dev/null; then
                echo -e "${YELLOW}Installing iptables...${NC}"
                if [ "$EUID" -eq 0 ]; then
                    pacman -S --noconfirm iptables
                else
                    sudo pacman -S --noconfirm iptables
                fi
            fi
            ;;
        "suse")
            if ! command -v SuSEfirewall2 &> /dev/null; then
                echo -e "${YELLOW}Installing SuSEfirewall2...${NC}"
                if [ "$EUID" -eq 0 ]; then
                    zypper install -y SuSEfirewall2
                else
                    sudo zypper install -y SuSEfirewall2
                fi
            fi
            ;;
    esac
}

# Main installation process
echo -e "${GREEN}Installing Network Security Checker...${NC}"

# Detect distribution
DIST=$(detect_distribution)
echo -e "${GREEN}Detected distribution: $DIST${NC}"

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python 3 is not installed. Installing...${NC}"
    install_python3 $DIST
fi

# Set installation directories based on user mode
if [ "$EUID" -eq 0 ]; then
    INSTALL_DIR="/usr/local/share/network-security-checker"
    BIN_DIR="/usr/local/bin"
else
    INSTALL_DIR="$HOME/.local/share/network-security-checker"
    BIN_DIR="$HOME/.local/bin"
fi

# Create necessary directories
mkdir -p "$BIN_DIR"
mkdir -p "$INSTALL_DIR"

# Copy the script
cp src/security_checker.py "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/security_checker.py"

# Create wrapper script
cat > "$BIN_DIR/security-checker" << EOL
#!/bin/bash
python3 "$INSTALL_DIR/security_checker.py" "\$@"
EOL

chmod +x "$BIN_DIR/security-checker"

# Add to PATH if not already present (only for non-root users)
if [ "$EUID" -ne 0 ]; then
    if ! grep -q "export PATH=\$PATH:\$HOME/.local/bin" ~/.bashrc; then
        echo 'export PATH=$PATH:$HOME/.local/bin' >> ~/.bashrc
    fi
fi

# Check and install firewall tools
check_firewall $DIST

echo -e "${GREEN}Installation complete!${NC}"
echo -e "You can now run the security checker by typing: ${GREEN}security-checker${NC}"
if [ "$EUID" -ne 0 ]; then
    echo -e "Please restart your terminal or run: ${GREEN}source ~/.bashrc${NC}"
fi