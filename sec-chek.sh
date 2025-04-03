#!/bin/bash

# sec-chek - Linux Network Security Check Script
# Author: Claude
# Version: 1.0

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if running as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Please run as root (use sudo)${NC}"
        exit 1
    fi
}

# Function to check OS compatibility
check_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
    else
        echo -e "${RED}Could not detect OS${NC}"
        exit 1
    fi
}

# Function to install dependencies
install_dependencies() {
    echo -e "${BLUE}Installing required dependencies...${NC}"
    case $OS in
        "Ubuntu"|"Debian GNU/Linux")
            apt-get update
            apt-get install -y net-tools nmap ufw iptables
            ;;
        "CentOS Linux"|"Red Hat Enterprise Linux")
            yum update -y
            yum install -y net-tools nmap firewalld iptables-services
            ;;
        *)
            echo -e "${RED}Unsupported OS: $OS${NC}"
            exit 1
            ;;
    esac
}

# Function to check firewall status
check_firewall() {
    echo -e "\n${BLUE}=== Firewall Status ===${NC}"
    case $OS in
        "Ubuntu"|"Debian GNU/Linux")
            ufw status | cat
            ;;
        "CentOS Linux"|"Red Hat Enterprise Linux")
            systemctl status firewalld | cat
            ;;
    esac
}

# Function to check open ports
check_open_ports() {
    echo -e "\n${BLUE}=== Open Ports ===${NC}"
    netstat -tuln | cat
}

# Function to check system security
check_system_security() {
    echo -e "\n${BLUE}=== System Security Checks ===${NC}"
    
    # Check for failed login attempts
    echo -e "\n${YELLOW}Recent Failed Login Attempts:${NC}"
    grep "Failed password" /var/log/auth.log 2>/dev/null || grep "Failed password" /var/log/secure 2>/dev/null
    
    # Check for root login attempts
    echo -e "\n${YELLOW}Root Login Attempts:${NC}"
    grep "root" /var/log/auth.log 2>/dev/null || grep "root" /var/log/secure 2>/dev/null
    
    # Check for running services
    echo -e "\n${YELLOW}Running Services:${NC}"
    systemctl list-units --type=service --state=running | cat
}

# Function to perform network scan
perform_network_scan() {
    echo -e "\n${BLUE}=== Network Scan ===${NC}"
    echo -e "${YELLOW}Scanning local network...${NC}"
    nmap -sn $(ip route | grep default | cut -d ' ' -f 3)/24
}

# Function to uninstall the script
uninstall() {
    echo -e "${BLUE}Uninstalling sec-chek...${NC}"
    rm -f /usr/local/bin/sec-chek
    echo -e "${GREEN}sec-chek has been uninstalled${NC}"
    exit 0
}

# Main menu function
show_menu() {
    while true; do
        echo -e "\n${BLUE}=== sec-chek Security Check Menu ===${NC}"
        echo -e "1) Check Firewall Status"
        echo -e "2) Check Open Ports"
        echo -e "3) Check System Security"
        echo -e "4) Perform Network Scan"
        echo -e "5) Uninstall sec-chek"
        echo -e "6) Exit"
        echo -e "${YELLOW}Enter your choice (1-6):${NC} "
        read choice

        case $choice in
            1) check_firewall ;;
            2) check_open_ports ;;
            3) check_system_security ;;
            4) perform_network_scan ;;
            5) uninstall ;;
            6) exit 0 ;;
            *) echo -e "${RED}Invalid option${NC}" ;;
        esac
    done
}

# Main execution
main() {
    check_root
    check_os
    install_dependencies
    show_menu
}

# Run main function
main 