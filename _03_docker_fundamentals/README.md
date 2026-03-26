# 📁 Step 03: Docker Fundamentals

> **Goal:** Understand Docker basics and containerize your React application for the first time.

---

## 📋 What You'll Learn

- Docker architecture (images, containers, layers)
- Writing your first Dockerfile
- Building and running Docker images
- Essential Docker commands
- Using `.dockerignore`

---

## 🤔 Why Docker for Frontend?

```
Without Docker:
❌ "Works on my machine" — different Node versions, OS, dependencies
❌ Manual server setup — install Node, npm, configure Nginx...
❌ Inconsistent environments — dev ≠ staging ≠ production
❌ Difficult onboarding — new dev needs hours to set up

With Docker:
✅ Same environment everywhere — dev, CI, production
✅ One command to run — docker run and it works
✅ Version-controlled infrastructure — Dockerfile IS your setup docs
✅ Instant onboarding — docker compose up and start coding
```

---

## 🚀 Step-by-Step Guide

### 1. Install Docker

```bash
# Check if Docker is installed
docker --version

# If not, download Docker Desktop from:
# https://www.docker.com/products/docker-desktop/
```

### 2. Docker Architecture Overview

```
┌──────────────────────────────────────────────────┐
│                  Your Machine                     │
│                                                   │
│  ┌─────────────┐     ┌──────────────────────┐   │
│  │  Dockerfile  │────▶│    Docker Image       │   │
│  │  (recipe)    │     │  (frozen snapshot)    │   │
│  └─────────────┘     └──────────┬───────────┘   │
│                                  │                │
│                        docker run│                │
│                                  ▼                │
│                       ┌──────────────────────┐   │
│                       │   Docker Container   │   │
│                       │  (running instance)  │   │
│                       │                      │   │
│                       │  Node.js + React App │   │
│                       │  Listening on :3000  │   │
│                       └──────────────────────┘   │
└──────────────────────────────────────────────────┘
```

### 3. Your First Dockerfile

Create a `Dockerfile` in your React project root:

```dockerfile
# ============================================
# Dockerfile for React App (Basic Version)
# ============================================

# Step 1: Use Node.js as the base image
# node:20-alpine is a lightweight version (~180MB vs ~1GB)
FROM node:20-alpine

# Step 2: Set the working directory inside the container
WORKDIR /app

# Step 3: Copy package files first (for better caching)
# Docker caches each layer. If package.json hasn't changed,
# npm install will be cached (saves minutes on rebuilds!)
COPY package.json package-lock.json ./

# Step 4: Install dependencies
RUN npm ci
# npm ci is better than npm install for Docker:
# - Uses exact versions from package-lock.json
# - Faster, cleaner installation
# - Fails if lock file doesn't match package.json

# Step 5: Copy the rest of the source code
COPY . .

# Step 6: Expose the port Vite dev server uses
EXPOSE 5173

# Step 7: Start the development server
CMD ["npm", "run", "dev", "--", "--host"]
# --host flag makes Vite accessible from outside the container
```

### 4. Create `.dockerignore`

```dockerignore
# Dependencies (will be installed inside container)
node_modules

# Build output
dist

# Git
.git
.gitignore

# IDE
.vscode
.idea

# OS
.DS_Store
Thumbs.db

# Docker
Dockerfile
docker-compose*.yml
.dockerignore

# Environment files with secrets
.env.local
.env.*.local

# Documentation
README.md
*.md

# Tests (if not needed in container)
# __tests__
# *.test.js
# *.spec.js
```

### 5. Build the Docker Image

```bash
# Build the image
# -t = tag (name) the image
# . = build context (current directory)
docker build -t my-react-app .

# Build with a specific tag
docker build -t my-react-app:v1.0 .
```

#### What Happens During Build:
```
Step 1/7: FROM node:20-alpine
  → Downloads Node.js Alpine image (if not cached)

Step 2/7: WORKDIR /app
  → Creates /app directory inside the image

Step 3/7: COPY package.json package-lock.json ./
  → Copies only package files (Layer 1)

Step 4/7: RUN npm ci
  → Installs all dependencies (Layer 2 — cached if package.json unchanged!)

Step 5/7: COPY . .
  → Copies all source code (Layer 3)

Step 6/7: EXPOSE 5173
  → Documents the port (metadata only)

Step 7/7: CMD ["npm", "run", "dev", "--", "--host"]
  → Sets the default start command
```

### 6. Run the Container

```bash
# Run the container
# -d = detached mode (runs in background)
# -p 5173:5173 = map host port to container port
# --name = give the container a name
docker run -d -p 5173:5173 --name react-dev my-react-app

# Now visit http://localhost:5173 in your browser!
```

### 7. Essential Docker Commands

```bash
# ── IMAGE COMMANDS ──
docker images                      # List all images
docker build -t name:tag .         # Build an image
docker rmi image_name              # Remove an image
docker image prune                 # Remove unused images

# ── CONTAINER COMMANDS ──
docker ps                          # List running containers
docker ps -a                       # List ALL containers (including stopped)
docker run -d -p 3000:3000 image   # Run a container
docker stop container_name         # Stop a container
docker start container_name        # Start a stopped container
docker rm container_name           # Remove a container
docker logs container_name         # View container logs
docker logs -f container_name      # Follow (tail) logs

# ── DEBUGGING COMMANDS ──
docker exec -it container_name sh  # Shell into container
docker inspect container_name      # View container details
docker stats                       # Resource usage (CPU, RAM)

# ── CLEANUP COMMANDS ──
docker system prune                # Remove all unused data
docker system prune -a             # Remove everything unused
```

---

## 🔍 Understanding Docker Layers & Caching

```
Dockerfile:                         Rebuild Time:
──────────────────────────────────────────────────
FROM node:20-alpine          ──▶  Cached ✅ (instant)
WORKDIR /app                 ──▶  Cached ✅ (instant)
COPY package.json ./         ──▶  Cached ✅ (if unchanged)
RUN npm ci                   ──▶  Cached ✅ (if package.json unchanged)
COPY . .                     ──▶  Changed ⚡ (source code changed)
CMD ["npm", "run", "dev"]    ──▶  Changed ⚡ (rebuilds from here)

💡 KEY INSIGHT: Docker rebuilds from the FIRST changed layer onwards.
That's why we copy package.json BEFORE copying source code!
Only source code changes? Skip npm install (saves minutes!)
```

---

## 🔄 Alternative Approaches

| Approach | Use When |
|----------|----------|
| **Docker** ⭐ | Standard containerization (recommended) |
| **Podman** | Need rootless containers, Docker-compatible |
| **Dev Containers (VS Code)** | Want full dev environment in a container |
| **nvm (Node Version Manager)** | Just need consistent Node versions, no containers |
| **Volta** | Fast Node version management |

---

## 🧠 Senior Developer Mindset

1. **Order Dockerfile instructions by change frequency** — Base image first, source code last.
2. **Use `npm ci` not `npm install`** — Deterministic, faster, production-ready.
3. **Always use `.dockerignore`** — Don't copy node_modules, .git, etc. into the image.
4. **Pin base image versions** — `node:20-alpine`, not `node:latest`. Avoid surprise breaks.
5. **Think in layers** — Each instruction creates a cacheable layer. Optimize for cache hits.

---

## ✅ Checkpoint

After completing this step, you should be able to:
- [ ] Build a Docker image from a Dockerfile
- [ ] Run a container and access your React app via browser
- [ ] List, stop, and remove containers
- [ ] Understand Docker layer caching
- [ ] Have a proper `.dockerignore` file
