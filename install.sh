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
echo -e "${BLUE}Script directory: $SCRIPT_DIR${NC}"

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

# Function to download the security checker
download_security_checker() {
    local temp_dir=$(mktemp -d)
    echo -e "${BLUE}Downloading security checker...${NC}"
    
    # Check if git is installed
    if command -v git &> /dev/null; then
        # Download the repository using git
        git clone https://github.com/ogbeh/Sec-Chek.git "$temp_dir" || {
            echo -e "${RED}Failed to download security checker using git.${NC}"
            rm -rf "$temp_dir"
            exit 1
        }
    else
        echo -e "${YELLOW}Git is not installed. Using alternative download method...${NC}"
        
        # Check if curl is installed
        if command -v curl &> /dev/null; then
            echo -e "${BLUE}Downloading using curl...${NC}"
            # Download the repository as a zip file
            curl -L https://github.com/ogbeh/Sec-Chek/archive/master.zip -o "$temp_dir/sec-chek.zip" || {
                echo -e "${RED}Failed to download security checker using curl.${NC}"
                rm -rf "$temp_dir"
                exit 1
            }
            
            # Check if unzip is installed
            if command -v unzip &> /dev/null; then
                echo -e "${BLUE}Extracting files...${NC}"
                unzip -q "$temp_dir/sec-chek.zip" -d "$temp_dir" || {
                    echo -e "${RED}Failed to extract the downloaded file.${NC}"
                    rm -rf "$temp_dir"
                    exit 1
                }
                # Move files from the extracted directory to temp_dir
                mv "$temp_dir/Sec-Chek-master"/* "$temp_dir/"
                rm -rf "$temp_dir/Sec-Chek-master"
            else
                echo -e "${RED}unzip is not installed. Please install unzip or git to continue.${NC}"
                rm -rf "$temp_dir"
                exit 1
            fi
        # Check if wget is installed
        elif command -v wget &> /dev/null; then
            echo -e "${BLUE}Downloading using wget...${NC}"
            # Download the repository as a zip file
            wget -q https://github.com/ogbeh/Sec-Chek/archive/master.zip -O "$temp_dir/sec-chek.zip" || {
                echo -e "${RED}Failed to download security checker using wget.${NC}"
                rm -rf "$temp_dir"
                exit 1
            }
            
            # Check if unzip is installed
            if command -v unzip &> /dev/null; then
                echo -e "${BLUE}Extracting files...${NC}"
                unzip -q "$temp_dir/sec-chek.zip" -d "$temp_dir" || {
                    echo -e "${RED}Failed to extract the downloaded file.${NC}"
                    rm -rf "$temp_dir"
                    exit 1
                }
                # Move files from the extracted directory to temp_dir
                mv "$temp_dir/Sec-Chek-master"/* "$temp_dir/"
                rm -rf "$temp_dir/Sec-Chek-master"
            else
                echo -e "${RED}unzip is not installed. Please install unzip or git to continue.${NC}"
                rm -rf "$temp_dir"
                exit 1
            fi
        else
            echo -e "${RED}Neither git, curl, nor wget is installed. Please install one of them to continue.${NC}"
            echo -e "${YELLOW}You can install them using:${NC}"
            echo -e "  - For Debian/Ubuntu: apt-get install git (or curl/wget)"
            echo -e "  - For CentOS/RHEL: yum install git (or curl/wget)"
            echo -e "  - For Arch Linux: pacman -S git (or curl/wget)"
            rm -rf "$temp_dir"
            exit 1
        fi
    fi
    
    # Debug: List the contents of the temp directory
    echo -e "${BLUE}Contents of downloaded repository:${NC}"
    ls -la "$temp_dir"
    
    # Check if the download was successful
    if [ ! -f "$temp_dir/sec-chek.py" ]; then
        echo -e "${RED}Downloaded repository does not contain sec-chek.py${NC}"
        echo -e "${YELLOW}Checking for alternative locations...${NC}"
        
        # Try to find the file in the repository
        if [ -f "$temp_dir/security_checker.py" ]; then
            echo -e "${GREEN}Found security_checker.py, renaming to sec-chek.py${NC}"
            # Rename the file
            mv "$temp_dir/security_checker.py" "$temp_dir/sec-chek.py"
        elif [ -f "$temp_dir/sec-chek/sec-chek.py" ]; then
            echo -e "${GREEN}Found sec-chek.py in sec-chek directory${NC}"
            # Copy the file to the root of temp_dir
            cp "$temp_dir/sec-chek/sec-chek.py" "$temp_dir/"
        elif [ -f "$temp_dir/src/security_checker.py" ]; then
            echo -e "${GREEN}Found security_checker.py in src directory, renaming to sec-chek.py${NC}"
            # Copy and rename the file
            cp "$temp_dir/src/security_checker.py" "$temp_dir/sec-chek.py"
        else
            echo -e "${YELLOW}Directory contents:${NC}"
            ls -la "$temp_dir"
            rm -rf "$temp_dir"
            exit 1
        fi
    fi
    
    echo -e "${GREEN}Download successful!${NC}"
    echo "$temp_dir"
}

# Function to check if security checker is already installed
check_existing_installation() {
    if [ -f "$SCRIPT_DIR/sec-chek/sec-chek.py" ]; then
        echo -e "${YELLOW}Security checker is already installed.${NC}"
        echo -e "1. Update (keep existing configuration)"
        echo -e "2. Reinstall (remove existing installation)"
        echo -e "3. Exit"
        echo
        read -p "Enter your choice (1-3): " choice
        
        case $choice in
            1)
                echo -e "${BLUE}Updating security checker...${NC}"
                return 0
                ;;
            2)
                echo -e "${BLUE}Reinstalling security checker...${NC}"
                rm -rf "$SCRIPT_DIR/sec-chek"
                return 0
                ;;
            3)
                echo -e "${BLUE}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Exiting...${NC}"
                exit 1
                ;;
        esac
    else
        return 1
    fi
}

# Main installation process
echo -e "${GREEN}=== Installing Network Security Checker ===${NC}"

# Check if already installed
check_existing_installation

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
INSTALL_DIR="$SCRIPT_DIR/sec-chek"
BIN_DIR="/usr/local/bin"

# Create necessary directories
echo -e "${BLUE}Creating installation directories...${NC}"
mkdir -p "$BIN_DIR"
mkdir -p "$INSTALL_DIR"

# Download the security checker
TEMP_DIR=$(download_security_checker)
SOURCE_FILE="$TEMP_DIR/sec-chek.py"

# Check if the source file exists
if [ ! -f "$SOURCE_FILE" ]; then
    echo -e "${RED}Error: Could not find sec-chek.py in the downloaded repository${NC}"
    echo -e "${YELLOW}Expected file location: $SOURCE_FILE${NC}"
    echo -e "${YELLOW}Directory contents:${NC}"
    ls -la "$TEMP_DIR"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Copy the script
echo -e "${BLUE}Copying security checker script...${NC}"
cp "$SOURCE_FILE" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/sec-chek.py"

# Verify the file was copied successfully
if [ ! -f "$INSTALL_DIR/sec-chek.py" ]; then
    echo -e "${RED}Error: Failed to copy sec-chek.py to $INSTALL_DIR${NC}"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Create menu script
echo -e "${BLUE}Creating menu script...${NC}"
cat > "$INSTALL_DIR/menu.py" << EOL
#!/usr/bin/env python3
import os
import sys
import subprocess
import time

def clear_screen():
    os.system('clear' if os.name == 'posix' else 'cls')

def print_header():
    clear_screen()
    print("=" * 60)
    print("           SECURITY CHECKER MENU")
    print("=" * 60)
    print()

def print_menu():
    print_header()
    print("1. Full Security Check")
    print("2. Check Firewall Status")
    print("3. Check Open Ports")
    print("4. Check System Information")
    print("5. Check User Accounts")
    print("6. Check Installed Packages")
    print("7. Check Network Configuration")
    print("8. Exit")
    print()
    print("=" * 60)
    print()

def run_check(check_type):
    print_header()
    print(f"Running {check_type}...")
    print("=" * 60)
    print()
    
    # Run the security checker with the appropriate option
    cmd = ["python3", "$INSTALL_DIR/sec-chek.py", check_type]
    process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    
    # Show a simple progress indicator
    while process.poll() is None:
        for char in "|/-\\\\":
            sys.stdout.write(f"\rRunning {check_type}... {char}")
            sys.stdout.flush()
            time.sleep(0.1)
    
    # Get the output
    stdout, stderr = process.communicate()
    
    # Clear the progress indicator
    sys.stdout.write("\r" + " " * 50 + "\r")
    
    # Print the output
    if stdout:
        print(stdout.decode('utf-8'))
    if stderr:
        print(stderr.decode('utf-8'))
    
    print()
    print("=" * 60)
    input("Press Enter to continue...")

def main():
    while True:
        print_menu()
        choice = input("Enter your choice (1-8): ")
        
        if choice == '1':
            run_check("full")
        elif choice == '2':
            run_check("firewall")
        elif choice == '3':
            run_check("ports")
        elif choice == '4':
            run_check("system")
        elif choice == '5':
            run_check("users")
        elif choice == '6':
            run_check("packages")
        elif choice == '7':
            run_check("network")
        elif choice == '8':
            print_header()
            print("Exiting Security Checker. Goodbye!")
            print("=" * 60)
            sys.exit(0)
        else:
            print("Invalid choice. Please try again.")
            time.sleep(1)

if __name__ == "__main__":
    main()
EOL

chmod +x "$INSTALL_DIR/menu.py"

# Create wrapper script
echo -e "${BLUE}Creating wrapper script...${NC}"
cat > "$BIN_DIR/sec-chek" << EOL
#!/bin/bash
if [ "\$EUID" -ne 0 ]; then 
    echo -e "${RED}This command must be run as root${NC}"
    echo -e "${YELLOW}Please run with sudo: sudo sec-chek${NC}"
    exit 1
fi

# Check if an argument was provided
if [ \$# -eq 0 ]; then
    # No arguments, run the menu
    python3 "$INSTALL_DIR/menu.py"
else
    # Arguments provided, run the security checker with those arguments
    python3 "$INSTALL_DIR/sec-chek.py" "\$@"
fi
EOL

chmod +x "$BIN_DIR/sec-chek"

# Clean up temporary directory
echo -e "${BLUE}Cleaning up...${NC}"
rm -rf "$TEMP_DIR"

# Check and install firewall tools
check_firewall $DIST

echo -e "${GREEN}=== Installation complete! ===${NC}"
echo -e "You can now run the security checker by typing: ${GREEN}sudo sec-chek${NC}"

# Run the security checker immediately
echo -e "${GREEN}=== Running security check now... ===${NC}"
echo -e "${BLUE}This may take a few minutes...${NC}"

# Check if the security checker exists before running it
if [ ! -f "$INSTALL_DIR/sec-chek.py" ]; then
    echo -e "${RED}Error: sec-chek.py not found at $INSTALL_DIR/sec-chek.py${NC}"
    echo -e "${YELLOW}Skipping initial security check.${NC}"
    echo -e "You can run the security checker manually by typing: ${GREEN}sudo sec-chek${NC}"
else
    # Run the security checker in the background and show progress
    python3 "$INSTALL_DIR/sec-chek.py" &
    SECURITY_CHECK_PID=$!
    show_progress $SECURITY_CHECK_PID "Running security check..."

    # Wait for the security check to complete
    wait $SECURITY_CHECK_PID

    echo -e "${GREEN}=== Security check complete! ===${NC}"
    echo -e "Check the generated report for detailed results."
fi

echo -e "To run the interactive menu, type: ${GREEN}sudo sec-chek${NC}"