# 📁 Step 01: Local Development Setup

> **Goal:** Set up a production-grade React application from scratch using Vite, with proper tooling, folder structure, and development workflow.

---

## 📋 What You'll Learn

- How to scaffold a React project with Vite
- Production-grade folder structure
- ESLint + Prettier configuration
- Understanding dev vs production builds
- Git workflow setup

---

## 🤔 Why Do We Need This?

A well-structured project from day one:
- **Saves time** — Less refactoring later
- **Enables collaboration** — New devs can onboard quickly
- **Supports scaling** — Easy to add features without chaos
- **Makes deployment easier** — Clean builds, clear entry points

---

## 🚀 Step-by-Step Guide

### 1. Create React App with Vite

```bash
# Create a new Vite + React project
npm create vite@latest my-react-app -- --template react

# Navigate into the project
cd my-react-app

# Install dependencies
npm install
```

#### Why Vite over Create React App (CRA)?
```
CRA (Deprecated):                    Vite:
├── Webpack-based (slow)              ├── ESBuild + Rollup (fast)
├── ~30s cold start                   ├── ~300ms cold start
├── ~10s HMR                          ├── Instant HMR
├── Large bundle size                 ├── Optimized tree-shaking
├── No longer maintained              ├── Actively maintained
└── Inflexible config                 └── Easy to configure
```

### 2. Production-Grade Folder Structure

```
my-react-app/
├── public/                     # Static assets (served as-is)
│   ├── favicon.ico
│   └── robots.txt
├── src/
│   ├── assets/                 # Images, fonts, svgs
│   │   ├── images/
│   │   ├── fonts/
│   │   └── icons/
│   ├── components/             # Reusable UI components
│   │   ├── common/             # Button, Input, Modal, etc.
│   │   ├── layout/             # Header, Footer, Sidebar
│   │   └── ui/                 # App-specific components
│   ├── pages/                  # Page-level components
│   │   ├── Home/
│   │   ├── About/
│   │   └── Dashboard/
│   ├── hooks/                  # Custom React hooks
│   ├── context/                # React Context providers
│   ├── services/               # API calls, external services
│   │   └── api.js
│   ├── utils/                  # Utility/helper functions
│   ├── constants/              # App-wide constants
│   ├── styles/                 # Global styles
│   │   ├── globals.css
│   │   └── variables.css
│   ├── routes/                 # Route definitions
│   │   └── index.jsx
│   ├── App.jsx                 # Root component
│   ├── main.jsx                # Entry point
│   └── config.js               # App configuration
├── .env.example                # Example env file
├── .eslintrc.cjs               # ESLint config
├── .prettierrc                 # Prettier config
├── .gitignore                  # Git ignore rules
├── index.html                  # HTML entry point
├── package.json
├── vite.config.js              # Vite configuration
└── README.md
```

### 3. Install Development Dependencies

```bash
# ESLint + Prettier
npm install -D eslint prettier eslint-config-prettier eslint-plugin-react eslint-plugin-react-hooks

# Optional but recommended
npm install -D @types/node
```

### 4. ESLint Configuration (`.eslintrc.cjs`)

```javascript
module.exports = {
  root: true,
  env: { browser: true, es2020: true },
  extends: [
    'eslint:recommended',
    'plugin:react/recommended',
    'plugin:react/jsx-runtime',
    'plugin:react-hooks/recommended',
    'prettier',
  ],
  parserOptions: { ecmaVersion: 'latest', sourceType: 'module' },
  settings: { react: { version: 'detect' } },
  rules: {
    'react/prop-types': 'off',
    'no-unused-vars': 'warn',
    'no-console': 'warn',
  },
};
```

### 5. Prettier Configuration (`.prettierrc`)

```json
{
  "semi": true,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 100,
  "bracketSpacing": true
}
```

### 6. Git Ignore (`.gitignore`)

```gitignore
# dependencies
node_modules/

# production build
dist/

# environment files
.env
.env.local
.env.production

# editor
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db

# debug logs
npm-debug.log*
```

### 7. Scripts in `package.json`

```json
{
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "lint": "eslint . --ext js,jsx --report-unused-disable-directives --max-warnings 0",
    "format": "prettier --write \"src/**/*.{js,jsx,css,md}\""
  }
}
```

---

## 🔍 Understanding Dev vs Production Builds

```
Development (npm run dev):
├── No bundling — files served individually via ESBuild
├── Source maps enabled — easy debugging
├── HMR (Hot Module Replacement) — instant updates
├── Console logs visible
├── Environment: .env.development
└── Output: none (served from memory)

Production (npm run build):
├── Full bundling via Rollup — optimized output
├── Tree-shaking — removes unused code
├── Minification — smaller file sizes
├── Code splitting — lazy-loaded chunks
├── Asset hashing — cache busting (app-a1b2c3.js)
├── CSS extraction — separate CSS files
├── Environment: .env.production
└── Output: dist/ folder (static files)
```

---

## 🔄 Alternative Approaches

| Tool | Use When |
|------|----------|
| **Vite** ⭐ | Default choice for new React projects |
| **Next.js** | Need SSR, SSG, or full-stack framework |
| **Remix** | Need nested routes and form handling |
| **Parcel** | Want zero-config bundling |
| **Webpack** | Legacy projects or need deep customization |
| **Turbopack** | Next.js development (still in beta) |

---

## 🧠 Senior Developer Mindset

1. **Folder structure should reflect features, not file types** — Consider grouping by feature (pages/Dashboard/components, pages/Dashboard/hooks) instead of type (all hooks in /hooks).
2. **Absolute imports from day one** — Configure `vite.config.js` to use `@/` aliases. Avoids `../../../../` hell.
3. **Linting is non-negotiable** — If it doesn't lint, it doesn't merge.
4. **Create conventions early** — Naming, file structure, export patterns. Document them.
5. **Start with TypeScript** — The earlier you adopt it, the easier. But JavaScript is fine for learning.

---

## ✅ Checkpoint

After completing this step, you should be able to:
- [ ] Run `npm run dev` and see your React app
- [ ] Run `npm run build` and see the `dist/` folder
- [ ] Understand the difference between dev and production builds
- [ ] Have ESLint and Prettier configured
- [ ] Have a clean, organized folder structure
