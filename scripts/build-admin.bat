@echo off
REM Build Admin Dashboard for Production

echo ========================================
echo Building Admin Dashboard
echo ========================================
echo.

cd admin-dashboard

echo Step 1: Installing dependencies...
call npm install
if %ERRORLEVEL% NEQ 0 (
    echo ❌ npm install failed!
    pause
    exit /b 1
)
echo.

echo Step 2: Building production bundle...
call npm run build
if %ERRORLEVEL% NEQ 0 (
    echo ❌ Build failed!
    pause
    exit /b 1
)
echo.

echo ✅ Build complete!
echo.
echo Build folder: admin-dashboard\build
echo.
echo To serve the build locally:
echo   Option 1: Use serve package
echo     cd admin-dashboard
echo     npx serve -s build -p 3001
echo.
echo   Option 2: Use http-server
echo     cd admin-dashboard
echo     npx http-server build -p 3001
echo.
pause

