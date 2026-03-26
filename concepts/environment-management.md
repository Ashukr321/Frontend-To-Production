# 🔐 Environment Management — Concepts & Resources

## What is Environment Management?

Environment management is the practice of configuring your application differently based on where it's running — development, staging, or production.

### The Problem It Solves

Without environment management:
- API keys hardcoded in source code (security risk!)
- Accidentally calling production API during development
- Different team members using different configurations
- Secrets exposed in Git history

With environment management:
- Secrets stay out of source code
- Each environment has appropriate configurations
- Developers can work safely without affecting production
- Configuration changes don't require code changes

---

## 🔑 Key Concepts

| Concept | Description |
|---------|-------------|
| **Environment Variable** | Key-value pair that configures app behavior without code changes |
| **`.env` file** | File containing environment variables (never commit!) |
| **Build-time variable** | Baked into the app during build (e.g., `VITE_API_URL`) |
| **Runtime variable** | Read when the app starts (server-side only) |
| **Secret** | Sensitive data like API keys, passwords, tokens |
| **Config** | Non-sensitive settings like feature flags, URLs |

### Build-time vs Runtime Variables (Frontend)

```
⚠️ CRITICAL FOR FRONTEND DEVELOPERS:

React/Vite apps run in the BROWSER. There is no "runtime" on the client.
All environment variables are baked in at BUILD TIME.

This means:
- VITE_API_URL="https://api.prod.com" → embedded in the JavaScript bundle
- Anyone can see it in browser DevTools → NEVER put secrets here!
- To change an env variable, you must REBUILD the app
```

### Vite Environment Variable Rules

```
✅ VITE_API_URL        → Exposed to frontend (prefixed with VITE_)
✅ VITE_APP_TITLE      → Exposed to frontend
❌ DATABASE_PASSWORD    → NOT exposed (no VITE_ prefix) — server only
❌ SECRET_KEY           → NOT exposed — server only
```

---

## 📖 Official Documentation

| Resource | Link |
|----------|------|
| Vite Env Variables | https://vitejs.dev/guide/env-and-mode |
| Create React App Env | https://create-react-app.dev/docs/adding-custom-environment-variables/ |
| dotenv (Node.js) | https://github.com/motdotla/dotenv |
| Docker Env Variables | https://docs.docker.com/compose/environment-variables/ |
| GitHub Actions Secrets | https://docs.github.com/en/actions/security-guides/encrypted-secrets |

---

## 🆓 Free Resources

| Resource | Link | Type |
|----------|------|------|
| 12-Factor App (Config) | https://12factor.net/config | Best Practices |
| Vite Env Guide | https://vitejs.dev/guide/env-and-mode | Official Guide |
| dotenv Documentation | https://www.dotenv.org/docs | Documentation |

---

## 🔄 Alternative Approaches

| Approach | Pros | Cons | Best For |
|----------|------|------|----------|
| **`.env` files** | Simple, well-supported | Easy to accidentally commit | Small teams, simple projects |
| **Docker env / args** | Container-level isolation | Requires Docker knowledge | Docker-based deployments |
| **CI/CD Secrets** | Secure, centralized | Different per platform | Automated pipelines |
| **AWS Secrets Manager** | Rotation, audit trail | AWS lock-in, cost | Enterprise AWS apps |
| **HashiCorp Vault** | Dynamic secrets, encryption | Complex setup | Enterprise, multi-cloud |
| **Doppler** | Universal secret manager | SaaS dependency | Teams needing simplicity |
| **Infisical** | Open-source Vault alternative | Newer, smaller community | Teams wanting OSS |

---

## 🏢 Company Approach vs Individual Developer

### Individual Developer
```
.env                  → Local development (git-ignored)
.env.production       → Production values (git-ignored)
GitHub Secrets        → CI/CD pipeline secrets
```

### Company / Enterprise
```
- Centralized secret management (Vault, AWS SM)
- Secret rotation policies (90-day rotation)
- Access control — not everyone can see production secrets
- Audit logging — who accessed which secret and when
- Environment promotion — dev → staging → prod config flow
- No secrets in Dockerfiles or docker-compose
- Encrypted at rest and in transit
- Separate AWS accounts per environment
```

---

## 🧠 Senior Developer Mindset

1. **Never commit `.env` files** — Add to `.gitignore` immediately. Create `.env.example` with placeholder values.
2. **Frontend secrets don't exist** — Anything in your React bundle is PUBLIC. Use a backend proxy for API keys.
3. **Use `.env.example`** — Document all required variables with dummy values for new developers.
4. **Validate env variables at startup** — Fail fast if required variables are missing. Use `zod` or custom validation.
5. **Minimize env-specific code** — Use config files that read from env vars, don't scatter `process.env` throughout your codebase.
6. **Use different API endpoints per environment** — `VITE_API_URL=http://localhost:3001` vs `https://api.yourapp.com`.
