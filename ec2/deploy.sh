#!/bin/bash
set -e

APP_DIR="/home/ubuntu/app"
APP_NAME="ec2-app"

cd "$APP_DIR"

echo "Running deployment from: $(pwd)"
ls -l

# Ensure package.json exists
if [ ! -f package.json ]; then
  echo "❌ package.json not found in $APP_DIR"
  exit 1
fi

echo "Installing dependencies..."
npm install --omit=dev

if pm2 describe "$APP_NAME" > /dev/null 2>&1; then
  echo "Restarting app..."
  pm2 restart "$APP_NAME"
else
  echo "Starting app..."
  pm2 start app.js --name "$APP_NAME"
fi

echo "Deployment completed successfully."
