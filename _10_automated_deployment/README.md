# 📁 Step 10: Automated Deployment Strategies

> **Goal:** Implement zero-downtime deployment, rollback mechanisms, and advanced deployment strategies for production React applications.

---

## 📋 What You'll Learn

- Zero-downtime deployment
- Blue-Green deployment strategy
- Rolling deployment
- Canary deployment
- Automated rollback
- Deployment notifications

---

## 🤔 Why Advanced Deployment Strategies?

```
Basic Deployment (what we did so far):
1. Stop old container     ← ❌ DOWNTIME (~5-30 seconds)
2. Pull new image
3. Start new container

Users experience:
"Site is down" or "Connection refused" during deploy

With Zero-Downtime Deployment:
1. Start new container alongside old one
2. Verify new container is healthy
3. Switch traffic to new container
4. Stop old container

Users experience:
Nothing. They don't even know a deploy happened. ✅
```

---

## 🚀 Deployment Strategies

### 1. Blue-Green Deployment

```
Before Deploy:
┌──────────────┐     ┌──────────────┐
│  Nginx       │────▶│  Blue (v1)   │  ← All traffic here
│  (port 80)   │     │  (port 3000) │
└──────────────┘     └──────────────┘
                     ┌──────────────┐
                     │  Green       │  ← Idle
                     │  (port 3001) │
                     └──────────────┘

During Deploy:
┌──────────────┐     ┌──────────────┐
│  Nginx       │     │  Blue (v1)   │  ← Still serving
│  (port 80)   │     │  (port 3000) │
└──────────────┘     └──────────────┘
                     ┌──────────────┐
                     │  Green (v2)  │  ← New version starts
                     │  (port 3001) │
                     └──────────────┘

After Health Check Pass:
┌──────────────┐     ┌──────────────┐
│  Nginx       │     │  Blue (v1)   │  ← Stopped
│  (port 80)   │────▶│  (port 3000) │
└──────────────┘     └──────────────┘
                     ┌──────────────┐
              ──────▶│  Green (v2)  │  ← All traffic here
                     │  (port 3001) │
                     └──────────────┘
```

#### Blue-Green Deploy Script

```bash
#!/bin/bash
# blue-green-deploy.sh
set -e

IMAGE_NAME="yourusername/react-app:latest"
BLUE_PORT=3000
GREEN_PORT=3001

# Determine which is currently active
CURRENT=$(docker ps --format '{{.Names}}' | grep -E 'react-(blue|green)' | head -1)

if [[ "$CURRENT" == "react-blue" ]]; then
    NEW_NAME="react-green"
    NEW_PORT=$GREEN_PORT
    OLD_NAME="react-blue"
else
    NEW_NAME="react-blue"
    NEW_PORT=$BLUE_PORT
    OLD_NAME="react-green"
fi

echo "🔄 Deploying $NEW_NAME (port $NEW_PORT)..."

# Pull latest image
docker pull $IMAGE_NAME

# Start new container
docker run -d \
  --name $NEW_NAME \
  --restart unless-stopped \
  -p $NEW_PORT:80 \
  $IMAGE_NAME

# Wait for health check
echo "⏳ Waiting for health check..."
for i in {1..30}; do
    if curl -sf http://localhost:$NEW_PORT > /dev/null 2>&1; then
        echo "✅ Health check passed!"
        break
    fi
    if [[ $i -eq 30 ]]; then
        echo "❌ Health check failed! Rolling back..."
        docker stop $NEW_NAME && docker rm $NEW_NAME
        exit 1
    fi
    sleep 1
done

# Update Nginx to point to new container
sudo sed -i "s/localhost:$BLUE_PORT\|localhost:$GREEN_PORT/localhost:$NEW_PORT/" \
  /etc/nginx/sites-available/yourapp.com
sudo nginx -t && sudo systemctl reload nginx

# Stop old container
echo "🛑 Stopping $OLD_NAME..."
docker stop $OLD_NAME 2>/dev/null || true
docker rm $OLD_NAME 2>/dev/null || true

echo "✅ Deploy complete! Traffic now on $NEW_NAME (port $NEW_PORT)"
```

### 2. Rollback Script

```bash
#!/bin/bash
# rollback.sh — Quickly revert to previous version
set -e

IMAGE_NAME="yourusername/react-app"

echo "🔄 Rolling back to previous version..."

# Get the previous image tag from deployment log
PREVIOUS_TAG=$(cat /opt/deploy/previous_tag.txt 2>/dev/null)

if [[ -z "$PREVIOUS_TAG" ]]; then
    echo "❌ No previous version found!"
    echo "Available tags:"
    docker images $IMAGE_NAME --format '{{.Tag}}' | head -5
    exit 1
fi

echo "Rolling back to: $IMAGE_NAME:$PREVIOUS_TAG"

# Stop current
docker stop react-app 2>/dev/null || true
docker rm react-app 2>/dev/null || true

# Start previous version
docker run -d \
  --name react-app \
  --restart unless-stopped \
  -p 3000:80 \
  $IMAGE_NAME:$PREVIOUS_TAG

echo "✅ Rollback complete! Running version: $PREVIOUS_TAG"
```

### 3. Deploy with Notifications

```yaml
# Add to GitHub Actions deploy workflow
- name: Notify Slack on Deploy
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    fields: repo,message,commit,author,action,eventName,ref,workflow
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}

# Or use Discord
- name: Notify Discord
  if: always()
  uses: sarisia/actions-status-discord@v1
  with:
    webhook: ${{ secrets.DISCORD_WEBHOOK }}
    status: ${{ job.status }}
    title: "Deploy to Production"
    description: "Commit: ${{ github.sha }}"
```

---

## 📊 Strategy Comparison

```
┌─────────────┬───────────┬───────────┬────────────┬──────────┐
│ Strategy    │ Downtime  │ Rollback  │ Complexity │ Cost     │
├─────────────┼───────────┼───────────┼────────────┼──────────┤
│ Stop/Start  │ 5-30 sec  │ Manual    │ Simple     │ Low      │
│ Blue-Green  │ Zero      │ Instant   │ Medium     │ 2x infra │
│ Rolling     │ Zero      │ Automatic │ Medium     │ Low      │
│ Canary      │ Zero      │ Automatic │ High       │ Medium   │
└─────────────┴───────────┴───────────┴────────────┴──────────┘
```

---

## 🏢 Company vs Individual

### Individual
```
- Blue-Green with 2 containers on 1 VPS
- Manual rollback via docker commands
- Discord/Slack notification
```

### Enterprise
```
- Kubernetes rolling deployments
- Automated canary with Istio/Flagger
- Feature flags for gradual rollout
- Automated rollback on error rate spike
- Deployment approval gates
- Change management process
- Post-deployment verification suite
- Blue-Green across multiple regions
```

---

## 🧠 Senior Developer Mindset

1. **Zero-downtime is non-negotiable for production** — Even 5 seconds of downtime is unacceptable for user-facing apps.
2. **Always have a rollback plan** — Before deploying, know exactly how to revert.
3. **Monitor after every deploy** — Watch error rates and performance for 15-30 minutes post-deploy.
4. **Tag every deployment** — Know exactly which commit is running in production.
5. **Feature flags > risky deploys** — Deploy code behind flags. Enable when ready. Disable if broken.

---

## ✅ Checkpoint

- [ ] Implement blue-green deployment
- [ ] Rollback script works
- [ ] Zero downtime verified
- [ ] Deploy notifications configured
- [ ] Previous version tracked for rollback
