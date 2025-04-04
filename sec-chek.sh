#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Version
VERSION="1.0.0"

# Configuration
CONFIG_DIR="/etc/sec-chek"
LOG_FILE="/var/log/sec-chek.log"
BACKUP_DIR="/etc/sec-chek/backups"
SCRIPT_NAME="sec-chek"
GITHUB_REPO="ogbeh/sec-chek"
GITHUB_RAW="https://raw.githubusercontent.com/$GITHUB_REPO/main/$SCRIPT_NAME"

# Function to log messages
log_message() {
    local message="$1"
    local level="${2:-INFO}"
    echo -e "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" | tee -a "$LOG_FILE"
}

# Function to create required directories
setup_directories() {
    mkdir -p "$CONFIG_DIR" "$BACKUP_DIR"
    touch "$LOG_FILE"
    chmod 600 "$LOG_FILE"
}

# Function to check and install required tools
check_requirements() {
    local missing_tools=()
    
    # Check for netstat
    if ! command -v netstat &> /dev/null; then
        missing_tools+=("net-tools")
    fi
    
    # Check for lsof
    if ! command -v lsof &> /dev/null; then
        missing_tools+=("lsof")
    fi
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        log_message "Installing required tools..." "INFO"
        if command -v apt-get &> /dev/null; then
            apt-get update
            apt-get install -y "${missing_tools[@]}"
        elif command -v yum &> /dev/null; then
            yum install -y "${missing_tools[@]}"
        elif command -v dnf &> /dev/null; then
            dnf install -y "${missing_tools[@]}"
        else
            log_message "Could not install required tools. Please install them manually: ${missing_tools[*]}" "ERROR"
            exit 1
        fi
    fi
}

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        log_message "Please run as root (use sudo)" "ERROR"
        exit 1
    fi
}

# Function to check port status
check_port_status() {
    read -p "Enter port number: " port
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        log_message "Invalid port number" "ERROR"
        return
    fi
    
    echo -e "${YELLOW}Checking status of port $port...${NC}"
    if command -v netstat &> /dev/null; then
        netstat -tulpn 2>/dev/null | grep ":$port"
    elif command -v ss &> /dev/null; then
        ss -tulpn | grep ":$port"
    elif command -v lsof &> /dev/null; then
        lsof -i :$port
    fi
}

# Function to check firewall status
check_firewall() {
    log_message "Checking firewall status..." "INFO"
    if command -v ufw &> /dev/null; then
        ufw status | cat
    elif command -v firewalld &> /dev/null; then
        firewall-cmd --state
    else
        log_message "No supported firewall found" "WARNING"
    fi
}

# Function to find process using port
find_port() {
    read -p "Enter port number: " port
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        log_message "Invalid port number" "ERROR"
        return
    fi
    
    log_message "Searching for process using port $port..." "INFO"
    if command -v lsof &> /dev/null; then
        lsof -i :$port
    else
        netstat -tulpn 2>/dev/null | grep :$port
    fi
}

# Function to kill process using port
kill_port() {
    read -p "Enter port number: " port
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        log_message "Invalid port number" "ERROR"
        return
    fi
    
    log_message "Attempting to kill process using port $port..." "INFO"
    if command -v lsof &> /dev/null; then
        pid=$(lsof -t -i:$port)
        if [ ! -z "$pid" ]; then
            kill -9 $pid
            log_message "Process killed successfully" "INFO"
        else
            log_message "No process found using port $port" "WARNING"
        fi
    else
        log_message "lsof not installed" "ERROR"
    fi
}

# Function to show menu
show_menu() {
    echo -e "${YELLOW}=== Sec-Chek v$VERSION ===${NC}"
    echo "1. Check Firewall Status"
    echo "2. Find Process Using Port"
    echo "3. Kill Process Using Port"
    echo "4. List All Open Ports"
    echo "5. Check Port Status"
    echo "6. Show System Information"
    echo "7. Check for Updates"
    echo "8. Uninstall"
    echo "9. Exit"
    echo
}

# Function to list all open ports
list_ports() {
    log_message "Listing all open ports..." "INFO"
    if command -v netstat &> /dev/null; then
        netstat -tulpn 2>/dev/null
    elif command -v ss &> /dev/null; then
        ss -tulpn
    elif command -v lsof &> /dev/null; then
        lsof -i -P -n | grep LISTEN
    else
        log_message "No suitable tool found to list ports. Installing required tools..." "WARNING"
        check_requirements
        if command -v netstat &> /dev/null; then
            netstat -tulpn 2>/dev/null
        fi
    fi
}

# Function to show system information
show_system_info() {
    echo -e "${BLUE}=== System Information ===${NC}"
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Distribution: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/*release 2>/dev/null | head -n1)"
    echo "CPU: $(grep 'model name' /proc/cpuinfo | head -n1 | cut -d':' -f2 | xargs)"
    echo "Memory: $(free -h | grep Mem | awk '{print $2}')"
    echo "Uptime: $(uptime -p)"
    echo "Firewall Status: $(if command -v ufw &> /dev/null; then ufw status | grep Status; elif command -v firewalld &> /dev/null; then firewall-cmd --state; else echo "No firewall found"; fi)"
}

# Function to create backup before uninstallation
create_backup() {
    local backup_file="$BACKUP_DIR/sec-chek_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "$backup_file" "$CONFIG_DIR" "$LOG_FILE" 2>/dev/null
    if [ $? -eq 0 ]; then
        log_message "Backup created successfully at $backup_file" "INFO"
    else
        log_message "Failed to create backup" "ERROR"
    fi
}

# Function to uninstall
uninstall() {
    log_message "Uninstalling Sec-Chek..." "INFO"
    create_backup
    rm -f /usr/local/bin/sec-chek
    rm -rf "$CONFIG_DIR"
    log_message "Sec-Chek uninstalled successfully" "INFO"
}

# Function to check for updates
check_updates() {
    log_message "Checking for updates..." "INFO"
    
    # Create temporary file
    local temp_file=$(mktemp)
    
    # Download latest version
    if ! curl -s "$GITHUB_RAW" -o "$temp_file"; then
        log_message "Failed to check for updates" "ERROR"
        rm -f "$temp_file"
        return 1
    fi
    
    # Get version from downloaded file
    local latest_version=$(grep -m 1 'VERSION=' "$temp_file" | cut -d'"' -f2)
    
    if [ "$latest_version" != "$VERSION" ]; then
        echo -e "${YELLOW}New version $latest_version available (current: $VERSION)${NC}"
        read -p "Do you want to update? (y/n): " choice
        if [[ $choice =~ ^[Yy]$ ]]; then
            # Create backup before update
            create_backup
            
            # Update the script
            if mv "$temp_file" "/usr/local/bin/$SCRIPT_NAME" && chmod +x "/usr/local/bin/$SCRIPT_NAME"; then
                log_message "Successfully updated to version $latest_version" "INFO"
                echo -e "${GREEN}Update successful! Please restart the script.${NC}"
                exit 0
            else
                log_message "Failed to update script" "ERROR"
                rm -f "$temp_file"
                return 1
            fi
        else
            log_message "Update cancelled by user" "INFO"
        fi
    else
        log_message "You are running the latest version ($VERSION)" "INFO"
    fi
    
    rm -f "$temp_file"
}

# Main script
check_root
setup_directories
check_requirements

while true; do
    show_menu
    read -p "Enter your choice (1-9): " choice
    
    case $choice in
        1) check_firewall ;;
        2) find_port ;;
        3) kill_port ;;
        4) list_ports ;;
        5) check_port_status ;;
        6) show_system_info ;;
        7) check_updates ;;
        8) uninstall; exit 0 ;;
        9) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) log_message "Invalid option" "ERROR" ;;
    esac
    echo
    read -p "Press Enter to continue..."
done 