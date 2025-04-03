#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Script version
VERSION="1.0"

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] This script must be run as root${NC}"
    exit 1
fi

# Function to display banner
show_banner() {
    clear
    echo -e "${BLUE}"
    echo "╔═══════════════════════════════════════╗"
    echo "║           SEC-CHECK v${VERSION}              ║"
    echo "║     Linux Security Checking Tool      ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to check firewall status
check_firewall() {
    echo -e "\n${YELLOW}[*] Checking Firewall Status...${NC}"
    
    if command -v ufw >/dev/null 2>&1; then
        echo -e "${BLUE}[*] UFW Status:${NC}"
        ufw status verbose
    elif command -v firewalld >/dev/null 2>&1; then
        echo -e "${BLUE}[*] FirewallD Status:${NC}"
        firewall-cmd --list-all
    else
        echo -e "${RED}[!] No firewall detected${NC}"
    fi
}

# Function to check open ports
check_open_ports() {
    echo -e "\n${YELLOW}[*] Checking Open Ports...${NC}"
    netstat -tuln | grep LISTEN
}

# Function to check system updates
check_updates() {
    echo -e "\n${YELLOW}[*] Checking System Updates...${NC}"
    
    if command -v apt >/dev/null 2>&1; then
        apt update >/dev/null 2>&1
        updates=$(apt list --upgradable 2>/dev/null | wc -l)
        echo -e "${BLUE}[*] Available updates: $((updates-1))${NC}"
    elif command -v dnf >/dev/null 2>&1; then
        dnf check-update >/dev/null 2>&1
        updates=$(dnf check-update --quiet | wc -l)
        echo -e "${BLUE}[*] Available updates: $updates${NC}"
    fi
}

# Function to check SSH configuration
check_ssh() {
    echo -e "\n${YELLOW}[*] Checking SSH Configuration...${NC}"
    if [ -f "/etc/ssh/sshd_config" ]; then
        echo -e "${BLUE}[*] SSH Configuration:${NC}"
        grep -E "^Port|^PermitRootLogin|^PasswordAuthentication" /etc/ssh/sshd_config
    else
        echo -e "${RED}[!] SSH configuration not found${NC}"
    fi
}

# Function to uninstall
uninstall() {
    echo -e "${YELLOW}[*] Uninstalling SEC-CHECK...${NC}"
    rm -rf /root/sec-check
    rm -f /usr/local/bin/sec-check
    echo -e "${GREEN}[+] Uninstallation completed${NC}"
    exit 0
}

# Main menu
while true; do
    show_banner
    echo -e "1. Check Firewall Status"
    echo -e "2. Scan Open Ports"
    echo -e "3. Check System Updates"
    echo -e "4. Check SSH Configuration"
    echo -e "5. Run All Checks"
    echo -e "6. Uninstall SEC-CHECK"
    echo -e "0. Exit"
    
    read -p "Select an option: " choice
    
    case $choice in
        1) check_firewall ;;
        2) check_open_ports ;;
        3) check_updates ;;
        4) check_ssh ;;
        5)
            check_firewall
            check_open_ports
            check_updates
            check_ssh
            ;;
        6) uninstall ;;
        0) exit 0 ;;
        *) echo -e "${RED}[!] Invalid option${NC}" ;;
    esac
    
    read -p "Press Enter to continue..."
done 