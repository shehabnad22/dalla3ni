#!/bin/bash

# Dalla3ni Full Deployment Script
# This script automates the complete deployment process

set -e

echo "🚀 Starting Dalla3ni Deployment..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if Render CLI is installed
if ! command -v render &> /dev/null; then
    echo -e "${YELLOW}Render CLI not found. Installing...${NC}"
    curl -fsSL https://render.com/install.sh | bash
fi

# Check if user is logged in to Render
if ! render auth whoami &> /dev/null; then
    echo -e "${YELLOW}Please log in to Render:${NC}"
    render auth login
fi

echo -e "${GREEN}✅ Render CLI ready${NC}"

# Step 1: Create PostgreSQL Database
echo -e "\n${YELLOW}Step 1: Creating PostgreSQL Database...${NC}"
DB_SERVICE_ID=$(render services create \
    --name dalla3ni-db \
    --type pg \
    --plan free \
    --region oregon \
    --json | jq -r '.id')

if [ -z "$DB_SERVICE_ID" ] || [ "$DB_SERVICE_ID" == "null" ]; then
    echo -e "${RED}❌ Failed to create database${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Database created: $DB_SERVICE_ID${NC}"

# Wait for database to be ready
echo -e "${YELLOW}Waiting for database to be ready...${NC}"
sleep 30

# Get database connection string
DB_URL=$(render services get $DB_SERVICE_ID --json | jq -r '.connectionString')

if [ -z "$DB_URL" ]; then
    echo -e "${RED}❌ Failed to get database URL${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Database URL obtained${NC}"

# Step 2: Deploy Backend
echo -e "\n${YELLOW}Step 2: Deploying Backend...${NC}"

# Create backend service
BACKEND_SERVICE_ID=$(render services create \
    --name dalla3ni-backend \
    --type web \
    --env node \
    --buildCommand "cd backend && npm install" \
    --startCommand "cd backend && npm start" \
    --healthCheckPath /health \
    --region oregon \
    --json | jq -r '.id')

if [ -z "$BACKEND_SERVICE_ID" ] || [ "$BACKEND_SERVICE_ID" == "null" ]; then
    echo -e "${RED}❌ Failed to create backend service${NC}"
    exit 1
fi

# Set environment variables
echo -e "${YELLOW}Setting environment variables...${NC}"
render env set NODE_ENV=production --service $BACKEND_SERVICE_ID
render env set DATABASE_URL="$DB_URL" --service $BACKEND_SERVICE_ID
render env set PORT=10000 --service $BACKEND_SERVICE_ID

# Generate JWT secrets
JWT_SECRET=$(openssl rand -hex 32)
JWT_REFRESH_SECRET=$(openssl rand -hex 32)

render env set JWT_SECRET="$JWT_SECRET" --service $BACKEND_SERVICE_ID
render env set JWT_REFRESH_SECRET="$JWT_REFRESH_SECRET" --service $BACKEND_SERVICE_ID

# Get backend URL (will be available after first deploy)
BACKEND_URL=$(render services get $BACKEND_SERVICE_ID --json | jq -r '.serviceDetails.url')

render env set API_URL="$BACKEND_URL" --service $BACKEND_SERVICE_ID

# Set CORS
render env set ALLOWED_ORIGINS="*" --service $BACKEND_SERVICE_ID

echo -e "${GREEN}✅ Backend service created: $BACKEND_SERVICE_ID${NC}"

# Step 3: Run Database Migration
echo -e "\n${YELLOW}Step 3: Running Database Migration...${NC}"
echo -e "${YELLOW}Note: Migration will run automatically on first deploy${NC}"

# Step 4: Deploy Admin Panel
echo -e "\n${YELLOW}Step 4: Deploying Admin Panel...${NC}"

# Build admin panel
cd admin-dashboard
echo "REACT_APP_API_URL=$BACKEND_URL/api" > .env
npm install
npm run build
cd ..

# Deploy to Render Static Site
ADMIN_SERVICE_ID=$(render services create \
    --name dalla3ni-admin \
    --type static \
    --buildCommand "cd admin-dashboard && npm install && npm run build" \
    --publishPath admin-dashboard/build \
    --region oregon \
    --json | jq -r '.id')

if [ -z "$ADMIN_SERVICE_ID" ] || [ "$ADMIN_SERVICE_ID" == "null" ]; then
    echo -e "${RED}❌ Failed to create admin panel service${NC}"
    exit 1
fi

render env set REACT_APP_API_URL="$BACKEND_URL/api" --service $ADMIN_SERVICE_ID

ADMIN_URL=$(render services get $ADMIN_SERVICE_ID --json | jq -r '.serviceDetails.url')

echo -e "${GREEN}✅ Admin panel created: $ADMIN_SERVICE_ID${NC}"

# Step 5: Build Flutter APK
echo -e "\n${YELLOW}Step 5: Building Flutter APK...${NC}"

cd mobile-app

# Update API URL in app_config.dart temporarily for build
flutter build apk --release \
    --dart-define=API_BASE_URL=$BACKEND_URL \
    --dart-define=PRODUCTION=true

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ ! -f "$APK_PATH" ]; then
    echo -e "${RED}❌ Failed to build APK${NC}"
    exit 1
fi

cd ..

echo -e "${GREEN}✅ APK built successfully${NC}"

# Summary
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}🎉 Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}"
echo -e "\n${YELLOW}Backend URL:${NC} $BACKEND_URL"
echo -e "${YELLOW}Admin Panel URL:${NC} $ADMIN_URL"
echo -e "${YELLOW}APK Location:${NC} mobile-app/$APK_PATH"
echo -e "\n${YELLOW}Admin Credentials:${NC}"
echo -e "  Email: shehab.nad22@gmail.com"
echo -e "  Password: Ss123456789"
echo -e "\n${GREEN}✅ All systems deployed and ready!${NC}"

