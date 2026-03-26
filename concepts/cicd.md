# 🔄 CI/CD — Continuous Integration & Continuous Deployment

## What is CI/CD?

**CI (Continuous Integration):** Automatically building and testing code every time a developer pushes changes.

**CD (Continuous Deployment/Delivery):** Automatically deploying tested code to production (deployment) or making it ready for manual deployment (delivery).

### The Problem CI/CD Solves

Without CI/CD:
- Manual builds are error-prone and inconsistent
- "Did you run the tests?" — Nobody knows
- Deployments are stressful, manual, weekend events
- Bugs reach production because nobody tested the integration
- Rollbacks require manual intervention

With CI/CD:
- Every push is automatically built and tested
- Broken code is caught before it reaches production
- Deployments are automated, consistent, and reversible
- Team moves faster with confidence

---

## 🔑 Key Concepts

| Concept | Description |
|---------|-------------|
| **Workflow** | A configurable automated process (defined in YAML) |
| **Job** | A set of steps that run on the same runner |
| **Step** | An individual task within a job (run command or use action) |
| **Runner** | The server that runs your workflows (GitHub-hosted or self-hosted) |
| **Action** | A reusable unit of code (from GitHub Marketplace or custom) |
| **Trigger** | Event that starts a workflow (push, PR, schedule, manual) |
| **Artifact** | Files produced by a workflow (build outputs, test reports) |
| **Secret** | Encrypted environment variables for sensitive data |
| **Matrix** | Run same job with different configurations (Node versions, OS) |

---

## 📖 Official Documentation

| Resource | Link |
|----------|------|
| GitHub Actions Docs | https://docs.github.com/en/actions |
| Workflow Syntax | https://docs.github.com/en/actions/reference/workflow-syntax-for-github-actions |
| GitHub Actions Marketplace | https://github.com/marketplace?type=actions |
| GitHub Actions Environments | https://docs.github.com/en/actions/deployment/targeting-different-environments |
| Encrypted Secrets | https://docs.github.com/en/actions/security-guides/encrypted-secrets |

---

## 🆓 Free Resources

| Resource | Link | Type |
|----------|------|------|
| GitHub Skills — Actions | https://skills.github.com | Interactive Course |
| GitHub Actions Tutorial | https://www.actionsbyexample.com | Examples |
| Awesome GitHub Actions | https://github.com/sdras/awesome-actions | Curated List |
| DevOps with GitHub Actions | https://lab.github.com | Lab |

---

## 🔄 Alternative CI/CD Tools

| Tool | Pros | Cons | Best For |
|------|------|------|----------|
| **GitHub Actions** | Free for public repos, native GitHub integration | Limited free minutes for private repos | GitHub-hosted projects |
| **GitLab CI** | Built into GitLab, powerful pipelines | Tied to GitLab ecosystem | GitLab-hosted projects |
| **Jenkins** | Extremely flexible, self-hosted | Complex setup, maintenance overhead | Enterprise with custom needs |
| **CircleCI** | Fast, good Docker support | Pricing can get expensive | Performance-critical pipelines |
| **Travis CI** | Simple YAML config | Reduced free tier | Open source projects |
| **AWS CodePipeline** | Native AWS integration | AWS lock-in | AWS-heavy architectures |
| **Vercel / Netlify** | Zero-config deployments for frontends | Limited to JAMstack/frontend | Simple frontend projects |

---

## 🏢 Company Approach vs Individual Developer

### Individual Developer
```
- Simple workflow: test → build → deploy
- Single environment (production)
- Manual approval not needed
- Deploy on push to main
```

### Company / Enterprise
```
- Multi-stage pipeline: lint → test → security scan → build → staging → approval → production
- Multiple environments (dev, staging, QA, pre-prod, production)
- Required reviewers and approvals for production deploys
- Branch protection rules (no direct push to main)
- Automated rollback on failure
- Deployment windows and change management
- Compliance and audit trails
- Self-hosted runners for security
```

---

## 🧠 Senior Developer Mindset

1. **Pipeline should be fast** — If CI takes 30 minutes, developers will avoid pushing. Target < 10 minutes.
2. **Fail fast** — Run linting and unit tests first (fast), then integration tests (slower).
3. **Cache aggressively** — Cache `node_modules`, Docker layers, build outputs.
4. **Keep workflows DRY** — Use reusable workflows and composite actions.
5. **Branch strategy matters** — `main` = production, `develop` = staging. Use feature branches.
6. **Never store secrets in code** — Always use GitHub Secrets or a vault.
7. **Test the pipeline itself** — Your CI/CD config is code. Review it like code.
