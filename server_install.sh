#!/bin/bash

# Update and upgrade the system
apt-get update && apt-get upgrade -y

# Install necessary packages
apt-get install -y wireguard nano netfilter-persistent iptables-persistent

# Enable IP forwarding
echo "net.ipv4.ip_forward=1" | tee -a /etc/sysctl.conf
sysctl -p /etc/sysctl.conf

# Create WireGuard config file
touch /etc/wireguard/wg0.conf

# Clear out iptables rules
iptables -F       # Flush all rules
iptables -X       # Delete all custom chains
iptables -P INPUT ACCEPT   # Allow all incoming traffic
iptables -P FORWARD ACCEPT # Allow all forwarded traffic
iptables -P OUTPUT ACCEPT  # Allow all outgoing traffic

# Persist iptables rules
netfilter-persistent save

# Verify rules
cat /etc/iptables/rules.v4 

# Install Docker
apt install -y docker.io
systemctl start docker
systemctl enable docker

# Install V2Ray via Docker
docker pull v2fly/v2fly-core
mkdir -p /etc/v2ray/
touch /etc/v2ray/config.json

echo "Setup completed successfully!"
