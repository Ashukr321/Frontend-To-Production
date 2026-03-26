#!/bin/bash
# ============================================
# Rollback Script
# Reverts to the previous Docker image version
# ============================================
set -e

IMAGE_NAME="yourusername/react-app"
DEPLOY_LOG="/opt/deploy/deploy.log"

# Get previous tag
PREVIOUS_TAG=$(tail -2 $DEPLOY_LOG 2>/dev/null | head -1 | awk '{print $2}')

if [[ -z "$PREVIOUS_TAG" ]]; then
    echo "❌ No previous version found!"
    echo "Available images:"
    docker images $IMAGE_NAME --format 'table {{.Tag}}\t{{.CreatedAt}}\t{{.Size}}'
    exit 1
fi

echo "🔄 Rolling back to: $IMAGE_NAME:$PREVIOUS_TAG"

docker stop react-app 2>/dev/null || true
docker rm react-app 2>/dev/null || true

docker run -d \
  --name react-app \
  --restart unless-stopped \
  -p 3000:80 \
  $IMAGE_NAME:$PREVIOUS_TAG

echo "✅ Rollback complete! Running: $PREVIOUS_TAG"
