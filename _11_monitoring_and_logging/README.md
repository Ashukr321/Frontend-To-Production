# 📁 Step 11: Monitoring & Logging

> **Goal:** Set up monitoring, logging, and alerting to ensure your production React application is healthy and performant.

---

## 📋 What You'll Learn

- Application health checks
- Uptime monitoring
- Error tracking with Sentry
- Server resource monitoring
- Log management
- Alerting for critical issues

---

## 🤔 Why Monitoring?

```
Without Monitoring:
❌ App goes down at 3 AM — nobody knows for hours
❌ Memory leak slowly kills the server — discovered by users
❌ 500 errors in production — no visibility into why
❌ Deployed a bug — found out from customer complaints

With Monitoring:
✅ Instant alert when app goes down (before users notice)
✅ Performance trends visible (catch issues early)
✅ Full error stack traces from production
✅ Historical data for debugging and capacity planning
```

---

## 🚀 Step-by-Step Guide

### 1. Docker Health Checks

```dockerfile
# In your Dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1
```

```bash
# Check container health
docker ps  # Shows HEALTH column
docker inspect --format='{{.State.Health.Status}}' react-app
```

### 2. Uptime Monitoring (External)

**Free Tools:**

| Tool | Free Tier | Check Interval |
|------|-----------|----------------|
| **UptimeRobot** | 50 monitors, 5 min | 5 min |
| **Better Stack (formerly Better Uptime)** | 10 monitors | 3 min |
| **Freshping** | 50 monitors | 1 min |
| **Hetrix Tools** | 15 monitors | 1 min |
| **Uptime Kuma** (self-hosted) | Unlimited | 1 min |

**Setting up UptimeRobot:**
```
1. Sign up at uptimerobot.com (free)
2. Add monitor:
   - Type: HTTPS
   - URL: https://yourapp.com
   - Interval: 5 minutes
3. Configure alerts (email, Slack, Discord)
4. Add status page (optional)
```

### 3. Error Tracking with Sentry

```bash
# Install Sentry SDK
npm install @sentry/react
```

```javascript
// src/main.jsx
import * as Sentry from '@sentry/react';

Sentry.init({
  dsn: import.meta.env.VITE_SENTRY_DSN,
  integrations: [
    Sentry.browserTracingIntegration(),
    Sentry.replayIntegration(),
  ],
  // Performance monitoring
  tracesSampleRate: 1.0, // In production, lower to 0.1 (10%)
  // Session replay
  replaysSessionSampleRate: 0.1,
  replaysOnErrorSampleRate: 1.0,
  // Only send errors in production
  enabled: import.meta.env.PROD,
});
```

```jsx
// Wrap your app with Sentry error boundary
import * as Sentry from '@sentry/react';

function App() {
  return (
    <Sentry.ErrorBoundary
      fallback={<p>Something went wrong. We've been notified.</p>}
    >
      <YourApp />
    </Sentry.ErrorBoundary>
  );
}
```

### 4. Server Monitoring Script

```bash
#!/bin/bash
# monitor.sh — Basic server health check
# Add to cron: */5 * * * * /opt/scripts/monitor.sh

LOG_FILE="/var/log/server-monitor.log"
ALERT_EMAIL="you@example.com"

# Timestamp
echo "=== $(date) ===" >> $LOG_FILE

# CPU Usage
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
echo "CPU: ${CPU}%" >> $LOG_FILE

# Memory Usage
MEM=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100}')
echo "Memory: ${MEM}%" >> $LOG_FILE

# Disk Usage
DISK=$(df -h / | tail -1 | awk '{print $5}' | tr -d '%')
echo "Disk: ${DISK}%" >> $LOG_FILE

# Docker container status
CONTAINERS=$(docker ps --format '{{.Names}}: {{.Status}}')
echo "Containers: $CONTAINERS" >> $LOG_FILE

# Alerts
if (( $(echo "$MEM > 90" | bc -l) )); then
    echo "⚠️ HIGH MEMORY: ${MEM}%" | mail -s "Server Alert" $ALERT_EMAIL
fi

if (( DISK > 85 )); then
    echo "⚠️ HIGH DISK: ${DISK}%" | mail -s "Server Alert" $ALERT_EMAIL
fi
```

### 5. Docker Container Logging

```bash
# View logs
docker logs react-app                    # All logs
docker logs react-app --tail 100         # Last 100 lines
docker logs react-app -f                 # Follow (stream)
docker logs react-app --since 1h         # Last hour
docker logs react-app --since 2024-01-01 # Since date

# Log rotation (prevent disk from filling up)
# In docker-compose.yml or docker run:
docker run -d \
  --log-driver json-file \
  --log-opt max-size=10m \
  --log-opt max-file=3 \
  --name react-app \
  react-app:latest
```

### 6. Web Vitals Monitoring (Frontend Performance)

```javascript
// src/utils/webVitals.js
import { onCLS, onFID, onLCP, onFCP, onTTFB } from 'web-vitals';

function sendToAnalytics(metric) {
  // Send to your analytics service
  console.log(metric);

  // Or send to a custom endpoint
  fetch('/api/metrics', {
    method: 'POST',
    body: JSON.stringify({
      name: metric.name,
      value: metric.value,
      delta: metric.delta,
      id: metric.id,
    }),
  });
}

export function reportWebVitals() {
  onCLS(sendToAnalytics);   // Cumulative Layout Shift
  onFID(sendToAnalytics);   // First Input Delay
  onLCP(sendToAnalytics);   // Largest Contentful Paint
  onFCP(sendToAnalytics);   // First Contentful Paint
  onTTFB(sendToAnalytics);  // Time to First Byte
}
```

---

## 📊 Monitoring Dashboard Checklist

```
✅ Uptime monitor (is the site up?)
✅ Response time (is it fast?)
✅ Error rate (are errors increasing?)
✅ Server CPU/Memory/Disk
✅ Container health status
✅ SSL certificate expiry
✅ Web Vitals (Core Web Vitals scores)
✅ User-facing error tracking (Sentry)
```

---

## 🔄 Alternative Tools

| Category | Free Options | Paid Options |
|----------|-------------|--------------|
| **Uptime** | UptimeRobot, Uptime Kuma | Datadog, PagerDuty |
| **Errors** | Sentry (free tier) | Bugsnag, Rollbar |
| **Metrics** | Prometheus + Grafana | Datadog, New Relic |
| **Logs** | Loki, self-hosted ELK | Datadog, Splunk |
| **APM** | Sentry Performance | Datadog APM, Dynatrace |

---

## 🧠 Senior Developer Mindset

1. **Monitor before you need to** — Set up monitoring day one, not after your first outage.
2. **Alert fatigue is real** — Only alert on actionable issues. Too many alerts = all alerts ignored.
3. **Two types of monitoring: proactive and reactive** — Uptime checks = proactive. Error tracking = reactive. You need both.
4. **Track trends, not just thresholds** — "Memory is at 80%" is concerning. "Memory grew 20% this week" is actionable.
5. **Post-incident reviews** — After every outage, document: What happened? Why? How to prevent it?

---

## ✅ Checkpoint

- [ ] Docker health checks configured
- [ ] Uptime monitoring active (UptimeRobot or similar)
- [ ] Sentry error tracking integrated
- [ ] Server monitoring script running
- [ ] Log rotation configured
- [ ] Alert notifications working
