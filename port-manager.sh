#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Version
VERSION="1.0.0"

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo -e "${RED}Please run as root (use sudo)${NC}"
        exit 1
    fi
}

# Function to check firewall status
check_firewall() {
    echo -e "${YELLOW}Checking firewall status...${NC}"
    if command -v ufw &> /dev/null; then
        ufw status | cat
    elif command -v firewalld &> /dev/null; then
        firewall-cmd --state
    else
        echo -e "${RED}No supported firewall found${NC}"
    fi
}

# Function to find process using port
find_port() {
    read -p "Enter port number: " port
    if ! [[ "$port" =~ ^[0-9]+$ ]]; then
        echo -e "${RED}Invalid port number${NC}"
        return
    fi
    
    echo -e "${YELLOW}Searching for process using port $port...${NC}"
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
        echo -e "${RED}Invalid port number${NC}"
        return
    fi
    
    echo -e "${YELLOW}Attempting to kill process using port $port...${NC}"
    if command -v lsof &> /dev/null; then
        pid=$(lsof -t -i:$port)
        if [ ! -z "$pid" ]; then
            kill -9 $pid
            echo -e "${GREEN}Process killed successfully${NC}"
        else
            echo -e "${RED}No process found using port $port${NC}"
        fi
    else
        echo -e "${RED}lsof not installed. Please install it first.${NC}"
    fi
}

# Function to show menu
show_menu() {
    echo -e "${YELLOW}=== Port Manager v$VERSION ===${NC}"
    echo "1. Check Firewall Status"
    echo "2. Find Process Using Port"
    echo "3. Kill Process Using Port"
    echo "4. List All Open Ports"
    echo "5. Uninstall"
    echo "6. Exit"
    echo
}

# Function to list all open ports
list_ports() {
    echo -e "${YELLOW}Listing all open ports...${NC}"
    if command -v netstat &> /dev/null; then
        netstat -tulpn 2>/dev/null
    else
        echo -e "${RED}netstat not installed. Please install it first.${NC}"
    fi
}

# Function to uninstall
uninstall() {
    echo -e "${YELLOW}Uninstalling Port Manager...${NC}"
    rm -f /usr/local/bin/port-manager
    echo -e "${GREEN}Port Manager uninstalled successfully${NC}"
}

# Main script
check_root

while true; do
    show_menu
    read -p "Enter your choice (1-6): " choice
    
    case $choice in
        1) check_firewall ;;
        2) find_port ;;
        3) kill_port ;;
        4) list_ports ;;
        5) uninstall; exit 0 ;;
        6) echo -e "${GREEN}Goodbye!${NC}"; exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
    echo
    read -p "Press Enter to continue..."
done 