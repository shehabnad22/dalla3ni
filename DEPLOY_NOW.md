# 🚀 Quick Deployment Guide

## Option 1: Automated Script (Recommended)

1. **Install Render CLI** (if not installed):
   ```bash
   curl -fsSL https://render.com/install.sh | bash
   ```

2. **Login to Render**:
   ```bash
   render auth login
   ```

3. **Run Deployment Script**:
   ```bash
   chmod +x deploy.sh
   ./deploy.sh
   ```

The script will:
- Create PostgreSQL database
- Deploy backend
- Run migrations
- Deploy admin panel
- Build Flutter APK

## Option 2: Manual Deployment via Render Dashboard

### Step 1: Create Database
1. Go to https://render.com/dashboard
2. Click "New +" → "PostgreSQL"
3. Name: `dalla3ni-db`
4. Plan: Free
5. Click "Create Database"
6. Copy the **Internal Database URL**

### Step 2: Deploy Backend
1. Click "New +" → "Web Service"
2. Connect your GitHub repository
3. Settings:
   - **Name**: `dalla3ni-backend`
   - **Root Directory**: `backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
4. Environment Variables:
   ```
   NODE_ENV=production
   DATABASE_URL=<paste from Step 1>
   PORT=10000
   JWT_SECRET=<generate random string>
   JWT_REFRESH_SECRET=<generate random string>
   API_URL=<will be auto-set after deploy>
   ALLOWED_ORIGINS=*
   ```
5. Click "Create Web Service"
6. Wait for deployment
7. Copy the **Service URL** (e.g., `https://dalla3ni-backend.onrender.com`)
8. Update `API_URL` environment variable with this URL

### Step 3: Run Migration
1. In Render dashboard, go to your backend service
2. Click "Shell" tab
3. Run:
   ```bash
   cd backend
   npm run migrate
   ```

### Step 4: Deploy Admin Panel
1. Click "New +" → "Static Site"
2. Connect your GitHub repository
3. Settings:
   - **Name**: `dalla3ni-admin`
   - **Root Directory**: `admin-dashboard`
   - **Build Command**: `npm install && npm run build`
   - **Publish Directory**: `build`
4. Environment Variables:
   ```
   REACT_APP_API_URL=<your-backend-url>/api
   ```
5. Click "Create Static Site"

### Step 5: Build Flutter APK
On your local machine:
```bash
cd mobile-app
flutter build apk --release \
  --dart-define=API_BASE_URL=<your-backend-url> \
  --dart-define=PRODUCTION=true
```

APK will be at: `mobile-app/build/app/outputs/flutter-apk/app-release.apk`

## Option 3: GitHub Actions (Fully Automated)

I've created GitHub Actions workflows that will automatically deploy on push to main branch.

Just push your code to GitHub and deployments will happen automatically!

---

## 📋 After Deployment

### Test Backend
```bash
curl https://your-backend.onrender.com/health
```

### Test Admin Panel
1. Go to your admin panel URL
2. Login with:
   - Email: `shehab.nad22@gmail.com`
   - Password: `Ss123456789`

### Install APK
1. Transfer `app-release.apk` to your Android device
2. Enable "Install from Unknown Sources"
3. Install the APK
4. Test the app

---

## ✅ Deployment Checklist

- [ ] Database created and running
- [ ] Backend deployed and accessible
- [ ] Database migration completed
- [ ] Admin panel deployed and accessible
- [ ] Admin login works
- [ ] Flutter APK built with production API URL
- [ ] APK tested on device

---

**Need Help?** Check the logs in Render dashboard if anything fails.

