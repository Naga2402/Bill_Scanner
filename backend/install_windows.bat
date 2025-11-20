@echo off
echo ========================================
echo Bill Scanner Backend - Windows Install
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Python is not installed or not in PATH
    echo Please install Python 3.8+ from https://www.python.org/
    pause
    exit /b 1
)

echo Step 1: Upgrading pip and setuptools...
python -m pip install --upgrade pip setuptools wheel

echo.
echo Step 2: Installing psycopg2-binary with pre-built wheels...
echo This avoids needing Microsoft C++ Build Tools
echo.

REM Try to install psycopg2-binary using pre-built wheels only
python -m pip install psycopg2-binary --only-binary :all: --no-cache-dir

if errorlevel 1 (
    echo.
    echo ========================================
    echo Installation failed!
    echo ========================================
    echo.
    echo Option 1: Install Microsoft C++ Build Tools
    echo Download from: https://visualstudio.microsoft.com/visual-cpp-build-tools/
    echo Then run this script again.
    echo.
    echo Option 2: Use alternative PostgreSQL adapter (pg8000)
    echo This is a pure Python implementation that doesn't require compilation.
    echo.
    set /p choice="Do you want to use pg8000 instead? (y/n): "
    if /i "%choice%"=="y" (
        echo Installing pg8000...
        python -m pip install pg8000
        echo.
        echo NOTE: You'll need to update app.py to use pg8000 instead of psycopg2
        echo See backend/README_WINDOWS.md for instructions
    ) else (
        echo.
        echo Please install Microsoft C++ Build Tools and try again.
        echo Download: https://visualstudio.microsoft.com/visual-cpp-build-tools/
    )
    pause
    exit /b 1
)

echo.
echo Step 3: Installing other dependencies...
python -m pip install -r requirements.txt

if errorlevel 1 (
    echo.
    echo Some dependencies failed to install. Check the error above.
    pause
    exit /b 1
)

echo.
echo ========================================
echo Installation successful!
echo ========================================
echo.
echo Next steps:
echo 1. Copy .env.example to .env
echo 2. Edit .env with your database credentials
echo 3. Run: python app.py
echo.
pause

