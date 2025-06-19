@echo off
setlocal enabledelayedexpansion

echo ======================================
echo Discord Slot Farmer - Setup and Build
echo ======================================

:: Check Python version
python --version > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo Error: Python not found in PATH.
    echo Please install Python 3.7+ and ensure it's added to your PATH.
    pause
    exit /b 1
)

:: Create images directory if it doesn't exist
if not exist "images" (
    echo Creating images directory...
    mkdir images
)

:: Setup virtual environment
if exist venv (
    echo Virtual environment already exists.
    choice /C YN /M "Recreate it (Y) or use existing (N)?"
    if !ERRORLEVEL! EQU 1 (
        echo Recreating virtual environment...
        rmdir /s /q venv
        python -m venv venv
    )
) else (
    echo Creating virtual environment...
    python -m venv venv
)

:: Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to activate virtual environment.
    pause
    exit /b 1
)

:: Install requirements
echo Installing requirements...
pip install -r requirements.txt
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to install requirements.
    echo Trying again with --no-cache-dir option...
    pip install --no-cache-dir -r requirements.txt
    if %ERRORLEVEL% NEQ 0 (
        echo Error: Failed to install requirements.
        pause
        exit /b 1
    )
)

:: Build executable
echo Building executable...
python -m PyInstaller --onefile --windowed --name=DiscordSlotFarmer slot_farmer.py
if %ERRORLEVEL% NEQ 0 (
    echo Error: Failed to build executable.
    pause
    exit /b 1
)

:: Copy config template and images
echo Setting up initial configuration...
if not exist "dist\images" (
    mkdir "dist\images"
)

:: Copy any existing button images to the dist folder
if exist "images\*.png" (
    copy "images\*.png" "dist\images\"
)
if exist "images\*.bmp" (
    copy "images\*.bmp" "dist\images\"
)
if exist "images\*.jpg" (
    copy "images\*.jpg" "dist\images\"
)

:: Create a simple README in the dist folder
echo Creating quick-start guide...
echo Discord Slot Farmer - Quick Start > "dist\README.txt"
echo 1. Run DiscordSlotFarmer.exe >> "dist\README.txt"
echo 2. Go to Settings tab and capture a button image >> "dist\README.txt" 
echo 3. Test Discord detection and button recognition >> "dist\README.txt"
echo 4. Adjust settings as needed >> "dist\README.txt"
echo 5. Click Start to begin farming >> "dist\README.txt"

echo ======================================
echo Build completed successfully!
echo Executable is in the 'dist' folder.
echo ======================================
pause
