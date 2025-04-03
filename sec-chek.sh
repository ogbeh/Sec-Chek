#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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
    echo "║           SEC-CHEK v1.0               ║"
    echo "║     Linux Security Checking Tool      ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
}

# Function to check firewall status
check_firewall() {
    echo -e "\n${YELLOW}[*] Checking Firewall Status...${NC}"
    if command -v ufw >/dev/null 2>&1; then
        ufw status verbose
    elif command -v firewall-cmd >/dev/null 2>&1; then
        firewall-cmd --list-all
    else
        echo -e "${RED}[!] No firewall detected${NC}"
    fi
}

# Function to check open ports
check_ports() {
    echo -e "\n${YELLOW}[*] Checking Open Ports...${NC}"
    if command -v netstat >/dev/null 2>&1; then
        netstat -tuln
    else
        echo -e "${RED}[!] netstat not found${NC}"
    fi
}

# Function to check system updates
check_updates() {
    echo -e "\n${YELLOW}[*] Checking for System Updates...${NC}"
    if command -v apt >/dev/null 2>&1; then
        apt update
        apt list --upgradable
    elif command -v dnf >/dev/null 2>&1; then
        dnf check-update
    else
        echo -e "${RED}[!] Package manager not found${NC}"
    fi
}

# Function to uninstall
uninstall() {
    echo -e "${YELLOW}[*] Uninstalling SEC-CHEK...${NC}"
    rm -f /root/sec-chek.sh
    echo -e "${GREEN}[+] Uninstallation completed${NC}"
    exit 0
}

# Main menu loop
while true; do
    show_banner
    echo "Please select an option:"
    echo "1. Check Firewall Status"
    echo "2. Check Open Ports"
    echo "3. Check System Updates"
    echo "4. Run All Checks"
    echo "5. Uninstall SEC-CHEK"
    echo "0. Exit"
    echo
    printf "Enter your choice (0-5): "
    read choice

    case $choice in
        1)
            clear
            check_firewall
            echo
            read -p "Press Enter to continue..."
            ;;
        2)
            clear
            check_ports
            echo
            read -p "Press Enter to continue..."
            ;;
        3)
            clear
            check_updates
            echo
            read -p "Press Enter to continue..."
            ;;
        4)
            clear
            check_firewall
            check_ports
            check_updates
            echo
            read -p "Press Enter to continue..."
            ;;
        5)
            clear
            echo -e "${YELLOW}Are you sure you want to uninstall? (y/n): ${NC}"
            read confirm
            if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
                uninstall
            fi
            ;;
        0)
            clear
            echo -e "${GREEN}Exiting SEC-CHEK. Goodbye!${NC}"
            exit 0
            ;;
        *)
            clear
            echo -e "${RED}Invalid option. Please try again.${NC}"
            sleep 2
            ;;
    esac
done 