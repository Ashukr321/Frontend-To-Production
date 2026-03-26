# 📁 Step 05: Docker Compose & Networking

> **Goal:** Use Docker Compose to manage multi-container applications, understand Docker networking, and set up a full development environment with a single command.

---

## 📋 What You'll Learn

- Docker Compose fundamentals
- Multi-container orchestration
- Docker networking (bridge, custom networks)
- Volume management for persistent data
- Environment variable management in Compose

---

## 🤔 Why Docker Compose?

```
Without Docker Compose:
docker run -d --name frontend -p 3000:80 --network mynet -e API_URL=http://backend:4000 react-app
docker run -d --name backend -p 4000:4000 --network mynet -e DB_URL=mongodb://db:27017 node-api
docker run -d --name db -p 27017:27017 --network mynet -v dbdata:/data/db mongo:7

❌ Three separate commands to remember
❌ Hard to manage, easy to mess up
❌ No single source of truth

With Docker Compose:
docker compose up -d

✅ One command to start everything
✅ All configuration in one file
✅ Easy to share with team
✅ Version controlled
```

---

## 🚀 Step-by-Step Guide

### 1. Docker Compose File (`docker-compose.yml`)

```yaml
# Docker Compose for Full-Stack React Application
# Run: docker compose up -d

version: "3.9"

services:
  # ── Frontend (React) ──
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: react-frontend
    ports:
      - "3000:80"
    environment:
      - VITE_API_URL=http://localhost:4000/api
    depends_on:
      - backend
    networks:
      - app-network
    restart: unless-stopped

  # ── Backend (Node.js API) ──
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: node-backend
    ports:
      - "4000:4000"
    environment:
      - NODE_ENV=development
      - PORT=4000
      - DATABASE_URL=mongodb://db:27017/myapp
      - JWT_SECRET=your-secret-key-change-in-production
    depends_on:
      - db
    networks:
      - app-network
    restart: unless-stopped
    volumes:
      - ./backend/src:/app/src  # Hot reload for development

  # ── Database (MongoDB) ──
  db:
    image: mongo:7
    container_name: mongodb
    ports:
      - "27017:27017"
    environment:
      - MONGO_INITDB_ROOT_USERNAME=admin
      - MONGO_INITDB_ROOT_PASSWORD=password123
    volumes:
      - mongo-data:/data/db    # Persist data across restarts
    networks:
      - app-network
    restart: unless-stopped

# ── Named Volumes ──
volumes:
  mongo-data:
    driver: local

# ── Custom Network ──
networks:
  app-network:
    driver: bridge
```

### 2. Development Compose Override (`docker-compose.dev.yml`)

```yaml
# Override for development
# Run: docker compose -f docker-compose.yml -f docker-compose.dev.yml up

version: "3.9"

services:
  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile.dev
    ports:
      - "5173:5173"
    volumes:
      - ./frontend/src:/app/src   # Hot reload
    environment:
      - VITE_ENABLE_DEBUG=true

  backend:
    volumes:
      - ./backend:/app            # Hot reload
      - /app/node_modules         # Don't override node_modules
    command: npm run dev
```

### 3. Docker Networking Explained

```
┌──────────────────── app-network (bridge) ────────────────────┐
│                                                               │
│  ┌─────────────┐     ┌─────────────┐     ┌──────────────┐  │
│  │  frontend    │────▶│  backend    │────▶│  db (mongo)  │  │
│  │  port: 80    │     │  port: 4000  │     │  port: 27017 │  │
│  │              │     │              │     │              │  │
│  │  Reaches     │     │  Reaches db  │     │  mongodb://  │  │
│  │  backend via │     │  via:        │     │  db:27017/   │  │
│  │  "backend"   │     │  "db:27017"  │     │  myapp       │  │
│  └─────────────┘     └─────────────┘     └──────────────┘  │
│                                                               │
│  Containers on the same network can reach each other          │
│  by SERVICE NAME (e.g., backend, db) — Docker DNS             │
└───────────────────────────────────────────────────────────────┘

External Access (from your browser):
  localhost:3000  →  frontend container
  localhost:4000  →  backend container
  localhost:27017 →  MongoDB (only for dev!)
```

### 4. Essential Docker Compose Commands

```bash
# ── LIFECYCLE ──
docker compose up                   # Start all services (foreground)
docker compose up -d                # Start all services (background)
docker compose down                 # Stop and remove containers
docker compose down -v              # Also remove volumes (⚠️ deletes data)
docker compose restart              # Restart all services

# ── BUILD ──
docker compose build                # Build all images
docker compose build frontend       # Build specific service
docker compose up --build           # Build and start

# ── MONITORING ──
docker compose ps                   # List services and status
docker compose logs                 # View all logs
docker compose logs frontend        # View specific service logs
docker compose logs -f              # Follow (tail) logs

# ── EXECUTION ──
docker compose exec frontend sh     # Shell into running container
docker compose run backend npm test # Run one-off command

# ── SCALING ──
docker compose up -d --scale backend=3  # Run 3 backend instances
```

### 5. Using Environment Files with Compose

```yaml
# docker-compose.yml
services:
  backend:
    env_file:
      - ./backend/.env         # Load from .env file
    environment:
      - NODE_ENV=production    # Override specific variables
```

---

## 🔄 Alternative Approaches

| Tool | When to Use |
|------|-------------|
| **Docker Compose** ⭐ | Local dev, small deployments, learning |
| **Kubernetes (K8s)** | Production at scale, enterprise orchestration |
| **Docker Swarm** | Simple multi-host orchestration |
| **Podman Compose** | Drop-in replacement, rootless |
| **Tilt** | Kubernetes dev workflow tool |
| **Skaffold** | K8s development tool by Google |

---

## 🏢 Company vs Individual

### Individual Developer
```
- docker-compose.yml for full-stack local dev
- Single machine deployment
- Manual container management
```

### Enterprise
```
- Docker Compose for local development only
- Kubernetes for production orchestration
- Helm charts for K8s deployment configs
- Service mesh (Istio) for inter-service communication
- Container registries with access control
- Resource limits and quotas
- Auto-scaling based on load
```

---

## 🧠 Senior Developer Mindset

1. **Compose is for dev, K8s is for prod** — Docker Compose is great for local development. Production at scale needs orchestration.
2. **Use `depends_on` wisely** — It controls startup ORDER, not readiness. Use health checks for actual readiness.
3. **Name your volumes** — Anonymous volumes are hard to manage and backup.
4. **Use custom networks** — Don't rely on the default bridge network. Explicit is better.
5. **Separate dev and prod configs** — Use `docker-compose.override.yml` for dev-specific settings.

---

## ✅ Checkpoint

- [ ] Create a `docker-compose.yml` with at least 2 services
- [ ] Start and stop the stack with `docker compose up/down`
- [ ] Understand how services communicate via network
- [ ] Use volumes for persistent data
- [ ] Use environment variables in Compose
