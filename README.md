# Port Manager

A powerful Bash script for managing ports and checking firewall status on Linux systems.

## Features

- Check firewall status (supports UFW and FirewallD)
- Find processes using specific ports
- Kill processes using specific ports
- List all open ports
- Easy installation and uninstallation
- User-friendly menu interface

## Requirements

- Linux operating system
- Root privileges (sudo access)
- Basic system tools (netstat, lsof)

## Installation

### Method 1: Direct Installation

```bash
curl -s https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/install.sh | sudo bash
```

### Method 2: Manual Installation

1. Clone this repository:
```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
cd YOUR_REPO
```

2. Make the script executable:
```bash
chmod +x port-manager.sh
```

3. Move the script to system directory:
```bash
sudo mv port-manager.sh /usr/local/bin/port-manager
```

## Usage

Run the script with sudo privileges:

```bash
sudo port-manager
```

## Menu Options

1. Check Firewall Status - Shows the current status of your firewall
2. Find Process Using Port - Searches for processes using a specific port
3. Kill Process Using Port - Terminates a process using a specific port
4. List All Open Ports - Shows all currently open ports
5. Uninstall - Removes the script from your system
6. Exit - Closes the program

## Uninstallation

You can uninstall the script either through the menu option (Option 5) or manually:

```bash
sudo rm /usr/local/bin/port-manager
```

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details. 