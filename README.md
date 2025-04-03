# Sec-Chek

A simple and efficient network security assessment tool for Linux systems that provides quick insights into your system's security status.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Supported Distributions

### Debian Family
- Ubuntu
- Debian
- Linux Mint
- Other Debian-based distributions

### Red Hat Family
- CentOS
- RHEL (Red Hat Enterprise Linux)
- Fedora
- Other RHEL-based distributions

### Other Distributions
- Arch Linux
- openSUSE
- SUSE Linux Enterprise

## Features

- Distribution-specific firewall status check:
  - UFW for Debian/Ubuntu family
  - firewalld for RHEL family
  - iptables for Arch Linux
  - SuSEfirewall2 for SUSE
- Common port scanning
- System information gathering
- HTML report generation
- Automatic distribution detection
- Distribution-specific package management

## Installation

### Quick Install (One-Liner)
```bash
curl -s https://raw.githubusercontent.com/ogbeh/Sec-Chek/master/install.sh | bash
```

### Alternative Quick Install
```bash
wget -qO- https://raw.githubusercontent.com/ogbeh/Sec-Chek/master/install.sh | bash
```

### Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/ogbeh/Sec-Chek.git
cd Sec-Chek
```

2. Make the script executable:
```bash
chmod +x install.sh
```

3. Run the installer:
```bash
./install.sh
```

### Direct Download
You can also download the installation script directly:
```bash
wget https://raw.githubusercontent.com/ogbeh/Sec-Chek/master/install.sh
chmod +x install.sh
./install.sh
```

## Requirements

- Python 3.6 or higher (will be installed automatically if missing)
- sudo privileges (for firewall checks)
- Internet connection (for initial installation)

## Output

The script generates an HTML report (`security_report.html`) containing:
- System information (distribution, version, architecture)
- Firewall status (distribution-specific)
- Open ports
- Security recommendations

## Usage

After installation, simply run:
```bash
security-checker
```

The report will be generated in your current directory.

## Distribution-Specific Notes

### Debian/Ubuntu Family
- Uses UFW (Uncomplicated Firewall)
- Automatically installs UFW if missing

### RHEL Family
- Uses firewalld
- Automatically installs firewalld if missing

### Arch Linux
- Uses iptables
- Automatically installs iptables if missing

### SUSE Family
- Uses SuSEfirewall2
- Automatically installs SuSEfirewall2 if missing

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

- **Ogbeh** - [GitHub](https://github.com/ogbeh)

## Acknowledgments

- Thanks to all contributors who have helped improve this tool
- Inspired by the need for quick security assessments on Linux systems