#!/usr/bin/env python3
import subprocess
import socket
import platform
import datetime
import os
from typing import List, Dict
import json

class SystemInfo:
    @staticmethod
    def get_distribution() -> str:
        try:
            with open('/etc/os-release', 'r') as f:
                for line in f:
                    if line.startswith('ID='):
                        return line.strip().split('=')[1].strip('"')
        except:
            return "Unknown"
        return "Unknown"

    @staticmethod
    def get_system_info() -> Dict:
        return {
            "distribution": SystemInfo.get_distribution(),
            "os_version": platform.version(),
            "architecture": platform.machine(),
            "processor": platform.processor(),
            "hostname": platform.node()
        }

class FirewallChecker:
    @staticmethod
    def check_firewall() -> Dict:
        dist = SystemInfo.get_distribution().lower()
        if dist in ['ubuntu', 'debian']:
            try:
                result = subprocess.run(['sudo', 'ufw', 'status'], capture_output=True, text=True)
                return {"status": "success", "output": result.stdout, "type": "ufw"}
            except:
                return {"status": "error", "message": "Could not check UFW status"}
        elif dist in ['centos', 'rhel', 'fedora']:
            try:
                result = subprocess.run(['sudo', 'firewall-cmd', '--state'], capture_output=True, text=True)
                return {"status": "success", "output": result.stdout, "type": "firewalld"}
            except:
                return {"status": "error", "message": "Could not check firewalld status"}
        return {"status": "error", "message": "Unsupported distribution"}

class PortScanner:
    @staticmethod
    def scan_ports(ports: List[int] = None) -> Dict:
        if ports is None:
            ports = [21, 22, 23, 25, 53, 80, 443, 3306, 3389]
        
        open_ports = []
        for port in ports:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(1)
            result = sock.connect_ex(('127.0.0.1', port))
            if result == 0:
                open_ports.append(port)
            sock.close()
        
        return {
            "total_ports_scanned": len(ports),
            "open_ports": open_ports,
            "closed_ports": [p for p in ports if p not in open_ports]
        }

class ReportGenerator:
    @staticmethod
    def generate_html_report(data: Dict) -> str:
        return f"""
        <html>
        <head>
            <title>Linux Network Security Report</title>
            <style>
                body {{ font-family: Arial; margin: 40px; }}
                .report {{ background: #f5f5f5; padding: 20px; }}
                .section {{ margin: 20px 0; padding: 15px; background: white; border-radius: 5px; }}
                .error {{ color: red; }}
                .success {{ color: green; }}
                .warning {{ color: orange; }}
            </style>
        </head>
        <body>
            <h1>Linux Network Security Report</h1>
            <div class="report">
                <h2>Generated on: {datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')}</h2>
                
                <div class="section">
                    <h3>System Information</h3>
                    <pre>{json.dumps(data['system_info'], indent=2)}</pre>
                </div>

                <div class="section">
                    <h3>Firewall Status</h3>
                    <p>Firewall Type: {data['firewall']['type']}</p>
                    <pre>{data['firewall']['output']}</pre>
                </div>

                <div class="section">
                    <h3>Port Scan Results</h3>
                    <p>Total ports scanned: {data['ports']['total_ports_scanned']}</p>
                    <p>Open ports: {data['ports']['open_ports']}</p>
                    <p>Closed ports: {data['ports']['closed_ports']}</p>
                </div>
            </div>
        </body>
        </html>
        """

class SecurityChecker:
    def __init__(self):
        self.system_info = SystemInfo()
        self.firewall_checker = FirewallChecker()
        self.port_scanner = PortScanner()
        self.report_generator = ReportGenerator()

    def run_checks(self) -> Dict:
        return {
            "system_info": self.system_info.get_system_info(),
            "firewall": self.firewall_checker.check_firewall(),
            "ports": self.port_scanner.scan_ports()
        }

    def generate_report(self, output_file: str = 'security_report.html'):
        data = self.run_checks()
        html_report = self.report_generator.generate_html_report(data)
        
        with open(output_file, 'w') as f:
            f.write(html_report)
        
        return os.path.abspath(output_file)

if __name__ == "__main__":
    checker = SecurityChecker()
    report_path = checker.generate_report()
    print(f"Report generated: {report_path}") 