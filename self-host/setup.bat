@echo off
setlocal

echo === LIDNS Setup ===

:: Check Docker Desktop is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker Desktop is not installed or not running.
    echo Download it from: https://www.docker.com/products/docker-desktop/
    echo Install it, start it, then re-run this script.
    pause
    exit /b 1
)

:: Check Docker is running
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker Desktop is installed but not running.
    echo Start Docker Desktop from the Start menu, wait for it to finish loading, then re-run this script.
    pause
    exit /b 1
)

echo Docker is running.

:: Move to the directory this script lives in
cd /d "%~dp0"

echo Building and starting LIDNS...
docker compose up -d --build
if %errorlevel% neq 0 (
    echo Something went wrong. Check the output above.
    pause
    exit /b 1
)

echo.
echo === Done ===
echo Run this to watch startup output:
echo   docker compose logs -f
echo.
echo The server IP and port status will appear in the logs.
echo.

:: Note about port 53 on Windows
echo NOTE: Windows DNS Client may be using port 53.
echo If CoreDNS fails to start, open Services (services.msc),
echo find "DNS Client", set it to Manual, and stop it.
echo Then run: docker compose restart
echo.

pause
