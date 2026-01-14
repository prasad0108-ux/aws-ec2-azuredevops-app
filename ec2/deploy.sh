#!/bin/bash
set -e

APP_DIR="/home/ubuntu/app"

# If files are nested (common mistake), fix path
if [ -f "$APP_DIR/package.json" ]; then
  cd "$APP_DIR"
elif [ -f "$APP_DIR/app/package.json" ]; then
  cd "$APP_DIR/app"
else
  echo "❌ package.json not found"
  exit 1
fi

echo "Starting deployment in $(pwd)"

npm install --omit=dev

APP_NAME="ec2-app"

if pm2 describe "$APP_NAME" > /dev/null 2>&1; then
  pm2 restart "$APP_NAME"
else
  pm2 start app.js --name "$APP_NAME"
fi
