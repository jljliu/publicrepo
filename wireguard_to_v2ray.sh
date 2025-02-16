#!/bin/bash

SERVICE_FILE="/etc/systemd/system/persistent-ip-rules.service"

# Ensure the script is run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Use sudo." >&2
    exit 1
fi

# Send udp and tcp traffic from wg0 interface to port 12345 using tproxy
iptables -t mangle -A PREROUTING -i wg0 -p udp -j TPROXY --tproxy-mark 0x1/0x1 --on-port 12345
iptables -t mangle -A PREROUTING -i wg0 -p tcp -j TPROXY --tproxy-mark 0x1/0x1 --on-port 12345

# Create the service file with the specified content
cat > "$SERVICE_FILE" <<EOF
[Unit]
Description=Persistent IP Rules
After=network.target

[Service]
Type=oneshot
ExecStart=/sbin/ip rule add fwmark 1 lookup 100 ; /sbin/ip route add local 0.0.0.0/0 dev lo table 100
ExecStop=/sbin/ip rule del fwmark 1 lookup 100 ; /sbin/ip route del local 0.0.0.0/0 dev lo table 100
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd to recognize the new service
systemctl daemon-reload

# Enable the service to start on boot
systemctl enable persistent-ip-rules.service

# Start the service
systemctl start persistent-ip-rules

# Inform the user
echo "Service created and enabled. To start it now, use:"
echo "  systemctl start persistent-ip-rules.service"
