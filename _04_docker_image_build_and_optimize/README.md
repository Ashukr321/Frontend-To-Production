# 📁 Step 04: Docker Image Build & Optimization

> **Goal:** Learn multi-stage Docker builds to create optimized, production-ready Docker images for React applications (from ~1GB to ~25MB).

---

## 📋 What You'll Learn

- Single-stage vs multi-stage builds
- Writing optimized production Dockerfiles
- Docker layer caching strategies
- Image size reduction techniques
- Tagging and versioning best practices

---

## 🤔 Why Optimize Docker Images?

```
Unoptimized Image:                    Optimized Image:
├── Size: ~1.2 GB                     ├── Size: ~25 MB
├── Contains: Node.js, npm,           ├── Contains: Nginx + static files
│   node_modules, source code,        ├── Attack surface: Minimal
│   build tools                       ├── Deploy time: ~5 seconds
├── Attack surface: Large             └── Startup: Instant
├── Deploy time: ~2 minutes
└── Startup: Slow

Why does this matter?
1. Faster deployments (smaller push/pull)
2. Less storage cost (registry + server)
3. Better security (smaller attack surface)
4. Faster scaling (new containers start quicker)
```

---

## 🚀 Step-by-Step Guide

### 1. The Problem with Single-Stage Builds

```dockerfile
# ❌ BAD: Single-stage build (Dockerfile.basic)
FROM node:20-alpine
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npm run build

# Includes Node.js, npm, node_modules, source code
# PLUS the built files — image is ~1.2GB!
CMD ["npx", "serve", "-s", "dist"]
```

### 2. Multi-Stage Build (The Solution)

```dockerfile
# ✅ GOOD: Multi-stage production build (Dockerfile.production)

# ============================================
# Stage 1: BUILD
# Purpose: Install deps, build the React app
# This stage is THROWN AWAY after build
# ============================================
FROM node:20-alpine AS builder

WORKDIR /app

# Copy package files first (layer caching)
COPY package.json package-lock.json ./

# Install dependencies
RUN npm ci

# Copy source code
COPY . .

# Build the production bundle
RUN npm run build
# Output: /app/dist/ (static HTML, CSS, JS files)

# ============================================
# Stage 2: PRODUCTION
# Purpose: Serve the built static files
# Only this stage becomes the final image
# ============================================
FROM nginx:alpine AS production

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built files from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Nginx runs in foreground
CMD ["nginx", "-g", "daemon off;"]
```

### 3. Nginx Configuration for React SPA

Create `nginx.conf`:

```nginx
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Handle React Router (SPA)
    # All routes should serve index.html
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets aggressively
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Don't cache the HTML file
    location = /index.html {
        expires -1;
        add_header Cache-Control "no-store, no-cache, must-revalidate";
    }

    # Enable gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml text/javascript image/svg+xml;
    gzip_min_length 256;
}
```

### 4. Build and Compare Sizes

```bash
# Build the basic (unoptimized) image
docker build -f Dockerfile.basic -t react-app:basic .

# Build the production (optimized) image
docker build -f Dockerfile.production -t react-app:production .

# Compare sizes
docker images | grep react-app

# REPOSITORY    TAG          SIZE
# react-app     basic        1.2GB  ❌
# react-app     production   25MB   ✅
```

### 5. Advanced Optimization Techniques

#### a. Leverage BuildKit Cache Mounts

```dockerfile
# Experimental: cache npm packages across builds
FROM node:20-alpine AS builder
WORKDIR /app
COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci
COPY . .
RUN npm run build
```

#### b. Use Non-Root User (Security)

```dockerfile
FROM nginx:alpine AS production
# Create non-root user
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
COPY --from=builder /app/dist /usr/share/nginx/html
# Change ownership
RUN chown -R appuser:appgroup /usr/share/nginx/html
RUN chown -R appuser:appgroup /var/cache/nginx && \
    chown -R appuser:appgroup /var/log/nginx && \
    chown -R appuser:appgroup /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
    chown -R appuser:appgroup /var/run/nginx.pid
USER appuser
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

#### c. Add Health Check

```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1
```

### 6. Tagging Strategy

```bash
# Semantic versioning
docker build -t my-react-app:1.0.0 .
docker build -t my-react-app:1.0 .
docker build -t my-react-app:latest .

# Git SHA-based (used in CI/CD)
docker build -t my-react-app:$(git rev-parse --short HEAD) .

# Date-based
docker build -t my-react-app:2024-01-15 .

# Environment-based
docker build -t my-react-app:staging .
docker build -t my-react-app:production .
```

### 7. Push to Docker Hub

```bash
# Login to Docker Hub
docker login

# Tag for Docker Hub
docker tag my-react-app:latest yourusername/my-react-app:latest

# Push
docker push yourusername/my-react-app:latest

# Push all tags
docker push yourusername/my-react-app --all-tags
```

---

## 📊 Image Size Comparison Chart

```
┌──────────────────────────────────────────────────────────────┐
│ Image Size Comparison                                        │
│                                                              │
│ node:20 (full)        ████████████████████████████  1.1 GB   │
│ node:20-slim          ██████████████               380 MB    │
│ node:20-alpine        ███████                      180 MB    │
│ Single-stage build    ████████████████████████████  1.2 GB   │
│ Multi-stage (nginx)   █                             25 MB    │
│ Multi-stage (alpine)  █                             22 MB    │
└──────────────────────────────────────────────────────────────┘
```

---

## 🔄 Alternative Approaches

| Approach | When to Use |
|----------|-------------|
| **Multi-stage + Nginx** ⭐ | Production React apps (recommended) |
| **Multi-stage + Caddy** | Want automatic HTTPS in the container |
| **Static hosting (S3/CloudFront)** | Serverless, no container needed |
| **Vercel/Netlify** | Don't want to deal with Docker at all |
| **Distroless images** | Ultra-minimal, maximum security |

---

## 🏢 Company Approach vs Individual Developer

### Individual Developer
```
- Single Dockerfile
- Push to Docker Hub (free tier, 1 private repo)
- Manual tagging (latest, v1.0)
```

### Company / Enterprise
```
- Multi-stage Dockerfiles, reviewed like code
- Private registry (ECR, GCR, GHCR)
- Automated builds in CI pipeline
- Security scanning (Trivy, Snyk) on every image
- Base image governance (approved base images only)
- Image signing (Cosign, Notary)
- Size budgets enforced in CI
- Automated vulnerability patching
```

---

## 🧠 Senior Developer Mindset

1. **Think in stages** — Build stage has everything; production stage has only what's needed to RUN.
2. **Image size is a feature** — Smaller images deploy faster, scale faster, and have less attack surface.
3. **Pin EVERYTHING** — Base images, npm versions, even Alpine package versions.
4. **Security scanning in CI** — Scan every image before it reaches production.
5. **Layer ordering matters** — Most stable layers first, most volatile last.

---

## ✅ Checkpoint

After completing this step, you should be able to:
- [ ] Explain why multi-stage builds are better
- [ ] Build a production Docker image under 30MB
- [ ] Configure Nginx inside Docker for React SPA
- [ ] Tag and push images to Docker Hub
- [ ] Understand layer caching and optimization
