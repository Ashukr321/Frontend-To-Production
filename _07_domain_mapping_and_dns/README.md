# 📁 Step 07: Domain Mapping & DNS

> **Goal:** Map a custom domain name to your VPS and understand how DNS works.

---

## 📋 What You'll Learn

- How DNS resolution works
- DNS record types (A, CNAME, TXT, MX)
- Purchasing and configuring a domain
- Setting up subdomains
- DNS propagation and troubleshooting

---

## 🤔 Why Custom Domains?

```
Without a domain:
❌ Users access your app via IP: http://165.22.34.123
❌ Hard to remember
❌ No SSL without a domain
❌ Looks unprofessional

With a domain:
✅ https://yourapp.com — professional, memorable
✅ SSL/HTTPS enabled
✅ Subdomains: api.yourapp.com, staging.yourapp.com
✅ Email: hello@yourapp.com
```

---

## 🚀 Step-by-Step Guide

### 1. Purchase a Domain

**Recommended Domain Registrars:**

| Registrar | Price (.com) | DNS Manager | Recommended |
|-----------|-------------|-------------|-------------|
| **Namecheap** | ~$9/year | ✅ Good | For beginners |
| **Cloudflare Registrar** | ~$9/year | ✅ Excellent | Best overall |
| **Google Domains** | ~$12/year | ✅ Good | Google ecosystem |
| **Porkbun** | ~$9/year | ✅ Good | Budget option |
| **GoDaddy** | ~$12/year | ✅ Basic | Avoid (upsells) |

### 2. Point Domain to Your VPS

#### Using Cloudflare (Recommended)

```
Step 1: Sign up at cloudflare.com (free)
Step 2: Add your domain to Cloudflare
Step 3: Change nameservers at your registrar to Cloudflare's NS
Step 4: Add DNS records in Cloudflare dashboard
```

#### DNS Records to Add

```
┌──────────┬──────────────────┬─────────────────┬───────┐
│ Type     │ Name             │ Content         │ TTL   │
├──────────┼──────────────────┼─────────────────┼───────┤
│ A        │ @                │ YOUR_VPS_IP     │ Auto  │
│ A        │ www              │ YOUR_VPS_IP     │ Auto  │
│ A        │ api              │ YOUR_VPS_IP     │ Auto  │
│ A        │ staging          │ YOUR_VPS_IP     │ Auto  │
│ CNAME    │ www              │ yourapp.com     │ Auto  │
└──────────┴──────────────────┴─────────────────┴───────┘

@ = root domain (yourapp.com)
www = www.yourapp.com
api = api.yourapp.com (for backend)
staging = staging.yourapp.com
```

### 3. DNS Record Types Explained

```
A Record (Address):
  Maps domain → IPv4 address
  yourapp.com → 165.22.34.123

AAAA Record:
  Maps domain → IPv6 address
  yourapp.com → 2001:0db8:85a3::8a2e:0370:7334

CNAME (Canonical Name):
  Maps domain → another domain (alias)
  www.yourapp.com → yourapp.com
  ⚠️ Cannot be set on root domain (@)

MX (Mail Exchange):
  Maps domain → mail server
  yourapp.com → mail.google.com (priority: 10)

TXT (Text):
  Stores text (verification, SPF, DKIM)
  yourapp.com → "v=spf1 include:_spf.google.com ~all"

NS (Name Server):
  Specifies DNS servers for domain
  yourapp.com → ns1.cloudflare.com
```

### 4. How DNS Resolution Works

```
User types: yourapp.com
      │
      ▼
┌─────────────────┐
│  Browser Cache   │ → Found? Return IP immediately
└────────┬────────┘
         │ Not found
         ▼
┌─────────────────┐
│  OS DNS Cache    │ → Found? Return IP
└────────┬────────┘
         │ Not found
         ▼
┌─────────────────┐
│  Router Cache    │ → Found? Return IP
└────────┬────────┘
         │ Not found
         ▼
┌─────────────────┐
│  ISP DNS Server  │ → Found? Return IP
└────────┬────────┘
         │ Not found
         ▼
┌─────────────────┐     ┌──────────────┐
│  Root DNS (.)    │────▶│  .com TLD    │
└─────────────────┘     └──────┬───────┘
                               │
                               ▼
                    ┌──────────────────┐
                    │  Cloudflare NS    │
                    │  (Authoritative)  │
                    │                   │
                    │  A: 165.22.34.123│
                    └──────────────────┘
                               │
                               ▼
                    Browser connects to 165.22.34.123
```

### 5. Verify DNS Configuration

```bash
# Check A record
dig yourapp.com A +short
# Expected: 165.22.34.123

# Check all records
dig yourapp.com ANY

# Check DNS propagation worldwide
# Visit: https://www.whatsmydns.net

# Check from your machine
nslookup yourapp.com

# Trace the full DNS resolution path
dig yourapp.com +trace
```

### 6. DNS Propagation

```
After changing DNS records:

┌──────────────────────────────────────────────────┐
│ DNS Propagation Timeline                          │
├──────────────────────────────────────────────────┤
│                                                   │
│  0-5 min    Some locations see changes             │
│  5-30 min   Most locations updated                 │
│  1-4 hours  Nearly all locations updated           │
│  24-48 hrs  Global propagation complete            │
│                                                   │
│  ⚡ Cloudflare: Usually < 5 minutes               │
│  🐌 Traditional: Can take up to 48 hours           │
│                                                   │
│  Tip: Lower TTL before making changes              │
│       (e.g., 300 seconds = 5 min)                  │
└──────────────────────────────────────────────────┘
```

### 7. Subdomain Strategy for Projects

```
yourapp.com             → Production frontend
www.yourapp.com         → Redirect to yourapp.com
api.yourapp.com         → Backend API
staging.yourapp.com     → Staging environment
admin.yourapp.com       → Admin panel
docs.yourapp.com        → Documentation
status.yourapp.com      → Status page
```

---

## 🔄 Alternative DNS Providers

| Provider | Free Tier | Best For |
|----------|-----------|----------|
| **Cloudflare** ⭐ | Unlimited | Best overall (CDN + DNS + DDoS protection) |
| **AWS Route 53** | No | AWS ecosystem, advanced routing |
| **Google Cloud DNS** | No | Google ecosystem |
| **Namecheap DNS** | Yes | Simple projects |
| **deSEC** | Yes | Privacy-focused, open source |

---

## 🏢 Company vs Individual

### Individual
```
- Single domain from Namecheap/Cloudflare
- Cloudflare free tier for DNS
- Manual DNS management via dashboard
```

### Enterprise
```
- Multiple domains and subdomains
- DNS managed via Infrastructure as Code (Terraform)
- Route 53 with health checks and failover
- Geo-routing (users routed to nearest server)
- DNSSEC enabled for security
- Automated DNS record management
- WAF rules at DNS level (Cloudflare Enterprise)
```

---

## 🧠 Senior Developer Mindset

1. **Use Cloudflare for everything** — Free CDN, DDoS protection, and blazing fast DNS.
2. **Lower TTL before changes** — Set TTL to 300s (5 min) before DNS changes, then increase after verification.
3. **Plan subdomain strategy** — Think about subdomains from the start.
4. **Use CNAME for flexibility** — Point subdomains to another domain for easy migration.
5. **Document your DNS records** — Keep a record of all DNS entries somewhere versioned.

---

## ✅ Checkpoint

- [ ] Domain purchased and configured
- [ ] DNS records pointing to your VPS
- [ ] Domain resolves to your React app
- [ ] Understand A, CNAME, TXT record types
- [ ] Subdomain plan documented
