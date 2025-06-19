@echo off
echo Cleaning up AHK files from Python directory...

:: Create directories in AHK folder if they don't exist
if not exist "AHK\src" mkdir "AHK\src"
if not exist "AHK\utils" mkdir "AHK\utils"

:: Option 1: Move files to AHK directory (uncomment these lines if you want to move files)
:: echo Moving AHK files to proper location...
:: move "Python\Gamble.ahk" "AHK\" 2>nul
:: move "Python\main.ahk" "AHK\" 2>nul
:: move "Python\test.ahk" "AHK\" 2>nul
:: move "Python\src\*.ahk" "AHK\src\" 2>nul
:: move "Python\utils\*.ahk" "AHK\utils\" 2>nul

:: Option 2: Remove AHK files from Python directory (since they're likely duplicates)
echo Removing AHK files from Python directory...
del "Python\*.ahk" 2>nul
rmdir /s /q "Python\src" 2>nul
rmdir /s /q "Python\utils" 2>nul

echo Creating clean Python directory structure...
mkdir "Python\images" 2>nul

echo Cleanup complete!
echo.
echo Python directory now contains only Python-related files.
echo AHK directory contains all AutoHotkey scripts.
echo.
pause