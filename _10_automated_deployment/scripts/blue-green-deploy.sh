#!/bin/bash
# ============================================
# Blue-Green Deployment Script
# Zero-downtime deployment for Docker containers
# ============================================
set -e

IMAGE_NAME="${1:-yourusername/react-app:latest}"
BLUE_PORT=3000
GREEN_PORT=3001
NGINX_CONF="/etc/nginx/sites-available/yourapp.com"

echo "🔄 Blue-Green Deployment Starting..."

# Determine currently active color
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

echo "   Current: $OLD_NAME → New: $NEW_NAME (port $NEW_PORT)"

# Pull latest
docker pull $IMAGE_NAME

# Start new container
docker run -d --name $NEW_NAME --restart unless-stopped -p $NEW_PORT:80 $IMAGE_NAME

# Health check
echo "⏳ Running health check..."
for i in {1..30}; do
    if curl -sf http://localhost:$NEW_PORT > /dev/null 2>&1; then
        echo "✅ Health check passed!"
        break
    fi
    if [[ $i -eq 30 ]]; then
        echo "❌ Health check FAILED! Rolling back..."
        docker stop $NEW_NAME && docker rm $NEW_NAME
        exit 1
    fi
    sleep 1
done

# Switch Nginx
sudo sed -i "s/localhost:[0-9]*/localhost:$NEW_PORT/" $NGINX_CONF
sudo nginx -t && sudo systemctl reload nginx

# Stop old
docker stop $OLD_NAME 2>/dev/null || true
docker rm $OLD_NAME 2>/dev/null || true

echo "✅ Deployment complete! Active: $NEW_NAME (port $NEW_PORT)"
