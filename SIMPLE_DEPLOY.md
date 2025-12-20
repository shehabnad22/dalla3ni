# 🚀 Simple 5-Minute Deployment

## What You Need
- A Render account (free): https://render.com (sign up if needed)
- 5 minutes of your time

## Step-by-Step (Copy-Paste Ready)

### 1. Create Database (1 minute)
1. Go to: https://render.com/dashboard
2. Click **"New +"** → **"PostgreSQL"**
3. Name: `dalla3ni-db`
4. Plan: **Free**
5. Click **"Create Database"**
6. **WAIT 2 minutes** for it to start
7. Copy the **"Internal Database URL"** (looks like: `postgresql://user:pass@host:5432/db`)

### 2. Deploy Backend (2 minutes)
1. Still in Render dashboard, click **"New +"** → **"Web Service"**
2. Connect your GitHub repo (or use "Public Git repository" and paste your repo URL)
3. Settings:
   - **Name**: `dalla3ni-backend`
   - **Root Directory**: `backend`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
4. Click **"Advanced"** → **"Add Environment Variable"**
5. Add these variables (one by one):
   ```
   NODE_ENV = production
   DATABASE_URL = <paste the Internal Database URL from Step 1>
   PORT = 10000
   JWT_SECRET = any-random-string-here-make-it-long
   JWT_REFRESH_SECRET = another-random-string-here-make-it-long
   ALLOWED_ORIGINS = *
   ```
6. Click **"Create Web Service"**
7. **WAIT 3-5 minutes** for deployment
8. Copy your **Service URL** (e.g., `https://dalla3ni-backend.onrender.com`)
9. Go back to Environment Variables and add:
   ```
   API_URL = <your-service-url>
   ```

### 3. Run Migration (30 seconds)
1. In your backend service, click **"Shell"** tab
2. Run:
   ```bash
   cd backend
   npm run migrate
   ```
3. Wait for "✅ Migration completed"

### 4. Deploy Admin Panel (1 minute)
1. Click **"New +"** → **"Static Site"**
2. Connect same GitHub repo
3. Settings:
   - **Name**: `dalla3ni-admin`
   - **Root Directory**: `admin-dashboard`
   - **Build Command**: `npm install && npm run build`
   - **Publish Directory**: `build`
4. Add Environment Variable:
   ```
   REACT_APP_API_URL = <your-backend-url>/api
   ```
5. Click **"Create Static Site"**
6. **WAIT 2-3 minutes**
7. Copy your **Admin Panel URL**

### 5. Build APK (30 seconds on your computer)
On your local machine:
```bash
cd mobile-app
flutter build apk --release \
  --dart-define=API_BASE_URL=<your-backend-url> \
  --dart-define=PRODUCTION=true
```

APK location: `mobile-app/build/app/outputs/flutter-apk/app-release.apk`

## ✅ Done!

You now have:
- ✅ Backend URL: `https://dalla3ni-backend.onrender.com`
- ✅ Admin Panel URL: `https://dalla3ni-admin.onrender.com`
- ✅ APK ready to install

## Test It

1. **Backend**: Visit `https://your-backend.onrender.com/health` (should show "ok")
2. **Admin Panel**: Visit your admin URL, login with:
   - Email: `shehab.nad22@gmail.com`
   - Password: `Ss123456789`
3. **APK**: Install on your phone and test

## That's It! 🎉

If anything fails, check the logs in Render dashboard.

