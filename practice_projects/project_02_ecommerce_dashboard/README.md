# 🟡 Project 02: E-commerce Dashboard — Multi-Container Deployment

> **Difficulty:** Intermediate  
> **Time:** 8-12 hours  
> **Goal:** Build a React dashboard with a backend API, deploy with Docker Compose, and manage multiple environments.

---

## 📋 Requirements

### Application
- [ ] Login page with authentication
- [ ] Dashboard with statistics (charts)
- [ ] Product listing page (CRUD operations)
- [ ] Order management table
- [ ] User profile settings
- [ ] Responsive sidebar navigation
- [ ] API integration with backend

### Backend (Simple Node/Express API)
- [ ] JWT authentication
- [ ] REST API endpoints (products, orders, users)
- [ ] MongoDB or PostgreSQL database
- [ ] Input validation
- [ ] Error handling

### DevOps
- [ ] Docker Compose with 3 services (frontend, backend, database)
- [ ] Multi-stage Docker builds for both frontend and backend
- [ ] Environment management (dev, staging, production)
- [ ] CI/CD with separate build and deploy stages
- [ ] Blue-green deployment (zero downtime)
- [ ] Sentry error tracking
- [ ] Uptime and performance monitoring

---

## 🏗️ Architecture

```
                    GitHub Actions (CI/CD)
                    ├── Build & Test Frontend
                    ├── Build & Test Backend
                    ├── Build Docker Images
                    └── Deploy via SSH
                          │
                          ▼
┌──────────────────────────────────────────────┐
│  VPS (Ubuntu)                                 │
│                                               │
│  Nginx (SSL + Reverse Proxy)                  │
│  ├── dashboard.yourapp.com → frontend:3000   │
│  └── api.yourapp.com → backend:4000          │
│                                               │
│  Docker Compose                               │
│  ├── frontend (React + Nginx) → :3000        │
│  ├── backend (Node.js + Express) → :4000     │
│  └── db (MongoDB/PostgreSQL) → :27017/5432   │
└──────────────────────────────────────────────┘
```

---

## 📁 Suggested Structure

```
ecommerce-dashboard/
├── frontend/
│   ├── src/
│   ├── Dockerfile
│   ├── nginx.conf
│   └── package.json
├── backend/
│   ├── src/
│   ├── Dockerfile
│   └── package.json
├── docker-compose.yml
├── docker-compose.dev.yml
├── .github/workflows/
│   ├── ci.yml
│   └── deploy.yml
├── .env.example
└── README.md
```

---

## 🎯 Learning Goals

After this project, you should be able to:
- [ ] Manage multi-container applications with Docker Compose
- [ ] Handle environment-specific configurations
- [ ] Deploy full-stack applications
- [ ] Set up subdomain routing with Nginx
- [ ] Implement error tracking with Sentry
- [ ] Run zero-downtime deployments
