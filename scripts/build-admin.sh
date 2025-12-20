#!/bin/bash

# Build Admin Dashboard for Production

echo "========================================"
echo "Building Admin Dashboard"
echo "========================================"
echo

cd admin-dashboard

echo "Step 1: Installing dependencies..."
npm install
if [ $? -ne 0 ]; then
    echo "❌ npm install failed!"
    exit 1
fi
echo

echo "Step 2: Building production bundle..."
npm run build
if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi
echo

echo "✅ Build complete!"
echo
echo "Build folder: admin-dashboard/build"
echo
echo "To serve the build locally:"
echo "  Option 1: Use serve package"
echo "    cd admin-dashboard"
echo "    npx serve -s build -p 3001"
echo
echo "  Option 2: Use http-server"
echo "    cd admin-dashboard"
echo "    npx http-server build -p 3001"
echo

