#!/bin/bash
# ============================================
# VPS Initial Setup Script
# Run as root on a fresh Ubuntu 22.04 server
# Usage: bash initial-setup.sh <username>
# ============================================

set -e

USERNAME=${1:-deploy}

echo "🔧 Starting VPS initial setup..."

# Update system
echo "📦 Updating system packages..."
apt update && apt upgrade -y

# Create non-root user
echo "👤 Creating user: $USERNAME"
adduser --disabled-password --gecos "" $USERNAME
usermod -aG sudo $USERNAME
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/$USERNAME

# Copy SSH keys to new user
echo "🔑 Setting up SSH keys..."
mkdir -p /home/$USERNAME/.ssh
cp /root/.ssh/authorized_keys /home/$USERNAME/.ssh/
chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh
chmod 700 /home/$USERNAME/.ssh
chmod 600 /home/$USERNAME/.ssh/authorized_keys

# Configure SSH security
echo "🔒 Hardening SSH..."
sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# Setup firewall
echo "🛡️  Configuring firewall..."
apt install ufw -y
ufw default deny incoming
ufw default allow outgoing
ufw allow OpenSSH
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

# Install fail2ban
echo "🚫 Installing fail2ban..."
apt install fail2ban -y
systemctl enable fail2ban
systemctl start fail2ban

# Install Docker
echo "🐳 Installing Docker..."
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker $USERNAME
apt install docker-compose-plugin -y

# Enable automatic security updates
echo "🔄 Enabling automatic updates..."
apt install unattended-upgrades -y
echo 'Unattended-Upgrade::Automatic-Reboot "false";' >> /etc/apt/apt.conf.d/50unattended-upgrades

# Cleanup
rm -f get-docker.sh

echo ""
echo "✅ VPS setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "User created: $USERNAME"
echo "SSH: ssh $USERNAME@$(curl -s ifconfig.me)"
echo "Docker: $(docker --version)"
echo "Firewall: Active (22, 80, 443 open)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "⚠️  IMPORTANT: Test SSH with new user before logging out!"
echo "    ssh $USERNAME@$(curl -s ifconfig.me)"
