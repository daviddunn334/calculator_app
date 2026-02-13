#!/bin/bash
# Deployment script for NDT-ToolKit with custom landing page
# This script builds the Flutter app and sets up the landing page

echo "========================================"
echo "NDT-ToolKit Deployment Script"
echo "========================================"
echo ""

echo "[1/6] Preparing Flutter web build (swap landing page)..."
if [ ! -f "web/app.html" ]; then
    echo "ERROR: web/app.html not found!"
    exit 1
fi
cp -f "web/index.html" "web/index.landing.html"
cp -f "web/app.html" "web/index.html"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to swap landing page for Flutter build!"
    exit 1
fi
echo "✓ Landing page swapped for Flutter build"
echo ""

echo "[2/6] Building Flutter web app..."
flutter build web
if [ $? -ne 0 ]; then
    echo "ERROR: Flutter build failed!"
    cp -f "web/index.landing.html" "web/index.html"
    exit 1
fi
echo "✓ Flutter build completed"
echo ""

echo "[3/6] Restoring landing page after build..."
cp -f "web/index.landing.html" "web/index.html"
rm -f "web/index.landing.html"
echo "✓ Landing page restored"
echo ""

echo "[4/6] Backing up Flutter's index.html as app.html..."
cp -f "build/web/index.html" "build/web/app.html"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to copy app.html!"
    exit 1
fi
echo "✓ Flutter app saved as app.html"
echo ""

echo "[5/6] Copying custom landing page..."
cp -f "web/index.html" "build/web/index.html"
if [ $? -ne 0 ]; then
    echo "ERROR: Failed to copy landing page!"
    exit 1
fi
echo "✓ Landing page installed"
echo ""

echo "[6/6] Copying assets to build directory..."
mkdir -p "build/web/icons"
cp -f "web/icons/logo_main.png" "build/web/icons/logo_main.png" 2>/dev/null || true
echo "✓ Assets copied"
echo ""

echo "[7/7] Deploying to Firebase..."
firebase deploy --only hosting
if [ $? -ne 0 ]; then
    echo "ERROR: Firebase deployment failed!"
    exit 1
fi
echo ""

echo "========================================"
echo "✓ Deployment completed successfully!"
echo "========================================"
echo ""
echo "Your site is now live:"
echo "- Landing page: https://ndt-toolkit.web.app/"
echo "- App: https://ndt-toolkit.web.app/app"
echo ""
