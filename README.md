# Discord Slot Farmer

An AutoHotkey script that automates playing slots in Discord. The bot can automatically detect and click the "Play Again" button, making it perfect for farming in-game currency while AFK.

## 🚀 Features

- **Automated Slot Farming**: Automatically detects and clicks the "Play Again" button
- **Smart Window Detection**: Finds and interacts with Discord window automatically
- **Resolution Independent**: Works on different screen resolutions
- **Debugging Tools**: Built-in tools for troubleshooting and testing
- **User-Friendly Interface**: Simple GUI with status indicators and controls
- **Stats Tracking**: Keeps track of executions and respawns

## 📋 Requirements

- Windows 10/11
- [AutoHotkey v2.0+](https://www.autohotkey.com/)
- Discord Desktop Application

## 🛠 Installation

1. **Install AutoHotkey**
   - Download and install [AutoHotkey v2.0+](https://www.autohotkey.com/)

2. **Download the Script**
   ```
   git clone https://github.com/yourusername/slot-farmer.git
   cd slot-farmer
   ```

3. **Prepare Button Image**
   - Take a screenshot of the "Play Again" button in Discord
   - Save it as `button.bmp` in the `images` directory
   - For best results, use the Windows Snipping Tool to capture just the button

## 🚦 Usage

1. **Start the Script**
   - Double-click `main.ahk` or right-click and select "Run with AutoHotkey"

2. **Using the Interface**
   - **Start/Stop**: Toggle the automation on/off
   - **Test Image Search**: Verify the script can find your button
   - **Test Discord Detection**: Check if the script can detect Discord
   - **Stay on Top**: Keep the control window visible

3. **Debug Menu**
   - **Show Mouse Position**: Toggle mouse coordinates display
   - **Test Click at Mouse**: Test clicking at current mouse position
   - **Show Debug Info**: Display detailed debugging information

## 🎮 Hotkeys

- **F8**: Manually trigger the slots sequence
- **Ctrl+Alt+R**: Reload the script
- **F4**: Show current mouse position (when debug tools are active)

## 🛠 Debugging

If the script isn't working:

1. Use the "Test Image Search" button to verify button detection
2. Check that Discord is running and visible
3. Ensure the button image is properly captured and saved
4. Use the debug tools to troubleshoot

## 📁 Project Structure

```
slot-farmer/
├── images/           # Button images for detection
├── src/              # Main source code
│   ├── Config.ahk           # Configuration settings
│   ├── DiscordController.ahk # Discord interaction logic
│   ├── ImageManager.ahk      # Image detection and clicking
│   └── UI.ahk               # User interface
├── utils/            # Utility scripts
│   └── DebugTools.ahk        # Debugging utilities
├── main.ahk          # Main script (entry point)
└── README.md         # This file
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
