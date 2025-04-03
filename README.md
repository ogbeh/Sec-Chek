# sec-chek - Linux Network Security Check Tool

A comprehensive Linux network security checking tool that provides a one-click installation and easy-to-use menu interface for performing various security checks on your Linux system.

## Features

- One-click installation
- Interactive menu interface
- Checks for:
  - Firewall status
  - Open ports
  - System security
  - Network scanning
- Color-coded output
- Uninstall option
- Works on common Linux distributions (Ubuntu, Debian, CentOS, RHEL)

## Installation

### One-Click Installation

```bash
wget -qO- https://raw.githubusercontent.com/ogbeh/sec-chek/main/install.sh | sudo bash
```

### Manual Installation

1. Download the script:
```bash
wget https://raw.githubusercontent.com/ogbeh/sec-chek/main/sec-chek.sh
```

2. Make it executable:
```bash
chmod +x sec-chek.sh
```

3. Move to system directory:
```bash
sudo mv sec-chek.sh /usr/local/bin/sec-chek
```

## Usage

Run the script with sudo privileges:
```bash
sudo sec-chek
```

The script will present an interactive menu with the following options:
1. Check Firewall Status
2. Check Open Ports
3. Check System Security
4. Perform Network Scan
5. Uninstall sec-chek
6. Exit

## Requirements

- Root privileges (sudo)
- Supported Linux distributions:
  - Ubuntu
  - Debian
  - CentOS
  - Red Hat Enterprise Linux

## Uninstallation

You can uninstall sec-chek either through the menu option (5) or by running:
```bash
sudo rm /usr/local/bin/sec-chek
```

## Security Note

This script requires root privileges to perform system checks. Always review the source code before running scripts with elevated privileges.

## License

MIT License 