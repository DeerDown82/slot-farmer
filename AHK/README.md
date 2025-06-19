# Discord Slot Farmer (AutoHotkey Edition)

An AutoHotkey script that automates playing slots in Discord. The bot can automatically detect and click the "Play Again" button, making it perfect for farming in-game currency while AFK.

## 🚀 Features

- **Automated Slot Farming**: Automatically detects and clicks the "Play Again" button
- **Smart Window Detection**: Finds and interacts with Discord window automatically
- **Auto-Respawn**: Restarts slots game when button is not found
- **Multiple Versions**: Includes variants for desktop, laptop, and Firefox

## 📋 Requirements

- Windows 10/11
- [AutoHotkey v2.0+](https://www.autohotkey.com/)
- Discord Desktop Application

## 🛠 Installation

1. **Install AutoHotkey**
   - Download and install [AutoHotkey v2.0+](https://www.autohotkey.com/)

2. **Choose the Right Version**
   - Main version: For standard desktop setups with Discord app
   - Laptop version: Optimized for laptop screens
   - Firefox version: For running Discord in Firefox browser

3. **Prepare Button Image**
   - Take a screenshot of the "Play Again" button in Discord using Windows Snipping Tool
   - Save it in the appropriate images folder:
     - Main PC: `images/main/button_v1.bmp` or `button_v2.bmp`
     - Laptop: `images/laptop/button.bmp`
     - Firefox: `images/firefox/button.bmp`

## 🚦 Usage

1. **Run the Script**
   - Double-click the appropriate AHK file:
     - Main PC: `Gamble.ahk`
     - Laptop: `laptop ver/Gamble_Laptop.ahk`
     - Firefox: `firefox ver/Gamble.ahk`

2. **Using the Interface**
   - **Start/Stop**: Toggle the automation on/off
   - **Test Image Search**: Verify the script can find your button
   - **Test Discord Detection**: Check if the script can detect Discord
   - **Stay on Top**: Keep the control window visible

3. **Hotkeys**
   - **F8**: Manually trigger the slots respawn sequence

## 🔧 Customization

Each version requires adjustment for your specific setup:

### Main & Laptop Versions:
- Edit the script to update the `imagePath` variable to point to your button image
- If clicks are off-center, adjust the offset values (x+36, y+12)
- For different click timings, modify the `interval` variable (default: 8 seconds)

### Firefox Version:
- Uses a different clicking mechanism (PostMessage instead of mouse movement)
- May require updating window title variable for your Firefox window

## 🛠 Troubleshooting

If the script isn't working:

1. Use the "Test Image Search" button to verify button detection
2. Check that Discord is running and visible
3. Ensure the button image is properly captured and saved
4. Try adjusting the variation parameter in ImageSearch (e.g., `*30` to `*50`)
5. Update hardcoded coordinates for your screen resolution

## ⚠️ Limitations

- The script uses fixed coordinates for some actions, so it's tied to your screen resolution
- Different Discord themes or zoom levels require different button images
- Each user setup (resolution, zoom) needs custom configuration