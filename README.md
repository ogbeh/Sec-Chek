# Linux Network Security Checker

A simple and efficient network security assessment tool for Linux systems that provides quick insights into your system's security status.

## Supported Distributions

- Ubuntu
- Debian
- CentOS
- RHEL
- Fedora

## Features

- Distribution-specific firewall status check (UFW for Debian/Ubuntu, firewalld for CentOS/RHEL)
- Common port scanning
- System information gathering
- HTML report generation
- Automatic distribution detection

## Quick Start

### Using curl
```bash
curl -s https://raw.githubusercontent.com/YOUR_USERNAME/network-security-checker/main/install.sh | bash
```

## Manual Installation

1. Clone the repository:
```bash
git clone https://github.com/YOUR_USERNAME/network-security-checker.git
cd network-security-checker
```

2. Make the script executable:
```bash
chmod +x install.sh
```

3. Run the installer:
```bash
./install.sh
```

## Requirements

- Python 3.6 or higher
- sudo privileges (for firewall checks)
- Internet connection (for initial installation)

## Output

The script generates an HTML report (`security_report.html`) containing:
- System information (distribution, version, architecture)
- Firewall status (UFW or firewalld)
- Open ports
- Security recommendations

## Usage

After installation, simply run:
```bash
security-checker
```

The report will be generated in your current directory.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. 