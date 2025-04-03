#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}This script must be run as root${NC}"
    echo -e "${YELLOW}Please run with sudo: sudo ./install.sh${NC}"
    exit 1
fi

# Get the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Function to show progress
show_progress() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while kill -0 $pid 2>/dev/null; do
        local temp=${spinstr#?}
        printf "\r[%c] %s" "$spinstr" "$2"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
    done
    printf "\r   \r"
}

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
    echo -e "${BLUE}Installing Python 3 for $dist...${NC}"
    case $dist in
        "ubuntu"|"debian"|"linuxmint")
            apt-get update
            apt-get install -y python3
            ;;
        "centos"|"rhel"|"fedora")
            dnf install -y python3
            ;;
        "arch")
            pacman -S --noconfirm python
            ;;
        "suse")
            zypper install -y python3
            ;;
        *)
            echo -e "${RED}Unsupported distribution: $dist${NC}"
            exit 1
            ;;
    esac
    echo -e "${GREEN}Python 3 installation complete${NC}"
}

# Function to check and install firewall tools
check_firewall() {
    local dist=$1
    echo -e "${BLUE}Checking firewall tools for $dist...${NC}"
    case $dist in
        "ubuntu"|"debian"|"linuxmint")
            if ! command -v ufw &> /dev/null; then
                echo -e "${YELLOW}Installing UFW...${NC}"
                apt-get install -y ufw
                echo -e "${GREEN}UFW installation complete${NC}"
            else
                echo -e "${GREEN}UFW is already installed${NC}"
            fi
            ;;
        "centos"|"rhel"|"fedora")
            if ! command -v firewall-cmd &> /dev/null; then
                echo -e "${YELLOW}Installing firewalld...${NC}"
                dnf install -y firewalld
                echo -e "${GREEN}firewalld installation complete${NC}"
            else
                echo -e "${GREEN}firewalld is already installed${NC}"
            fi
            ;;
        "arch")
            if ! command -v iptables &> /dev/null; then
                echo -e "${YELLOW}Installing iptables...${NC}"
                pacman -S --noconfirm iptables
                echo -e "${GREEN}iptables installation complete${NC}"
            else
                echo -e "${GREEN}iptables is already installed${NC}"
            fi
            ;;
        "suse")
            if ! command -v SuSEfirewall2 &> /dev/null; then
                echo -e "${YELLOW}Installing SuSEfirewall2...${NC}"
                zypper install -y SuSEfirewall2
                echo -e "${GREEN}SuSEfirewall2 installation complete${NC}"
            else
                echo -e "${GREEN}SuSEfirewall2 is already installed${NC}"
            fi
            ;;
    esac
}

# Main installation process
echo -e "${GREEN}=== Installing Network Security Checker ===${NC}"

# Detect distribution
DIST=$(detect_distribution)
echo -e "${GREEN}Detected distribution: $DIST${NC}"

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python 3 is not installed. Installing...${NC}"
    install_python3 $DIST
else
    echo -e "${GREEN}Python 3 is already installed${NC}"
fi

# Set installation directories (root only)
INSTALL_DIR="/opt/sec-chek"
BIN_DIR="/usr/local/bin"

# Create necessary directories
echo -e "${BLUE}Creating installation directories...${NC}"
mkdir -p "$BIN_DIR"
mkdir -p "$INSTALL_DIR"

# Check if source file exists
SOURCE_FILE="$SCRIPT_DIR/src/security_checker.py"
if [ ! -f "$SOURCE_FILE" ]; then
    echo -e "${RED}Error: Could not find security_checker.py in $SOURCE_FILE${NC}"
    echo -e "${YELLOW}Please make sure you're running the install script from the project root directory${NC}"
    exit 1
fi

# Copy the script
echo -e "${BLUE}Copying security checker script...${NC}"
cp "$SOURCE_FILE" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/security_checker.py"

# Create wrapper script
echo -e "${BLUE}Creating wrapper script...${NC}"
cat > "$BIN_DIR/security-checker" << EOL
#!/bin/bash
if [ "\$EUID" -ne 0 ]; then 
    echo -e "${RED}This command must be run as root${NC}"
    echo -e "${YELLOW}Please run with sudo: sudo security-checker${NC}"
    exit 1
fi
python3 "$INSTALL_DIR/security_checker.py" "\$@"
EOL

chmod +x "$BIN_DIR/security-checker"

# Check and install firewall tools
check_firewall $DIST

echo -e "${GREEN}=== Installation complete! ===${NC}"
echo -e "You can now run the security checker by typing: ${GREEN}sudo security-checker${NC}"

# Run the security checker immediately
echo -e "${GREEN}=== Running security check now... ===${NC}"
echo -e "${BLUE}This may take a few minutes...${NC}"

# Run the security checker in the background and show progress
python3 "$INSTALL_DIR/security_checker.py" &
SECURITY_CHECK_PID=$!
show_progress $SECURITY_CHECK_PID "Running security check..."

# Wait for the security check to complete
wait $SECURITY_CHECK_PID

echo -e "${GREEN}=== Security check complete! ===${NC}"
echo -e "Check the generated report for detailed results."