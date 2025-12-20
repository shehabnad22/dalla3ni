# Production Configuration Guide

This document outlines the production-ready configuration for the Dalla3ni application.

## Backend Configuration

### Environment Variables

The backend uses the following environment variables (set these in Render or your production environment):

```bash
# Server Configuration
PORT=10000  # Render will set this automatically, but you can override
NODE_ENV=production

# Database (Render PostgreSQL)
DATABASE_URL=postgresql://user:password@host:port/database  # Set by Render automatically

# For local development (optional)
DATABASE_URL_LOCAL=postgresql://user:password@localhost:5432/dalla3ni

# API Configuration
API_URL=https://your-backend-url.onrender.com  # Your Render backend URL

# CORS Configuration (comma-separated list)
ALLOWED_ORIGINS=https://your-admin-dashboard.com,https://your-mobile-app-domain.com

# JWT Secrets (CHANGE IN PRODUCTION!)
JWT_SECRET=your_strong_jwt_secret_key_here
JWT_REFRESH_SECRET=your_strong_jwt_refresh_secret_key_here
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# Feature Flags
STORES_ENABLED=false
CENTERS_ENABLED=false

# Commission Settings
COMMISSION_AMOUNT=2500
DEBT_THRESHOLD=50
```

### Key Changes Made

1. **Database Configuration**: Now uses `DATABASE_URL` in production (Render-compatible), falls back to `DATABASE_URL_LOCAL` for local development
2. **CORS**: Configurable via `ALLOWED_ORIGINS` environment variable
3. **Port**: Uses `process.env.PORT` (Render-compatible)
4. **Swagger**: Uses `API_URL` environment variable instead of hardcoded localhost

## Flutter Mobile App Configuration

### Production Build

To build for production with the production API URL:

```bash
# Android Release Build
flutter build apk --release --dart-define=API_BASE_URL=https://your-backend-url.onrender.com --dart-define=PRODUCTION=true

# iOS Release Build
flutter build ios --release --dart-define=API_BASE_URL=https://your-backend-url.onrender.com --dart-define=PRODUCTION=true
```

### Development Build

For local development (Android emulator):
```bash
flutter run
# Uses default: http://10.0.2.2:3000
```

For local development (real device):
```bash
# Update app_config.dart baseUrl to your computer's IP
# Or use: flutter run --dart-define=API_BASE_URL=http://192.168.1.20:3000
```

### Configuration Details

- **Base URL**: Configurable via `--dart-define=API_BASE_URL=...` build flag
- **Production Mode**: Set via `--dart-define=PRODUCTION=true`
- **Default**: Falls back to `http://10.0.2.2:3000` for Android emulator development

## Admin Dashboard Configuration

### Environment Variables

Create a `.env` file in the `admin-dashboard` directory:

```bash
REACT_APP_API_URL=https://your-backend-url.onrender.com/api
REACT_APP_STORES_ENABLED=false
```

### Build Commands

```bash
# Development
npm start

# Production Build
npm run build
```

The built files will be in the `build/` directory and can be deployed to any static hosting service.

## Deployment Checklist

### Backend (Render)

- [ ] Set all environment variables in Render dashboard
- [ ] Ensure `DATABASE_URL` is set (automatically set by Render for PostgreSQL)
- [ ] Set `NODE_ENV=production`
- [ ] Set `API_URL` to your Render backend URL
- [ ] Configure `ALLOWED_ORIGINS` with your frontend URLs
- [ ] Update JWT secrets to strong, random values
- [ ] Test database connection
- [ ] Verify health endpoint: `https://your-backend-url.onrender.com/health`

### Flutter App

- [ ] Build release APK/AAB with production API URL
- [ ] Test on real device with production API
- [ ] Verify all API calls work correctly
- [ ] Check that no debug banners appear
- [ ] Verify splash screen and app icons are production-ready
- [ ] Test offline functionality (if applicable)

### Admin Dashboard

- [ ] Set `REACT_APP_API_URL` environment variable
- [ ] Build production bundle: `npm run build`
- [ ] Deploy `build/` folder to hosting service
- [ ] Test all admin panel features with production API
- [ ] Verify CORS allows admin dashboard origin

## Testing Production Setup

1. **Backend Health Check**:
   ```bash
   curl https://your-backend-url.onrender.com/health
   ```

2. **API Endpoints**:
   - Test authentication endpoints
   - Test order creation
   - Test driver registration
   - Verify all endpoints return expected responses

3. **Mobile App**:
   - Install release build on device
   - Test customer registration
   - Test order creation
   - Test driver login
   - Verify all API calls succeed

4. **Admin Dashboard**:
   - Access admin panel
   - Test login
   - Verify data loads correctly
   - Test all CRUD operations

## Security Notes

- ✅ All hardcoded localhost/IP references removed
- ✅ CORS configured via environment variables
- ✅ Database connection uses environment variables only
- ✅ JWT secrets should be strong and unique
- ✅ Debug-only code removed from Flutter app
- ✅ Production builds use release mode

## Troubleshooting

### Backend Issues

- **Database Connection Failed**: Check `DATABASE_URL` is set correctly
- **CORS Errors**: Verify `ALLOWED_ORIGINS` includes your frontend URLs
- **Port Issues**: Render sets `PORT` automatically, don't override unless needed

### Flutter App Issues

- **API Calls Failing**: Verify `API_BASE_URL` is set correctly in build command
- **Connection Refused**: Check backend URL is accessible and CORS is configured
- **Build Errors**: Ensure all environment variables are set correctly

### Admin Dashboard Issues

- **API Calls Failing**: Check `REACT_APP_API_URL` is set in `.env` file
- **CORS Errors**: Verify backend `ALLOWED_ORIGINS` includes admin dashboard URL

