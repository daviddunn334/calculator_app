@echo off
REM Deployment script for NDT-ToolKit with custom landing page
REM This script builds the Flutter app and sets up the landing page

echo ========================================
echo NDT-ToolKit Deployment Script
echo ========================================
echo.

echo [1/6] Preparing Flutter web build (swap landing page)...
if not exist "web\app.html" (
    echo ERROR: web\app.html not found!
    exit /b 1
)
copy /Y "web\index.html" "web\index.landing.html" >nul
copy /Y "web\app.html" "web\index.html" >nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to swap landing page for Flutter build!
    exit /b 1
)
echo ✓ Landing page swapped for Flutter build
echo.

echo [2/6] Building Flutter web app...
call flutter build web
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter build failed!
    copy /Y "web\index.landing.html" "web\index.html" >nul
    exit /b 1
)
echo ✓ Flutter build completed
echo.

echo [3/6] Restoring landing page after build...
copy /Y "web\index.landing.html" "web\index.html" >nul
del /Q "web\index.landing.html" >nul 2>&1
echo ✓ Landing page restored
echo.

echo [4/6] Backing up Flutter's index.html as app.html...
copy /Y "build\web\index.html" "build\web\app.html"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to copy app.html!
    exit /b 1
)
echo ✓ Flutter app saved as app.html
echo.

echo [5/6] Copying custom landing page...
copy /Y "web\index.html" "build\web\index.html"
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to copy landing page!
    exit /b 1
)
echo ✓ Landing page installed
echo.

echo [6/6] Copying assets to build directory...
if not exist "build\web\icons" mkdir "build\web\icons"
copy /Y "web\icons\logo_main.png" "build\web\icons\logo_main.png" 2>nul
echo ✓ Assets copied
echo.

echo [7/7] Deploying to Firebase...
call firebase deploy --only hosting
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Firebase deployment failed!
    exit /b 1
)
echo.

echo ========================================
echo ✓ Deployment completed successfully!
echo ========================================
echo.
echo Your site is now live:
echo - Landing page: https://ndt-toolkit.web.app/
echo - App: https://ndt-toolkit.web.app/app
echo.
pause
