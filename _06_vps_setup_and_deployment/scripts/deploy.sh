#!/bin/bash
# ============================================
# Simple Deployment Script
# Run on VPS: bash deploy.sh
# ============================================

set -e

APP_NAME="react-app"
IMAGE_NAME="yourusername/react-app"
TAG="latest"
PORT="80:80"

echo "🚀 Starting deployment..."
echo "   Image: $IMAGE_NAME:$TAG"
echo ""

# Pull latest image
echo "📥 Pulling latest image..."
docker pull $IMAGE_NAME:$TAG

# Stop existing container
echo "🛑 Stopping existing container..."
docker stop $APP_NAME 2>/dev/null || true
docker rm $APP_NAME 2>/dev/null || true

# Start new container
echo "▶️  Starting new container..."
docker run -d \
  --name $APP_NAME \
  --restart unless-stopped \
  -p $PORT \
  $IMAGE_NAME:$TAG

# Verify
echo "🔍 Verifying deployment..."
sleep 3
if docker ps | grep -q $APP_NAME; then
  echo "✅ Deployment successful!"
  echo "🌐 App running at http://$(curl -s ifconfig.me)"
else
  echo "❌ Deployment failed! Check logs:"
  docker logs $APP_NAME
  exit 1
fi

# Cleanup old images
echo "🧹 Cleaning up..."
docker image prune -f

echo "✅ Done!"
