#!/bin/bash
set -e

APP_DIR="/home/ubuntu/app"
APP_NAME="ec2-app"

echo "Starting deployment..."

cd "$APP_DIR"

echo "Installing dependencies..."
npm install --production

echo "Checking PM2 process..."
if pm2 describe "$APP_NAME" > /dev/null 2>&1; then
  echo "Restarting existing app..."
  pm2 restart "$APP_NAME"
else
  echo "Starting app for the first time..."
  pm2 start app.js --name "$APP_NAME"
fi

echo "Deployment completed successfully."
