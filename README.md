# Discord Slot Farmer

An automation tool for playing slots in Discord. This project automatically detects and clicks the "Spin Again" button, making it perfect for farming the "Casino Degenerate" role (awarded after 50,000 bets).

## 🎮 How It Works

The bot uses image recognition to find and click the "Spin Again" button in Discord's slot game. If the button isn't found, it automatically restarts the game by:
1. Typing `/slots [amount]` to start a new game
2. Using `/shop icons` to create ephemeral messages (keeps the view stable)
3. Scrolling up to freeze the chat position

This ensures continuous play even when chat messages push the game out of view.

## 📋 Project Structure

This project has two implementations:

1. **AutoHotkey Implementation** (Original)
   - Located in the `AHK` directory
   - Simple, lightweight approach using AutoHotkey scripts
   - Good for single-system use with fixed resolution
   - Includes variants for desktop, laptop, and Firefox

2. **Python Implementation** (Enhanced)
   - Located in the `Python` directory
   - Resolution-independent using computer vision (OpenCV)
   - Cross-compatible with different Discord layouts and zoom levels
   - Includes user-friendly GUI with live stats and settings
   - Features built-in button capture tool

## 🤔 Which Implementation Should I Use?

### Choose AutoHotkey if:
- You want a lightweight solution
- You only need it for a single system with fixed resolution
- You're comfortable with basic script tweaking
- You have AutoHotkey installed or are willing to install it

### Choose Python if:
- You want to share with friends who have different screen resolutions
- You need a user-friendly interface with visual feedback
- You want to easily calibrate for different Discord layouts
- You prefer a more robust solution with features like confidence-based button detection

## 🚀 Quick Start

### AutoHotkey Version:
1. Install [AutoHotkey v2.0+](https://www.autohotkey.com/)
2. Navigate to the `AHK` directory
3. Capture a screenshot of your "Spin Again" button using Windows Snipping Tool
4. Save it as `button.bmp` in the appropriate images directory
5. Run `Gamble.ahk` or the version specific to your setup (laptop/firefox)

### Python Version:
1. Install [Python 3.7+](https://www.python.org/downloads/)
2. Navigate to the `Python` directory
3. Run `build.bat` to set up the environment and build the application
4. Run `dist\DiscordSlotFarmer.exe` or `python slot_farmer.py`
5. Use the built-in button capture tool to create a template image
6. Configure settings and start farming

## 📖 Detailed Documentation

Each implementation has its own detailed README:

- [AutoHotkey Implementation](AHK/README.md)
- [Python Implementation](Python/README.md)

## ⚠️ Disclaimer

This tool is for educational purposes only. Using automation tools may violate Discord's Terms of Service. Use at your own risk.

## 🔄 Project Development

### Original Development (March 2025)
- Initial AutoHotkey implementation with hardcoded coordinates
- Created separate versions for different devices/browsers
- Basic GUI for monitoring stats

### Enhanced Version (June 2025)
- Complete Python rewrite using computer vision
- Resolution-independent design
- User-friendly interface with configuration options
- Improved reliability and adaptability

## ⚙️ Technical Implementation

Both versions use similar techniques with different technologies:
- **Window Detection**: Finding the Discord window by title
- **Image Recognition**: Locating the "Spin Again" button
- **Automation**: Clicking buttons and typing commands
- **Timers**: Managing intervals between actions

The Python version adds:
- **Template Matching**: More robust button detection using OpenCV
- **Ratio-Based Positioning**: Using screen proportions instead of fixed coordinates
- **Configuration System**: Saving/loading user preferences
- **Visual Debugging**: Tools to verify detection accuracy

## 🤝 Contributing

Contributions are welcome! Feel free to submit a Pull Request with improvements.
