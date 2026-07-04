@echo off
setlocal enabledelayedexpansion
title Office Monitoring System - Setup

echo.
echo  =====================================================
echo       Office Monitoring System - One Click Setup
echo  =====================================================
echo.

:: ==========================================
:: Configuration
:: ==========================================
set REPO_URL=https://github.com/risatnum/Techathon2026-TeamDambiriyani.git
set PROJECT_DIR=Techathon2026-TeamDambiriyani
set ENV_GIST_URL=https://gist.githubusercontent.com/risatnum/0cfb7563128a8f9bfc4f4b3781f02197/raw/6c197a10ef14e69d768c747a9a016148340a8563/.env
set DISCORD_INVITE_URL=https://url-shortener.me/NSPX

:: -----------------------------------------------
:: 0. Check Prerequisites (Git, Python, Node.js)
:: -----------------------------------------------
echo  [0/6] Checking prerequisites...
echo.
set MISSING=0

where git >nul 2>nul
if errorlevel 1 (
    echo  [!] Git is NOT installed.
    set MISSING=1
    set NEED_GIT=1
) else (
    echo  [OK] Git found.
)

where python >nul 2>nul
if errorlevel 1 (
    echo  [!] Python is NOT installed.
    set MISSING=1
    set NEED_PYTHON=1
) else (
    echo  [OK] Python found.
)

where node >nul 2>nul
if errorlevel 1 (
    echo  [!] Node.js is NOT installed.
    set MISSING=1
    set NEED_NODE=1
) else (
    echo  [OK] Node.js found.
)

if "!MISSING!"=="0" goto PREREQS_OK

echo.
echo  -------------------------------------------------
echo   Some required tools are missing.
echo   This script can install them for you using winget
echo   (Windows Package Manager).
echo  -------------------------------------------------
echo.
set /p INSTALL_CHOICE="  Would you like to install the missing tools? (Y/N): "
if /i "!INSTALL_CHOICE!" neq "y" goto PREREQS_FAIL

if not defined NEED_GIT goto SKIP_GIT
echo.
echo  Installing Git...
winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
if errorlevel 1 (
    echo  [ERROR] Failed to install Git. Install manually: https://git-scm.com/
    pause
    exit /b 1
)
echo  Git installed successfully!
:SKIP_GIT

if not defined NEED_PYTHON goto SKIP_PYTHON
echo.
echo  Installing Python...
winget install --id Python.Python.3.12 -e --accept-source-agreements --accept-package-agreements
if errorlevel 1 (
    echo  [ERROR] Failed to install Python. Install manually: https://www.python.org/
    pause
    exit /b 1
)
echo  Python installed successfully!
:SKIP_PYTHON

if not defined NEED_NODE goto SKIP_NODE
echo.
echo  Installing Node.js LTS...
winget install --id OpenJS.NodeJS.LTS -e --accept-source-agreements --accept-package-agreements
if errorlevel 1 (
    echo  [ERROR] Failed to install Node.js. Install manually: https://nodejs.org/
    pause
    exit /b 1
)
echo  Node.js installed successfully!
:SKIP_NODE

echo.
echo  =====================================================
echo   All tools installed! Please CLOSE this window and
echo   DOUBLE-CLICK the script again to continue setup.
echo  =====================================================
echo.
echo  (A restart is needed so your system recognizes the
echo   newly installed programs.)
echo.
pause
exit /b 0

:PREREQS_FAIL
echo.
echo  [ERROR] Cannot continue without the required tools.
echo  Please install them manually and run this script again.
echo.
echo   Git:     https://git-scm.com/
echo   Python:  https://www.python.org/
echo   Node.js: https://nodejs.org/
echo.
pause
exit /b 1

:PREREQS_OK
echo.
echo  All prerequisites are installed!
echo.

:: -----------------------------------------------
:: 1. Check if the project is already downloaded
:: -----------------------------------------------
if exist "%PROJECT_DIR%" goto SKIP_CLONE
echo  [1/6] Project not found. Downloading from GitHub...
echo.
git clone %REPO_URL% %PROJECT_DIR%
if errorlevel 1 (
    echo.
    echo  [ERROR] Failed to clone repository.
    pause
    exit /b 1
)
echo.
echo  Download complete!
goto AFTER_CLONE

:SKIP_CLONE
echo  [1/6] Project already downloaded. Skipping.

:AFTER_CLONE
cd "%PROJECT_DIR%"

:: -----------------------------------------------
:: 2. Download .env file for the Discord bot
:: -----------------------------------------------
echo.
if exist "bot\.env" goto SKIP_ENV
echo  [2/6] Downloading environment config for Discord Bot...
powershell -Command "Invoke-WebRequest -Uri '%ENV_GIST_URL%' -OutFile 'bot\.env'"
if errorlevel 1 (
    echo  [WARNING] Could not download .env file. The Discord Bot may not work.
) else (
    echo  Environment config downloaded and placed in bot\ folder.
)
goto AFTER_ENV

:SKIP_ENV
echo  [2/6] Bot environment config already exists. Skipping.

:AFTER_ENV

:: -----------------------------------------------
:: 3. Setup Backend (FastAPI)
:: -----------------------------------------------
echo.
echo  [3/6] Setting up Backend...
if exist "backend\venv" goto SKIP_BACKEND_INSTALL
echo  Creating virtual environment for backend...
python -m venv backend\venv
echo  Installing backend dependencies...
backend\venv\Scripts\pip install -r backend\requirements.txt
goto START_BACKEND

:SKIP_BACKEND_INSTALL
echo  Backend dependencies already installed. Skipping.

:START_BACKEND
echo  Starting Backend...
start "Backend" cmd /k "title Backend & call backend\venv\Scripts\activate & cd backend & uvicorn app.main:socket_app --host 0.0.0.0 --port 8000"

:: -----------------------------------------------
:: 4. Setup Simulator
:: -----------------------------------------------
echo.
echo  [4/6] Setting up Simulator...
if exist "simulator\venv" goto SKIP_SIM_INSTALL
echo  Creating virtual environment for simulator...
python -m venv simulator\venv
echo  Installing simulator dependencies...
simulator\venv\Scripts\pip install -r simulator\requirements.txt
goto START_SIM

:SKIP_SIM_INSTALL
echo  Simulator dependencies already installed. Skipping.

:START_SIM
echo  Starting Simulator...
start "Simulator" cmd /k "title Simulator & call simulator\venv\Scripts\activate & cd simulator & python main.py"

:: -----------------------------------------------
:: 5. Setup Frontend (React + Vite)
:: -----------------------------------------------
echo.
echo  [5/6] Setting up Frontend Dashboard...
if exist "frontend\node_modules" goto SKIP_FRONTEND_INSTALL
echo  Installing frontend dependencies...
cd frontend
call npm install
cd ..
goto START_FRONTEND

:SKIP_FRONTEND_INSTALL
echo  Frontend dependencies already installed. Skipping.

:START_FRONTEND
echo  Starting Frontend...
start "Frontend" cmd /k "title Frontend & cd frontend & npm run dev"

:: -----------------------------------------------
:: 6. Setup Discord Bot
:: -----------------------------------------------
echo.
echo  [6/6] Setting up Discord Bot...
if exist "bot\node_modules" goto SKIP_BOT_INSTALL
echo  Installing bot dependencies...
cd bot
call npm install
cd ..
goto START_BOT

:SKIP_BOT_INSTALL
echo  Bot dependencies already installed. Skipping.

:START_BOT
echo  Starting Discord Bot...
start "Discord Bot" cmd /k "title Discord Bot & cd bot & npm start"

:: -----------------------------------------------
:: 7. Discord Bot Invitation
:: -----------------------------------------------
echo.
echo  =====================================================
echo   Would you like to invite the Discord Bot to your
echo   server to receive live alerts and updates?
echo  =====================================================
echo.
set /p INVITE_CHOICE="  Type Y to invite, or N to skip: "
if /i "!INVITE_CHOICE!"=="y" (
    echo.
    echo  Opening Discord Bot invite link in your browser...
    start %DISCORD_INVITE_URL%
) else (
    echo.
    echo  Got it! Continuing without Discord.
    echo  You won't receive Discord alerts or updates.
)

:: -----------------------------------------------
:: 8. Open the Dashboard
:: -----------------------------------------------
echo.
echo  Waiting 5 seconds for services to start up...
timeout /t 5 /nobreak >nul
echo  Opening dashboard in your default browser...
start http://localhost:5173

echo.
echo  =====================================================
echo   All services are running! You can close this
echo   window, but keep the other terminal windows open.
echo  =====================================================
echo.
pause
