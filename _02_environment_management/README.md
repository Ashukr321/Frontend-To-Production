# 📁 Step 02: Environment Management

> **Goal:** Learn how to manage environment variables across development, staging, and production environments in a React (Vite) application.

---

## 📋 What You'll Learn

- How `.env` files work in Vite
- Build-time vs runtime environment variables
- Managing secrets safely
- Environment-specific configurations
- Validating environment variables

---

## 🤔 Why Do We Need This?

```
Without Environment Management:
❌ API keys hardcoded in source code
❌ Same config for dev and prod (calling production API during development)
❌ Secrets pushed to Git (exposed to the world)
❌ Changing config requires code changes and redeployment

With Environment Management:
✅ Secrets stay out of source code
✅ Each environment has its own configuration
✅ Safe development (hitting dev API, not production)
✅ Config changes without code changes
```

---

## 🚀 Step-by-Step Guide

### 1. Understanding Vite Environment Files

Vite loads environment files in a specific order of priority:

```
.env                  # Always loaded
.env.local            # Always loaded, git-ignored
.env.[mode]           # Loaded for specific mode (development, production)
.env.[mode].local     # Loaded for specific mode, git-ignored

Priority (highest to lowest):
.env.[mode].local > .env.[mode] > .env.local > .env
```

### 2. Create Environment Files

#### `.env` (shared, non-sensitive defaults)
```env
# App Configuration
VITE_APP_TITLE=My React App
VITE_APP_VERSION=1.0.0
```

#### `.env.development` (development-specific)
```env
# Development API
VITE_API_URL=http://localhost:3001/api
VITE_API_TIMEOUT=30000

# Feature Flags
VITE_ENABLE_DEBUG=true
VITE_ENABLE_MOCK_DATA=true

# Analytics (disabled in dev)
VITE_ANALYTICS_ENABLED=false
```

#### `.env.staging` (staging-specific)
```env
# Staging API
VITE_API_URL=https://staging-api.yourapp.com/api
VITE_API_TIMEOUT=10000

# Feature Flags
VITE_ENABLE_DEBUG=true
VITE_ENABLE_MOCK_DATA=false

# Analytics
VITE_ANALYTICS_ENABLED=true
```

#### `.env.production` (production-specific)
```env
# Production API
VITE_API_URL=https://api.yourapp.com/api
VITE_API_TIMEOUT=5000

# Feature Flags
VITE_ENABLE_DEBUG=false
VITE_ENABLE_MOCK_DATA=false

# Analytics
VITE_ANALYTICS_ENABLED=true
VITE_ANALYTICS_ID=UA-XXXXXXXXX
```

#### `.env.example` (template for developers — COMMIT THIS)
```env
# Copy this file to .env.local and fill in the values
# DO NOT commit .env.local to Git!

VITE_API_URL=http://localhost:3001/api
VITE_API_TIMEOUT=10000
VITE_APP_TITLE=My React App
VITE_ENABLE_DEBUG=true
VITE_ENABLE_MOCK_DATA=true
VITE_ANALYTICS_ENABLED=false
VITE_ANALYTICS_ID=
```

### 3. Accessing Environment Variables in Code

```javascript
// ✅ Correct way in Vite
const apiUrl = import.meta.env.VITE_API_URL;
const appTitle = import.meta.env.VITE_APP_TITLE;
const isDebug = import.meta.env.VITE_ENABLE_DEBUG === 'true';

// ❌ This does NOT work in Vite (CRA syntax)
// const apiUrl = process.env.REACT_APP_API_URL;
```

### 4. Create a Config Module (`src/config.js`)

```javascript
/**
 * Centralized configuration module
 * All environment variables should be accessed through this file
 * This makes it easy to:
 * 1. See all config in one place
 * 2. Add validation
 * 3. Add defaults
 * 4. Refactor env variable names
 */

const config = {
  // API Configuration
  api: {
    baseUrl: import.meta.env.VITE_API_URL || 'http://localhost:3001/api',
    timeout: parseInt(import.meta.env.VITE_API_TIMEOUT || '10000', 10),
  },

  // App Configuration
  app: {
    title: import.meta.env.VITE_APP_TITLE || 'My React App',
    version: import.meta.env.VITE_APP_VERSION || '0.0.0',
  },

  // Feature Flags
  features: {
    debug: import.meta.env.VITE_ENABLE_DEBUG === 'true',
    mockData: import.meta.env.VITE_ENABLE_MOCK_DATA === 'true',
  },

  // Analytics
  analytics: {
    enabled: import.meta.env.VITE_ANALYTICS_ENABLED === 'true',
    id: import.meta.env.VITE_ANALYTICS_ID || '',
  },

  // Environment info
  isDevelopment: import.meta.env.DEV,
  isProduction: import.meta.env.PROD,
  mode: import.meta.env.MODE,
};

// Validate required config in production
if (config.isProduction) {
  const required = ['api.baseUrl'];
  required.forEach((key) => {
    const value = key.split('.').reduce((obj, k) => obj?.[k], config);
    if (!value) {
      throw new Error(`Missing required config: ${key}`);
    }
  });
}

export default config;
```

### 5. Usage in Components

```jsx
import config from '@/config';

function ApiStatus() {
  return (
    <div>
      <p>API: {config.api.baseUrl}</p>
      <p>Environment: {config.mode}</p>
      {config.features.debug && <DebugPanel />}
    </div>
  );
}
```

### 6. Running with Different Environments

```bash
# Development (default)
npm run dev
# Uses: .env + .env.development

# Production Build
npm run build
# Uses: .env + .env.production

# Staging Build
npm run build -- --mode staging
# Uses: .env + .env.staging

# Preview production build locally
npm run preview
```

### 7. Update `.gitignore`

```gitignore
# Environment files with secrets
.env.local
.env.*.local
.env.production

# Keep these (no secrets)
# .env
# .env.example
# .env.development (if no secrets)
```

---

## ⚠️ Critical Security Rules

```
┌──────────────────────────────────────────────────────────────┐
│                    SECURITY RULES                            │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  1. NEVER put real secrets in frontend env variables         │
│     (API keys, passwords, tokens)                            │
│                                                              │
│  2. Everything with VITE_ prefix is PUBLIC                   │
│     (visible in browser bundle)                              │
│                                                              │
│  3. Use a backend proxy for sensitive API calls              │
│                                                              │
│  4. ALWAYS add .env*.local to .gitignore                     │
│                                                              │
│  5. Use GitHub Secrets for CI/CD pipeline variables           │
│                                                              │
│  6. Rotate exposed secrets immediately                       │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 🔄 Alternative Approaches

| Approach | When to Use |
|----------|-------------|
| **`.env` files (Vite/CRA)** | Standard approach for most React apps |
| **Window config injection** | When you need runtime config without rebuilding |
| **Feature flag services (LaunchDarkly, Flagsmith)** | When you need runtime feature toggles |
| **Config server** | When config needs to change without redeployment |

### Runtime Config (Window Injection) — Advanced

```html
<!-- index.html -->
<script>
  window.__CONFIG__ = {
    API_URL: '__API_URL_PLACEHOLDER__',
  };
</script>
```

```bash
# At deploy time, replace placeholder with actual value
sed -i 's|__API_URL_PLACEHOLDER__|https://api.yourapp.com|g' dist/index.html
```

This avoids rebuilding the Docker image for each environment!

---

## ✅ Checkpoint

After completing this step, you should be able to:
- [ ] Have `.env`, `.env.development`, `.env.production` files
- [ ] Have a `.env.example` committed to Git
- [ ] Access env variables via `import.meta.env.VITE_*`
- [ ] Have a centralized `config.js` module
- [ ] Understand what NOT to put in frontend env variables
