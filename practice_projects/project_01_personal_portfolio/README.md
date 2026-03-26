# 🟢 Project 01: Personal Portfolio — Full Deployment

> **Difficulty:** Beginner  
> **Time:** 4-6 hours  
> **Goal:** Build a personal portfolio site and deploy it to production with Docker, a custom domain, and CI/CD.

---

## 📋 Requirements

### Application
- [ ] Hero section with name and title
- [ ] About section with bio
- [ ] Projects section (at least 3 projects)
- [ ] Skills section
- [ ] Contact form (Formspree or EmailJS)
- [ ] Responsive design (mobile + desktop)
- [ ] Dark mode (optional)

### DevOps
- [ ] Dockerized with multi-stage build (< 30MB image)
- [ ] Deployed to a VPS
- [ ] Custom domain with SSL
- [ ] GitHub Actions CI/CD pipeline
- [ ] Uptime monitoring

---

## 🏗️ Architecture

```
GitHub Repo
    │ git push
    ▼
GitHub Actions ──▶ Build Docker Image ──▶ Push to Docker Hub
    │
    ▼
VPS (Ubuntu)
├── Nginx (reverse proxy + SSL)
└── Docker container (Nginx + static files)
    │
    ▼
https://yourname.com ← Users
```

---

## 📁 Suggested File Structure

```
portfolio/
├── public/
│   └── favicon.ico
├── src/
│   ├── components/
│   │   ├── Hero.jsx
│   │   ├── About.jsx
│   │   ├── Projects.jsx
│   │   ├── Skills.jsx
│   │   └── Contact.jsx
│   ├── App.jsx
│   ├── main.jsx
│   └── App.css
├── Dockerfile
├── nginx.conf
├── .dockerignore
├── .github/
│   └── workflows/
│       └── deploy.yml
├── package.json
└── vite.config.js
```

---

## ✅ Completion Checklist

- [ ] React portfolio app running locally
- [ ] Dockerfile created (multi-stage with Nginx)
- [ ] Docker image built and tested locally
- [ ] Image pushed to Docker Hub
- [ ] VPS created and secured
- [ ] Docker installed on VPS
- [ ] Container deployed on VPS
- [ ] Domain configured and pointing to VPS
- [ ] Nginx reverse proxy configured
- [ ] SSL certificate installed (Let's Encrypt)
- [ ] GitHub Actions workflow deploys on push to main
- [ ] Uptime monitoring active
- [ ] Site accessible at https://yourname.com 🎉

---

## 💡 Tips

1. Use **Vite** for the React app (fast builds)
2. Use **nginx:alpine** in the Dockerfile (smallest image)
3. Use **Cloudflare** for DNS (free CDN + DDoS protection)
4. Start with the app, then containerize, then deploy
5. Test locally with `docker run -p 3000:80 portfolio:latest` before deploying
