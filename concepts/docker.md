# 🐳 Docker — Concepts & Resources

## What is Docker?

Docker is a platform that packages your application and all its dependencies into a **container** — a lightweight, portable, self-sufficient unit that runs the same everywhere (your laptop, CI server, production server).

### The Problem Docker Solves
> "It works on my machine!" — Every developer, before Docker.

Without Docker:
- Different Node.js versions on dev vs production cause bugs
- Missing system dependencies break deployments
- Setting up a new developer's machine takes hours/days
- "Works on my machine" but fails in production

With Docker:
- Same environment everywhere (dev, staging, production)
- One-command setup for new team members
- Reproducible builds every time
- Isolated dependencies, no conflicts

---

## 🔑 Key Concepts

| Concept | Description |
|---------|-------------|
| **Image** | A blueprint/template for creating containers (like a class in OOP) |
| **Container** | A running instance of an image (like an object in OOP) |
| **Dockerfile** | Instructions to build an image (recipe) |
| **Layer** | Each instruction in Dockerfile creates a cached layer |
| **Registry** | A storage for Docker images (DockerHub, GHCR, ECR) |
| **Volume** | Persistent storage that survives container restarts |
| **Network** | Communication channel between containers |
| **Docker Compose** | Tool to define multi-container applications |

---

## 📖 Official Documentation

| Resource | Link |
|----------|------|
| Docker Official Docs | https://docs.docker.com |
| Dockerfile Reference | https://docs.docker.com/reference/dockerfile/ |
| Docker Compose Docs | https://docs.docker.com/compose/ |
| Docker Hub | https://hub.docker.com |
| Docker Best Practices | https://docs.docker.com/build/building/best-practices/ |

---

## 🆓 Free Resources

| Resource | Link | Type |
|----------|------|------|
| Play with Docker | https://labs.play-with-docker.com | Hands-on Lab |
| Docker Curriculum | https://docker-curriculum.com | Tutorial |
| Docker 101 Tutorial | https://www.docker.com/101-tutorial/ | Official Tutorial |
| Awesome Docker | https://github.com/veggiemonk/awesome-docker | Curated List |
| Docker Cheat Sheet | https://dockerlabs.collabnix.com/docker/cheatsheet/ | Reference |

---

## 🔄 Alternative Approaches

| Instead of Docker | When to Use |
|-------------------|-------------|
| **Podman** | Drop-in Docker replacement, rootless by default, no daemon. Great for security-focused environments |
| **Buildah** | Specialized in building OCI images without requiring a daemon |
| **LXC/LXD** | System-level containers (heavier than Docker, more like VMs) |
| **Nix** | Reproducible builds without containers. Complex but powerful |
| **Direct Deploy** | Small projects where Docker overhead isn't worth it. `npm run build` + copy files to server |

### When to Use Docker vs. Direct Deploy

```
Solo Developer, Simple App → Direct deploy (rsync/scp) is fine
Team of 2-5, Multiple Services → Docker + Docker Compose
Enterprise, Microservices → Docker + Kubernetes
```

---

## 🏢 Company Approach vs Individual Developer

### Individual Developer
```
- Single Dockerfile
- docker-compose for local dev
- Push to DockerHub (free tier)
- Pull and run on VPS manually
```

### Company / Enterprise
```
- Multi-stage Dockerfiles with security scanning
- Private container registry (ECR, GCR, GHCR)
- Base images maintained by platform team
- Automated vulnerability scanning (Snyk, Trivy)
- Container orchestration (Kubernetes, ECS)
- Resource limits and health checks enforced
- Image signing and verification
```

---

## 🧠 Senior Developer Mindset

1. **Always use multi-stage builds** — Your production image should only contain what's needed to RUN the app, not BUILD it.
2. **Order Dockerfile instructions by change frequency** — Put rarely-changing layers first (OS, deps) and frequently-changing layers last (source code) for better caching.
3. **Never run as root in containers** — Always create and use a non-root user.
4. **Pin your base image versions** — `node:20-alpine` not `node:latest`. Avoid surprises.
5. **Use `.dockerignore`** — Don't copy `node_modules`, `.git`, or test files into images.
6. **Think about image size** — A 25MB Nginx image serving React static files is better than a 1GB Node image.
