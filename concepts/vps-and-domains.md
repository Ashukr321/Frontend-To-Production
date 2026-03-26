# 🌐 VPS & Domains — Concepts & Resources

## What is a VPS?

A **VPS (Virtual Private Server)** is a virtual machine you rent from a hosting provider. It gives you full root access to a Linux server where you can install anything — Docker, Nginx, databases, etc.

### How VPS Works
```
Physical Server (Provider's Data Center)
├── VPS 1 (Your server) — 2 CPU, 4GB RAM, 80GB SSD
├── VPS 2 (Someone else's) — 4 CPU, 8GB RAM, 160GB SSD
├── VPS 3 (Someone else's) — 1 CPU, 2GB RAM, 40GB SSD
└── ... (Many more VPS instances)

Each VPS is isolated using virtualization (KVM, Xen, etc.)
```

### VPS vs Other Hosting Options

| Type | Control | Cost | Complexity | Best For |
|------|---------|------|------------|----------|
| **Shared Hosting** | Low | $3-10/mo | Easy | WordPress, simple sites |
| **VPS** | High | $5-40/mo | Medium | Full-stack apps, Docker |
| **Dedicated Server** | Full | $50-500/mo | High | High-traffic, compliance |
| **PaaS (Vercel, Railway)** | Low | Free-$20/mo | Easy | Quick deployments |
| **Cloud (AWS, GCP, Azure)** | Full | Pay-as-you-go | High | Enterprise, scalable apps |

---

## 🔑 Key Concepts

### VPS Concepts

| Concept | Description |
|---------|-------------|
| **SSH** | Secure Shell — encrypted connection to your server |
| **Root Access** | Full admin privileges on the server |
| **Firewall (UFW)** | Controls which ports accept traffic |
| **systemd** | Linux service manager (start, stop, restart services) |
| **cron** | Scheduled task runner on Linux |

### Domain & DNS Concepts

| Concept | Description |
|---------|-------------|
| **Domain Name** | Human-readable address (e.g., `yourapp.com`) |
| **DNS** | Domain Name System — translates domain to IP address |
| **A Record** | Maps domain to IPv4 address |
| **AAAA Record** | Maps domain to IPv6 address |
| **CNAME Record** | Maps domain to another domain (alias) |
| **MX Record** | Maps domain to mail server |
| **TXT Record** | Stores text data (used for verification, SPF, DKIM) |
| **NS Record** | Specifies nameservers for the domain |
| **TTL** | Time to Live — how long DNS records are cached |
| **Propagation** | Time for DNS changes to spread globally (minutes to 48 hours) |

### How DNS Resolution Works
```
User types: yourapp.com
       │
       ▼
Browser Cache → OS Cache → Router Cache → ISP DNS
       │ (miss)
       ▼
Root DNS Server (.com)
       │
       ▼
TLD DNS Server (yourapp.com → Cloudflare NS)
       │
       ▼
Authoritative DNS (Cloudflare)
       │
       ▼
A Record: yourapp.com → 165.22.X.X (Your VPS IP)
       │
       ▼
Browser connects to 165.22.X.X:443 (HTTPS)
```

---

## 📖 Official Documentation

| Resource | Link |
|----------|------|
| DigitalOcean Docs | https://docs.digitalocean.com |
| AWS EC2 Docs | https://docs.aws.amazon.com/ec2/ |
| Hetzner Docs | https://docs.hetzner.com |
| Cloudflare DNS | https://developers.cloudflare.com/dns/ |
| Namecheap DNS Guide | https://www.namecheap.com/support/knowledgebase/ |

---

## 🆓 Free Resources & Cheap VPS Providers

### Free Tier VPS Options

| Provider | Free Tier | Limitations |
|----------|-----------|-------------|
| **Oracle Cloud** | 2 VMs, 1GB RAM each | Always Free |
| **AWS EC2** | t2.micro, 750 hrs/mo | 12 months |
| **Google Cloud** | e2-micro | Always Free (limited) |
| **Azure** | B1s, 750 hrs/mo | 12 months |

### Affordable VPS Providers

| Provider | Starting Price | Best For |
|----------|---------------|----------|
| **Hetzner** | €3.49/mo | Best value in Europe |
| **DigitalOcean** | $4/mo | Beginner-friendly, great docs |
| **Linode (Akamai)** | $5/mo | Reliable, good performance |
| **Vultr** | $2.50/mo | Cheapest option |
| **Contabo** | €4.99/mo | High specs for price |

### Free Domain Options

| Provider | Notes |
|----------|-------|
| **Freenom** | .tk, .ml, .ga domains (limited availability) |
| **GitHub Pages** | username.github.io |
| **Netlify** | yourapp.netlify.app |
| **Vercel** | yourapp.vercel.app |

---

## 🔄 Alternative Approaches

### Instead of VPS + Manual Setup

| Approach | Pros | Cons | Cost |
|----------|------|------|------|
| **Vercel** | Zero-config React deploys, automatic SSL | No backend control | Free tier available |
| **Netlify** | JAMstack focused, form handling | Limited server-side | Free tier available |
| **Railway** | Full-stack, Docker support | Newer platform | $5/mo + usage |
| **Render** | Auto-deploy from GitHub | Cold starts on free tier | Free tier available |
| **Fly.io** | Edge deployment, Docker-based | Learning curve | Free tier available |
| **AWS Amplify** | Full AWS integration | AWS complexity | Pay-as-you-go |

---

## 🏢 Company Approach vs Individual Developer

### Individual Developer
```
- Single VPS ($5-10/mo)
- One domain ($10-15/year)
- Cloudflare for DNS (free)
- Manual server setup
- SSH key authentication
```

### Company / Enterprise
```
- Cloud infrastructure (AWS, GCP, Azure)
- Infrastructure as Code (Terraform, Pulumi)
- Multiple environments on separate servers/clusters
- Load balancers for high availability
- Auto-scaling groups
- Private networking (VPC)
- Domain managed through enterprise registrar
- DNS managed through Route53/Cloudflare Enterprise
- DDoS protection
- Compliance certifications (SOC2, HIPAA, etc.)
```

---

## 🧠 Senior Developer Mindset

1. **Start with PaaS, graduate to VPS** — Don't over-engineer. Use Vercel/Netlify for simple projects. Move to VPS when you need more control.
2. **Automate server setup** — Use scripts or tools like Ansible to make server setup reproducible.
3. **Always use SSH keys, never passwords** — Disable password authentication on your VPS.
4. **Use Cloudflare in front** — Free DDoS protection, CDN, and DNS management.
5. **Monitor your server** — Set up alerts for CPU, memory, and disk usage.
6. **Keep your server updated** — Run `apt update && apt upgrade` regularly. Automate with `unattended-upgrades`.
7. **Plan for failure** — What happens if your VPS goes down? Have backups and a recovery plan.
