# 📁 Step 09: CI/CD Pipeline with GitHub Actions

> **Goal:** Automate building, testing, and deploying your React app using GitHub Actions — from `git push` to production in minutes.

---

## 📋 What You'll Learn

- GitHub Actions fundamentals (workflows, jobs, steps)
- Automated testing and linting
- Building and pushing Docker images in CI
- Automated deployment to VPS
- GitHub Secrets management

---

## 🤔 Why CI/CD?

```
Without CI/CD (Manual Process):
1. Developer pushes code                     ⏱️ 0 min
2. Someone remembers to run tests locally    ⏱️ 5 min (if they remember)
3. SSH into server                           ⏱️ 2 min
4. Pull latest code                          ⏱️ 1 min
5. Build Docker image on server              ⏱️ 5 min
6. Stop old container, start new one         ⏱️ 2 min
7. Verify everything works                   ⏱️ 3 min
Total: ~18 minutes of manual work per deploy
+ Human error potential: HIGH

With CI/CD (Automated):
1. Developer pushes code                     ⏱️ 0 min
2. Everything else happens automatically     ⏱️ 3-5 min
Total: ~0 minutes of manual work
+ Human error potential: ZERO
```

---

## 🚀 Step-by-Step Guide

### 1. GitHub Actions File Structure

```
your-repo/
└── .github/
    └── workflows/
        ├── ci.yml          # Lint + Test on every PR
        ├── deploy.yml      # Build + Deploy on push to main
        └── preview.yml     # Deploy preview on PR (optional)
```

### 2. CI Workflow — Lint & Test (`ci.yml`)

```yaml
# .github/workflows/ci.yml
name: CI — Lint & Test

# When to run
on:
  pull_request:
    branches: [main, develop]
  push:
    branches: [main, develop]

jobs:
  lint-and-test:
    name: Lint & Test
    runs-on: ubuntu-latest

    strategy:
      matrix:
        node-version: [18, 20]  # Test on multiple Node versions

    steps:
      # 1. Checkout code
      - name: Checkout repository
        uses: actions/checkout@v4

      # 2. Setup Node.js
      - name: Setup Node.js ${{ matrix.node-version }}
        uses: actions/setup-node@v4
        with:
          node-version: ${{ matrix.node-version }}
          cache: 'npm'  # Cache npm dependencies

      # 3. Install dependencies
      - name: Install dependencies
        run: npm ci

      # 4. Run linting
      - name: Run ESLint
        run: npm run lint

      # 5. Run tests
      - name: Run tests
        run: npm test -- --coverage --watchAll=false

      # 6. Build check (ensure it compiles)
      - name: Build
        run: npm run build

      # 7. Upload coverage (optional)
      - name: Upload coverage
        if: matrix.node-version == 20
        uses: actions/upload-artifact@v4
        with:
          name: coverage-report
          path: coverage/
```

### 3. Deploy Workflow — Build & Deploy (`deploy.yml`)

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]  # Only deploy on push to main

# Prevent concurrent deployments
concurrency:
  group: production
  cancel-in-progress: false

env:
  REGISTRY: docker.io
  IMAGE_NAME: ${{ secrets.DOCKERHUB_USERNAME }}/react-app

jobs:
  # ── Job 1: Build and Test ──
  build-and-test:
    name: Build & Test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: 'npm'

      - name: Install & Test
        run: |
          npm ci
          npm run lint
          npm run build

  # ── Job 2: Build Docker Image ──
  build-docker:
    name: Build & Push Docker Image
    runs-on: ubuntu-latest
    needs: build-and-test  # Only run if tests pass

    steps:
      - uses: actions/checkout@v4

      # Login to Docker Hub
      - name: Login to Docker Hub
        uses: docker/login-action@v3
        with:
          username: ${{ secrets.DOCKERHUB_USERNAME }}
          password: ${{ secrets.DOCKERHUB_TOKEN }}

      # Set up Docker Buildx (for caching)
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      # Build and push image
      - name: Build and Push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ env.IMAGE_NAME }}:latest
            ${{ env.IMAGE_NAME }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  # ── Job 3: Deploy to VPS ──
  deploy:
    name: Deploy to VPS
    runs-on: ubuntu-latest
    needs: build-docker  # Only deploy if image is pushed
    environment: production  # Requires approval (optional)

    steps:
      # Deploy via SSH
      - name: Deploy to VPS
        uses: appleboy/ssh-action@v1
        with:
          host: ${{ secrets.VPS_HOST }}
          username: ${{ secrets.VPS_USERNAME }}
          key: ${{ secrets.VPS_SSH_KEY }}
          script: |
            echo "🚀 Starting deployment..."

            # Pull latest image
            docker pull ${{ env.IMAGE_NAME }}:latest

            # Stop and remove existing container
            docker stop react-app 2>/dev/null || true
            docker rm react-app 2>/dev/null || true

            # Start new container
            docker run -d \
              --name react-app \
              --restart unless-stopped \
              -p 3000:80 \
              ${{ env.IMAGE_NAME }}:latest

            # Cleanup old images
            docker image prune -f

            echo "✅ Deployment complete!"

      # Verify deployment
      - name: Verify Deployment
        run: |
          sleep 10
          curl -f https://${{ secrets.DOMAIN }} || exit 1
          echo "✅ Site is live!"

      # Notify on success
      - name: Notify Success
        if: success()
        run: echo "🎉 Deployment successful!"

      # Notify on failure
      - name: Notify Failure
        if: failure()
        run: echo "❌ Deployment failed!"
```

### 4. Setting Up GitHub Secrets

```
Go to: Repository → Settings → Secrets and variables → Actions

Required Secrets:
┌───────────────────────┬──────────────────────────────────┐
│ Secret Name           │ Value                            │
├───────────────────────┼──────────────────────────────────┤
│ DOCKERHUB_USERNAME    │ Your Docker Hub username         │
│ DOCKERHUB_TOKEN       │ Docker Hub access token          │
│ VPS_HOST              │ Your VPS IP (e.g., 165.22.34.1)  │
│ VPS_USERNAME          │ SSH user (e.g., deploy)          │
│ VPS_SSH_KEY           │ Private SSH key (full PEM)       │
│ DOMAIN                │ Your domain (e.g., yourapp.com)  │
└───────────────────────┴──────────────────────────────────┘

How to get Docker Hub Token:
1. Go to hub.docker.com
2. Account Settings → Security → New Access Token
3. Copy the token → Add as GitHub Secret

How to get SSH Key:
1. Generate: ssh-keygen -t ed25519 -f deploy_key
2. Add deploy_key.pub to VPS: ~/.ssh/authorized_keys
3. Copy deploy_key (private) → Add as GitHub Secret
```

### 5. The Complete Pipeline Flow

```
Developer pushes to main
        │
        ▼
┌────────────────────────────────────┐
│  GitHub Actions Triggered          │
│                                    │
│  Job 1: Build & Test               │
│  ├── Checkout code                 │
│  ├── Install dependencies          │
│  ├── Run ESLint                    │
│  ├── Run tests                     │
│  └── Build React app               │
│       │                            │
│       ▼ (pass)                     │
│  Job 2: Docker Build               │
│  ├── Login to Docker Hub           │
│  ├── Build Docker image            │
│  ├── Tag with :latest and :sha     │
│  └── Push to Docker Hub            │
│       │                            │
│       ▼ (pass)                     │
│  Job 3: Deploy                     │
│  ├── SSH into VPS                  │
│  ├── Pull new image                │
│  ├── Stop old container            │
│  ├── Start new container           │
│  └── Verify health                 │
└────────────────────────────────────┘
        │
        ▼
   ✅ App live at https://yourapp.com
```

---

## 🔒 Security Best Practices for CI/CD

```
1. ✅ Use GitHub Secrets for ALL sensitive data
2. ✅ Use access tokens, not passwords
3. ✅ Limit SSH key permissions (deploy key, not personal key)
4. ✅ Use environments with protection rules
5. ✅ Pin action versions (@v4 not @latest)
6. ✅ Enable branch protection on main
7. ✅ Require PR reviews before merging
8. ✅ Use concurrency groups to prevent parallel deploys
```

---

## 🔄 Alternative Approaches

| Tool | When to Use |
|------|-------------|
| **GitHub Actions** ⭐ | GitHub repos (free for public repos) |
| **GitLab CI** | GitLab repos (built-in) |
| **Jenkins** | Self-hosted, maximum flexibility |
| **CircleCI** | Fast builds, great Docker support |
| **AWS CodePipeline** | AWS-native deployments |
| **Drone CI** | Container-native CI |
| **Vercel/Netlify CI** | Zero-config frontend deploys |

---

## 🏢 Company vs Individual

### Individual
```
- Single workflow: test → build → deploy
- Deploy on push to main
- GitHub-hosted runners (free)
```

### Enterprise
```
- Multi-stage pipeline with gates
- Environment promotion: dev → staging → QA → prod
- Required approvals for production
- Self-hosted runners (for security)
- Parallel testing across Node versions and browsers
- Automated security scanning (SAST, DAST)
- Compliance checks in pipeline
- Deployment windows
- Automatic rollback on failure
```

---

## 🧠 Senior Developer Mindset

1. **Pipeline speed matters** — If CI takes 30 minutes, developers won't push frequently. Target < 10 min.
2. **Cache everything** — npm cache, Docker layer cache, build cache. Minutes saved per run.
3. **Fail fast, fail early** — Run cheap checks (lint) before expensive ones (e2e tests).
4. **Branch protection is essential** — No direct push to main. Always through PRs.
5. **Test the pipeline** — Your CI config is code. Test changes in a branch first.
6. **Concurrency controls** — Prevent two deployments from running at the same time.

---

## ✅ Checkpoint

- [ ] CI workflow runs on PRs (lint + test)
- [ ] Deploy workflow runs on push to main
- [ ] Docker image built and pushed in CI
- [ ] Automated deployment to VPS via SSH
- [ ] GitHub Secrets configured
- [ ] Branch protection enabled
