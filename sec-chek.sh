#!/bin/bash

# sec-chek - Linux Network Security Check Script
# Author: Claude
# Version: 1.0

# Enable debug mode
set -x

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
    echo -e "${GREEN}Running with root privileges${NC}"
}

# Function to check OS compatibility
check_os() {
    echo -e "${BLUE}Detecting operating system...${NC}"
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$NAME
        echo -e "${GREEN}Detected OS: $OS${NC}"
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
            if ! command -v apt-get &> /dev/null; then
                echo -e "${RED}apt-get not found. Are you sure this is a Debian-based system?${NC}"
                exit 1
            fi
            apt-get update || { echo -e "${RED}Failed to update package list${NC}"; exit 1; }
            apt-get install -y net-tools nmap ufw iptables || { echo -e "${RED}Failed to install dependencies${NC}"; exit 1; }
            ;;
        "CentOS Linux"|"Red Hat Enterprise Linux")
            if ! command -v yum &> /dev/null; then
                echo -e "${RED}yum not found. Are you sure this is a Red Hat-based system?${NC}"
                exit 1
            fi
            yum update -y || { echo -e "${RED}Failed to update package list${NC}"; exit 1; }
            yum install -y net-tools nmap firewalld iptables-services || { echo -e "${RED}Failed to install dependencies${NC}"; exit 1; }
            ;;
        *)
            echo -e "${RED}Unsupported OS: $OS${NC}"
            exit 1
            ;;
    esac
    echo -e "${GREEN}Dependencies installed successfully${NC}"
}

# Function to check firewall status
check_firewall() {
    echo -e "\n${BLUE}=== Firewall Status ===${NC}"
    case $OS in
        "Ubuntu"|"Debian GNU/Linux")
            if command -v ufw &> /dev/null; then
                ufw status | cat
            else
                echo -e "${RED}UFW not found${NC}"
            fi
            ;;
        "CentOS Linux"|"Red Hat Enterprise Linux")
            if command -v firewalld &> /dev/null; then
                systemctl status firewalld | cat
            else
                echo -e "${RED}Firewalld not found${NC}"
            fi
            ;;
    esac
}

# Function to check open ports
check_open_ports() {
    echo -e "\n${BLUE}=== Open Ports ===${NC}"
    if command -v netstat &> /dev/null; then
        netstat -tuln | cat
    else
        echo -e "${RED}netstat not found${NC}"
    fi
}

# Function to check system security
check_system_security() {
    echo -e "\n${BLUE}=== System Security Checks ===${NC}"
    
    # Check for failed login attempts
    echo -e "\n${YELLOW}Recent Failed Login Attempts:${NC}"
    if [ -f /var/log/auth.log ]; then
        grep "Failed password" /var/log/auth.log 2>/dev/null
    elif [ -f /var/log/secure ]; then
        grep "Failed password" /var/log/secure 2>/dev/null
    else
        echo -e "${RED}Could not find auth logs${NC}"
    fi
    
    # Check for root login attempts
    echo -e "\n${YELLOW}Root Login Attempts:${NC}"
    if [ -f /var/log/auth.log ]; then
        grep "root" /var/log/auth.log 2>/dev/null
    elif [ -f /var/log/secure ]; then
        grep "root" /var/log/secure 2>/dev/null
    else
        echo -e "${RED}Could not find auth logs${NC}"
    fi
    
    # Check for running services
    echo -e "\n${YELLOW}Running Services:${NC}"
    if command -v systemctl &> /dev/null; then
        systemctl list-units --type=service --state=running | cat
    else
        echo -e "${RED}systemctl not found${NC}"
    fi
}

# Function to perform network scan
perform_network_scan() {
    echo -e "\n${BLUE}=== Network Scan ===${NC}"
    if command -v nmap &> /dev/null; then
        echo -e "${YELLOW}Scanning local network...${NC}"
        nmap -sn $(ip route | grep default | cut -d ' ' -f 3)/24
    else
        echo -e "${RED}nmap not found${NC}"
    fi
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
    echo -e "${BLUE}Starting sec-chek...${NC}"
    check_root
    check_os
    install_dependencies
    show_menu
}

# Run main function
main 