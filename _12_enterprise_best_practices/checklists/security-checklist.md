# ============================================
# Security Hardening Checklist
# ============================================

## Application Level
- [ ] Content Security Policy (CSP) headers
- [ ] HTTPS enforced everywhere (HSTS)
- [ ] XSS protection headers (X-XSS-Protection)
- [ ] Clickjacking protection (X-Frame-Options)
- [ ] MIME sniffing prevention (X-Content-Type-Options)
- [ ] No secrets in frontend env variables
- [ ] API keys proxied through backend
- [ ] npm audit — no critical vulnerabilities
- [ ] Subresource Integrity for CDN resources

## Server Level
- [ ] SSH key authentication only
- [ ] Root login disabled
- [ ] Firewall active (UFW) — only 22, 80, 443
- [ ] fail2ban installed and running
- [ ] Automatic security updates enabled
- [ ] Docker runs as non-root
- [ ] Docker images scanned (Trivy)
- [ ] Nginx rate limiting configured

## CI/CD Level
- [ ] Branch protection on main
- [ ] Required PR reviews
- [ ] Automated tests before merge
- [ ] npm audit in CI pipeline
- [ ] Secrets in GitHub Secrets only
- [ ] Dependabot enabled
- [ ] Signed commits (GPG) — optional

## Performance
- [ ] Gzip enabled in Nginx
- [ ] Static assets cached (1 year, immutable)
- [ ] index.html not cached
- [ ] Code splitting / lazy loading
- [ ] Images optimized (WebP)
- [ ] Core Web Vitals passing
- [ ] Bundle size < 200KB (initial load)
