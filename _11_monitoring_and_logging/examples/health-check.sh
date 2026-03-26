#!/bin/bash
# ============================================
# Server Health Check Script
# Usage: Add to crontab:
#   */5 * * * * /opt/scripts/health-check.sh
# ============================================

LOG_FILE="/var/log/health-check.log"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "=== $TIMESTAMP ===" >> $LOG_FILE

# CPU
CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}')
echo "CPU: ${CPU}%" >> $LOG_FILE

# Memory
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
MEM_PERCENT=$(echo "scale=1; $MEM_USED * 100 / $MEM_TOTAL" | bc)
echo "Memory: ${MEM_USED}MB / ${MEM_TOTAL}MB (${MEM_PERCENT}%)" >> $LOG_FILE

# Disk
DISK=$(df -h / | tail -1 | awk '{print $5}')
echo "Disk: $DISK" >> $LOG_FILE

# Docker containers
echo "Containers:" >> $LOG_FILE
docker ps --format '  {{.Names}}: {{.Status}}' >> $LOG_FILE

# App health
HTTP_CODE=$(curl -s -o /dev/null -w '%{http_code}' http://localhost:3000 2>/dev/null || echo "000")
echo "App HTTP Status: $HTTP_CODE" >> $LOG_FILE

echo "" >> $LOG_FILE
