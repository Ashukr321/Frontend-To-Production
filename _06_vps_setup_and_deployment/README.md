# 📁 Step 06: VPS Setup & Deployment

> **Goal:** Set up a Virtual Private Server (VPS), configure it securely, install Docker, and deploy your containerized React application to the internet.

---

## 📋 What You'll Learn

- Choosing a VPS provider
- Initial server setup and security hardening
- SSH key authentication
- Installing Docker on a Linux server
- Manual deployment of Docker containers
- Server security best practices

---

## 🤔 Why a VPS?

```
Platform Comparison:
┌─────────────────┬──────────┬─────────┬──────────┬───────────┐
│ Feature         │ VPS      │ Vercel  │ AWS EC2  │ Shared    │
├─────────────────┼──────────┼─────────┼──────────┼───────────┤
│ Control         │ Full     │ Low     │ Full     │ Minimal   │
│ Cost/month      │ $5-20    │ Free+   │ $10+     │ $3-10     │
│ Docker Support  │ ✅       │ ❌      │ ✅       │ ❌        │
│ Custom Backend  │ ✅       │ Partial │ ✅       │ Limited   │
│ Learning Value  │ High     │ Low     │ Very High│ Low       │
│ Setup Time      │ 30 min   │ 5 min   │ 1 hour   │ 10 min   │
│ Scalability     │ Manual   │ Auto    │ Auto     │ None      │
└─────────────────┴──────────┴─────────┴──────────┴───────────┘
```

---

## 🚀 Step-by-Step Guide

### 1. Choose a VPS Provider

| Provider | Price | Recommendation |
|----------|-------|----------------|
| **DigitalOcean** | $4/mo | Best for beginners (great docs) |
| **Hetzner** | €3.49/mo | Best value for money |
| **Linode (Akamai)** | $5/mo | Reliable, good performance |
| **Vultr** | $2.50/mo | Cheapest option |
| **AWS Lightsail** | $3.50/mo | If you want to stay in AWS |

**Recommended specs for a React app:**
- **OS:** Ubuntu 22.04 LTS
- **CPU:** 1 vCPU
- **RAM:** 1-2 GB
- **Storage:** 25 GB SSD
- **Cost:** ~$5/month

### 2. Initial Server Setup

```bash
# ── Step 1: SSH into your server ──
ssh root@YOUR_SERVER_IP

# ── Step 2: Update system packages ──
apt update && apt upgrade -y

# ── Step 3: Create a non-root user ──
adduser deploy
usermod -aG sudo deploy

# ── Step 4: Set up SSH key for new user ──
# On YOUR LOCAL MACHINE:
ssh-keygen -t ed25519 -C "your-email@example.com"
ssh-copy-id deploy@YOUR_SERVER_IP

# ── Step 5: Test SSH with new user ──
ssh deploy@YOUR_SERVER_IP

# ── Step 6: Disable root login & password auth ──
sudo nano /etc/ssh/sshd_config
# Change these lines:
#   PermitRootLogin no
#   PasswordAuthentication no
#   PubkeyAuthentication yes

sudo systemctl restart sshd
```

### 3. Configure Firewall (UFW)

```bash
# Enable UFW firewall
sudo ufw default deny incoming
sudo ufw default allow outgoing

# Allow SSH (IMPORTANT: do this before enabling!)
sudo ufw allow OpenSSH
# OR if using custom SSH port:
# sudo ufw allow 2222/tcp

# Allow HTTP and HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Enable firewall
sudo ufw enable

# Check status
sudo ufw status
```

### 4. Install Docker on VPS

```bash
# Install Docker using official script
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Add your user to docker group (avoid using sudo for docker)
sudo usermod -aG docker deploy

# Log out and back in for group changes to take effect
exit
ssh deploy@YOUR_SERVER_IP

# Verify Docker installation
docker --version
docker run hello-world

# Install Docker Compose plugin
sudo apt install docker-compose-plugin

# Verify
docker compose version
```

### 5. Deploy Your React App

```bash
# ── Option A: Build locally, push to registry, pull on server ──

# On your LOCAL machine:
docker build -t yourusername/react-app:latest .
docker push yourusername/react-app:latest

# On your SERVER:
docker pull yourusername/react-app:latest
docker run -d -p 80:80 --name react-app --restart unless-stopped yourusername/react-app:latest

# ── Option B: Clone repo and build on server ──

# On your SERVER:
git clone https://github.com/yourusername/your-repo.git
cd your-repo
docker build -t react-app:latest .
docker run -d -p 80:80 --name react-app --restart unless-stopped react-app:latest
```

### 6. Deployment Script (`scripts/deploy.sh`)

```bash
#!/bin/bash
# ============================================
# Simple Deployment Script
# Run on VPS: bash deploy.sh
# ============================================

set -e  # Exit on error

APP_NAME="react-app"
IMAGE_NAME="yourusername/react-app"
PORT="80:80"

echo "🚀 Starting deployment..."

# Pull latest image
echo "📥 Pulling latest image..."
docker pull $IMAGE_NAME:latest

# Stop and remove existing container
echo "🛑 Stopping existing container..."
docker stop $APP_NAME 2>/dev/null || true
docker rm $APP_NAME 2>/dev/null || true

# Start new container
echo "▶️  Starting new container..."
docker run -d \
  --name $APP_NAME \
  --restart unless-stopped \
  -p $PORT \
  $IMAGE_NAME:latest

# Clean up old images
echo "🧹 Cleaning up old images..."
docker image prune -f

echo "✅ Deployment complete!"
echo "🌐 App is running at http://$(curl -s ifconfig.me)"
```

### 7. Server Monitoring Basics

```bash
# Check system resources
htop                    # Interactive process viewer
df -h                   # Disk usage
free -h                 # Memory usage

# Check Docker status
docker ps               # Running containers
docker stats            # Resource usage per container
docker logs react-app   # Container logs

# Set up fail2ban (protects against brute force)
sudo apt install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

---

## 🔒 Security Checklist

```
✅ SSH key authentication (no passwords)
✅ Root login disabled
✅ Firewall enabled (UFW)
✅ Only necessary ports open (22, 80, 443)
✅ Non-root user for daily operations
✅ fail2ban installed
✅ Automatic security updates enabled
✅ Docker runs as non-root user
```

Enable automatic security updates:
```bash
sudo apt install unattended-upgrades -y
sudo dpkg-reconfigure -plow unattended-upgrades
```

---

## 🔄 Alternative Approaches

| Approach | When to Use |
|----------|-------------|
| **VPS (manual)** ⭐ | Learning, small projects, full control |
| **Vercel/Netlify** | Simple frontend, no backend needed |
| **Railway/Render** | Full-stack, don't want to manage servers |
| **AWS ECS** | Container orchestration on AWS |
| **Kubernetes** | Large-scale, multiple services |
| **CapRover** | PaaS on your own VPS (Heroku-like) |
| **Coolify** | Self-hosted PaaS alternative |

---

## 🏢 Company vs Individual

### Individual Developer
```
- Single $5 VPS
- Manual SSH deployment
- Basic firewall + fail2ban
- Manual monitoring (htop, docker stats)
```

### Enterprise
```
- Infrastructure as Code (Terraform)
- Configuration management (Ansible)
- Private VPC networking
- Load balancers
- Auto-scaling groups
- Centralized log management
- 24/7 monitoring and alerting
- Incident response procedures
- Disaster recovery plan
- Regular security audits
```

---

## 🧠 Senior Developer Mindset

1. **Automate server setup** — If you can't reproduce your server from scratch in 10 minutes, automate it.
2. **Security is not optional** — Every public server gets attacked. Prepare accordingly.
3. **Use `--restart unless-stopped`** — Your containers should survive server reboots.
4. **Monitor before you need to** — Set up monitoring before your first user, not after your first outage.
5. **Keep deployment scripts in Git** — Your deployment process is code. Version control it.
6. **Document everything** — Future you (or your teammate) will thank you.

---

## ✅ Checkpoint

- [ ] VPS created and SSH access working
- [ ] Non-root user configured
- [ ] Firewall enabled with correct rules
- [ ] Docker installed and running
- [ ] React app deployed and accessible via IP address
- [ ] Basic security hardening completed
