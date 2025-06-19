# Discord Slot Farmer (Python Edition)

An enhanced Python-based tool for automating Discord slot games. This version is designed to be more portable across different screen resolutions and Discord configurations.

## 🚀 Features

- **Cross-Resolution Support**: Works on any screen resolution through relative positioning
- **Dynamic Button Detection**: Uses computer vision to find the "Spin Again" button
- **Screenshot Capture Tool**: Built-in tool to capture the button image on your setup
- **Configurable Settings**: Adjust timings, bet amounts, and detection confidence
- **Visual Debugging**: Test Discord detection and button recognition
- **Customizable Message Box Location**: Configure input location for any Discord layout
- **User-Friendly Interface**: Tabbed UI with status indicators and controls

## 📋 Requirements

- Windows 10/11
- Python 3.7+
- Dependencies: PyQt5, OpenCV, numpy, pyautogui, pygetwindow, pywin32 (for Windows)

## 🛠 Installation

1. **Install Python**
   - Download and install [Python 3.7+](https://www.python.org/downloads/)
   - Ensure you check "Add Python to PATH" during installation

2. **Setup (Automatic)**
   - Run `build.bat` to set up a virtual environment and install dependencies
   ```
   build.bat
   ```

3. **Setup (Manual)**
   - Install dependencies:
   ```
   pip install -r requirements.txt
   ```

## 🚦 Usage

1. **Start the Application**
   - Run `DiscordSlotFarmer.exe` (if built with PyInstaller)
   - Or run from source:
   ```
   python slot_farmer.py
   ```

2. **Setup Button Detection**
   - Go to the "Settings" tab
   - Click "Capture Image" and select the "Spin Again" button in Discord
   - Or use "Add Image" to add an existing image of the button

3. **Calibrate Message Box Location**
   - Still in the "Settings" tab, adjust the message input box position
   - Use the sliders to set the X and Y ratios
   - Test with "Test Message Box Click" to verify it clicks the correct location

4. **Test Detection**
   - On the "Main" tab, click "Test Discord" to ensure Discord is detected
   - Click "Test Button Detection" to check if the button is recognized

5. **Configure Settings**
   - Set the "Click Interval" (typically 7 seconds for slots)
   - Set the "Respawn Interval" (how often to restart when button isn't found)
   - Adjust the "Bet Amount" for your slots command
   - Set "Detection Confidence" (lower = more lenient matching)

6. **Start Farming**
   - Click "Start Auto-Click" to begin the automated process
   - The app will click the button when found, or respawn when needed
   - Stats are tracked in the status area

## 🔄 How It Works

1. **Window Detection**: Finds the Discord window using window title
2. **Button Search**: Takes a screenshot of Discord and searches for the button image
3. **Clicking**: When found, moves cursor to button and clicks
4. **Respawning**: If button isn't found for a set time, performs these steps:
   - Clicks message input area (position calculated based on window size)
   - Types `/slots [bet amount]` and presses Enter
   - Types `/shop icons` twice to get ephemeral messages
   - Scrolls up slightly to freeze chat position

## 🔧 Troubleshooting

If the script isn't working:

1. **Button Detection Issues**
   - Capture a new image of the button using the "Capture Image" tool
   - Lower the confidence threshold if detection is too strict
   - Ensure Discord theme/zoom hasn't changed

2. **Clicking Wrong Location**
   - Adjust the message box location using the sliders in Settings
   - Test with "Test Message Box Click" to verify

3. **Discord Not Detected**
   - Ensure Discord is running and visible
   - Try setting Discord as your active window before starting

4. **Dependencies Issues**
   - If you get import errors, run:
   ```
   pip install -r requirements.txt
   ```

5. **Debug Mode**
   - Enable "Debug Mode" for additional console output and visual feedback

## 🔒 Safety Notes

- This tool uses image recognition and does not modify Discord in any way
- However, automation tools may violate Discord's Terms of Service
- Use at your own discretion and risk