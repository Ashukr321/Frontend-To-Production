# 📁 Step 08: Nginx Reverse Proxy & SSL

> **Goal:** Configure Nginx as a reverse proxy, set up SSL/HTTPS with Let's Encrypt, and serve your React app securely with a custom domain.

---

## 📋 What You'll Learn

- Installing and configuring Nginx on VPS
- Setting up Nginx as a reverse proxy for Docker containers
- SSL certificate setup with Let's Encrypt + Certbot
- HTTPS redirect and security headers
- Performance optimization (gzip, caching)

---

## 🤔 Why Nginx + SSL?

```
Without Nginx + SSL:
❌ http://165.22.34.123:3000 — ugly, insecure
❌ Browser shows "Not Secure" warning
❌ No compression, no caching
❌ Can't serve multiple apps on one server

With Nginx + SSL:
✅ https://yourapp.com — professional, secure
✅ Padlock icon in browser
✅ gzip compression (60% smaller transfers)
✅ Multiple apps on one server via reverse proxy
✅ HTTP/2 support (faster page loads)
```

---

## 🚀 Step-by-Step Guide

### 1. Install Nginx on VPS

```bash
# Update packages
sudo apt update

# Install Nginx
sudo apt install nginx -y

# Start and enable
sudo systemctl start nginx
sudo systemctl enable nginx

# Verify — visit http://YOUR_IP in browser
sudo systemctl status nginx
```

### 2. Configure Nginx as Reverse Proxy

```bash
# Remove default config
sudo rm /etc/nginx/sites-enabled/default

# Create your app config
sudo nano /etc/nginx/sites-available/yourapp.com
```

#### Nginx Configuration (HTTP only — before SSL):

```nginx
# /etc/nginx/sites-available/yourapp.com

server {
    listen 80;
    server_name yourapp.com www.yourapp.com;

    # Proxy requests to Docker container
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Enable the config
sudo ln -s /etc/nginx/sites-available/yourapp.com /etc/nginx/sites-enabled/

# Test config syntax
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### 3. Install SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtain SSL certificate
sudo certbot --nginx -d yourapp.com -d www.yourapp.com

# Follow the prompts:
# 1. Enter email address
# 2. Accept terms of service
# 3. Choose to redirect HTTP to HTTPS (recommended)
```

### 4. Final Nginx Config (After SSL — Certbot auto-configures)

```nginx
# /etc/nginx/sites-available/yourapp.com

# HTTP → HTTPS redirect
server {
    listen 80;
    server_name yourapp.com www.yourapp.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS server block
server {
    listen 443 ssl http2;
    server_name yourapp.com www.yourapp.com;

    # SSL certificates (managed by Certbot)
    ssl_certificate /etc/letsencrypt/live/yourapp.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourapp.com/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # ── Security Headers ──
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # ── Gzip Compression ──
    gzip on;
    gzip_vary on;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        application/json
        application/javascript
        text/xml
        application/xml
        text/javascript
        image/svg+xml;
    gzip_min_length 256;

    # ── Reverse Proxy to Docker Container ──
    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # ── API Proxy (if backend is separate) ──
    location /api/ {
        proxy_pass http://localhost:4000/api/;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### 5. Verify SSL Auto-Renewal

```bash
# Test renewal (dry run)
sudo certbot renew --dry-run

# Certbot creates a cron job automatically:
sudo systemctl list-timers | grep certbot

# Manual renewal (if needed)
sudo certbot renew
```

### 6. Multiple Apps on One Server

```nginx
# yourapp.com → React Frontend (port 3000)
server {
    listen 443 ssl http2;
    server_name yourapp.com;
    # ... SSL config ...
    location / {
        proxy_pass http://localhost:3000;
    }
}

# api.yourapp.com → Backend API (port 4000)
server {
    listen 443 ssl http2;
    server_name api.yourapp.com;
    # ... SSL config ...
    location / {
        proxy_pass http://localhost:4000;
    }
}

# staging.yourapp.com → Staging (port 3001)
server {
    listen 443 ssl http2;
    server_name staging.yourapp.com;
    # ... SSL config ...
    location / {
        proxy_pass http://localhost:3001;
    }
}
```

### 7. Architecture Diagram

```
Internet
    │
    ▼
┌──────────────────────────────────────────────────┐
│  VPS (Ubuntu)                                     │
│                                                   │
│  ┌────────────────────────────────────────────┐  │
│  │              Nginx                         │  │
│  │         (Port 80 → 301 → 443)              │  │
│  │         SSL Termination                    │  │
│  │         gzip compression                   │  │
│  │         Security headers                   │  │
│  │                                            │  │
│  │   yourapp.com ──────▶ localhost:3000       │  │
│  │   api.yourapp.com ──▶ localhost:4000       │  │
│  └────────────┬────────────────┬──────────────┘  │
│               │                │                  │
│               ▼                ▼                  │
│  ┌────────────────┐  ┌────────────────────┐     │
│  │  Docker:3000    │  │  Docker:4000       │     │
│  │  React App     │  │  Node.js API       │     │
│  │  (Nginx/static)│  │  (Express)         │     │
│  └────────────────┘  └────────────────────┘     │
└──────────────────────────────────────────────────┘
```

---

## 🔄 Alternative Approaches

| Approach | When to Use |
|----------|-------------|
| **Nginx + Certbot** ⭐ | Standard production setup |
| **Caddy** | Want auto-SSL without Certbot (simpler) |
| **Traefik** | Docker-native, auto-discovery, auto-SSL |
| **Cloudflare Tunnel** | Don't want to expose ports at all |
| **AWS ALB + ACM** | AWS infrastructure, auto-managed SSL |

---

## 🧠 Senior Developer Mindset

1. **SSL is mandatory** — No exceptions. Even for staging.
2. **Security headers cost nothing** — Add them to every config.
3. **Test with SSL Labs** — Aim for an A+ score (https://ssllabs.com/ssltest/).
4. **Modularize Nginx configs** — Use `include` for common patterns.
5. **Monitor certificate expiry** — Auto-renewal can fail silently.
6. **Rate limiting is essential** — Protect your API from abuse.

---

## ✅ Checkpoint

- [ ] Nginx installed and running on VPS
- [ ] Nginx reverse proxying to Docker container
- [ ] SSL certificate installed via Certbot
- [ ] HTTP auto-redirects to HTTPS
- [ ] Security headers configured
- [ ] SSL Labs test: A or A+ rating
