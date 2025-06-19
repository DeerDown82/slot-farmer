import sys
import os
import time
import json
from pathlib import Path
from typing import Optional, Tuple, Dict, Any, List
import threading

import pyautogui
# These imports might need installation via pip
try:
    import cv2
    import numpy as np
except ImportError:
    print("Warning: OpenCV (cv2) not found. Image processing features will be limited.")
    # Create dummy implementations
    class DummyCV2:
        def imread(self, path):
            return None
        def imwrite(self, path, img):
            return False
        def matchTemplate(self, *args, **kwargs):
            return None
        def minMaxLoc(self, *args, **kwargs):
            return 0, 0, (0, 0), (0, 0)
        def cvtColor(self, *args, **kwargs):
            return None
        TM_CCOEFF_NORMED = 0
        COLOR_RGB2BGR = 0
    
    if 'cv2' not in globals():
        cv2 = DummyCV2()
    if 'np' not in globals():
        import array
        class DummyNumPy:
            def array(self, obj):
                return obj
            
            def __call__(self, obj):
                return self.array(obj)
        np = DummyNumPy()

try:
    from PyQt5.QtWidgets import (QApplication, QMainWindow, QVBoxLayout, QPushButton,
                              QLabel, QWidget, QCheckBox, QSpinBox, QHBoxLayout,
                              QFileDialog, QTabWidget, QGridLayout, QSlider, QGroupBox)
    from PyQt5.QtCore import Qt, QTimer
    from PyQt5.QtGui import QPixmap, QImage
except ImportError:
    print("Error: PyQt5 is required for this application.")
    print("Please install it with: pip install PyQt5")
    sys.exit(1)

class SlotFarmer(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Discord Slot Farmer")
        self.setFixedSize(600, 450)
        
        # Configuration
        self.config = self.load_config()
        self.running = False
        self.auto_click = False
        self.click_interval = 7  # seconds for a slot game
        self.respawn_interval = 15  # seconds before attempting respawn
        self.last_click_time = 0
        self.last_respawn_time = 0
        self.execution_count = 0
        self.respawn_count = 0
        self.confidence = 0.7  # Default template matching confidence
        self.debug_mode = False
        
        # Create references for button images
        self.button_images = []
        self.load_button_images()
        
        # Initialize UI
        self.init_ui()
        
        # Setup timer for auto-clicking
        self.timer = QTimer(self)
        self.timer.timeout.connect(self.update)
        self.timer.start(100)  # 100ms update interval
    
    def load_config(self) -> Dict[str, Any]:
        """Load configuration from file or return defaults."""
        config_path = Path("config.json")
        defaults = {
            "discord_window_title": "Discord",
            "click_interval": 7,
            "respawn_interval": 15,
            "confidence_threshold": 0.7,
            "images_dir": "images",
            "button_images": [],
            "message_input_x_ratio": 0.5,  # X position ratio for Discord message input
            "message_input_y_ratio": 0.95,  # Y position ratio for Discord message input
            "bet_amount": 100,
            "debug_mode": False
        }
        
        if config_path.exists():
            try:
                with open(config_path, 'r') as f:
                    return {**defaults, **json.load(f)}
            except Exception as e:
                print(f"Error loading config: {e}")
        
        # If config doesn't exist, create it with defaults
        try:
            with open(config_path, 'w') as f:
                json.dump(defaults, f, indent=4)
        except Exception as e:
            print(f"Error creating config: {e}")
            
        return defaults
    
    def save_config(self):
        """Save current configuration to file."""
        config_path = Path("config.json")
        try:
            with open(config_path, 'w') as f:
                json.dump(self.config, f, indent=4)
        except Exception as e:
            self.status_label.setText(f"Error saving config: {e}")
    
    def load_button_images(self):
        """Load button images from the images directory."""
        images_dir = Path(self.config["images_dir"])
        if not images_dir.exists():
            images_dir.mkdir(parents=True, exist_ok=True)
            
        # Load all image paths from config
        self.button_images = []
        for img_path in self.config.get("button_images", []):
            if Path(img_path).exists():
                self.button_images.append(img_path)
        
        # If no images in config, try to find images in the images directory
        if not self.button_images:
            for ext in ['.png', '.bmp', '.jpg']:
                for img_file in images_dir.glob(f"*{ext}"):
                    self.button_images.append(str(img_file))
                    
        # Update config with found images
        self.config["button_images"] = self.button_images
        self.save_config()
    
    def init_ui(self):
        """Initialize the user interface."""
        # Main widget and layout
        main_widget = QWidget()
        self.setCentralWidget(main_widget)
        main_layout = QVBoxLayout(main_widget)
        
        # Create tabs
        tabs = QTabWidget()
        main_layout.addWidget(tabs)
        
        # Main tab
        main_tab = QWidget()
        main_tab_layout = QVBoxLayout(main_tab)
        tabs.addTab(main_tab, "Main")
        
        # Status group
        status_group = QGroupBox("Status")
        status_layout = QVBoxLayout(status_group)
        
        self.status_label = QLabel("Status: Ready")
        status_layout.addWidget(self.status_label)
        
        self.countdown_label = QLabel("Next Action: N/A")
        status_layout.addWidget(self.countdown_label)
        
        stats_layout = QHBoxLayout()
        self.executions_label = QLabel("Executions: 0")
        stats_layout.addWidget(self.executions_label)
        
        self.respawns_label = QLabel("Respawns: 0")
        stats_layout.addWidget(self.respawns_label)
        
        status_layout.addLayout(stats_layout)
        main_tab_layout.addWidget(status_group)
        
        # Controls group
        controls_group = QGroupBox("Controls")
        controls_layout = QGridLayout(controls_group)
        
        # Click interval control
        controls_layout.addWidget(QLabel("Click Interval (seconds):"), 0, 0)
        self.interval_spin = QSpinBox()
        self.interval_spin.setRange(1, 60)
        self.interval_spin.setValue(self.click_interval)
        self.interval_spin.valueChanged.connect(self.update_click_interval)
        controls_layout.addWidget(self.interval_spin, 0, 1)
        
        # Respawn interval control
        controls_layout.addWidget(QLabel("Respawn Interval (seconds):"), 1, 0)
        self.respawn_spin = QSpinBox()
        self.respawn_spin.setRange(5, 120)
        self.respawn_spin.setValue(self.respawn_interval)
        self.respawn_spin.valueChanged.connect(self.update_respawn_interval)
        controls_layout.addWidget(self.respawn_spin, 1, 1)
        
        # Bet amount control
        controls_layout.addWidget(QLabel("Bet Amount:"), 2, 0)
        self.bet_spin = QSpinBox()
        self.bet_spin.setRange(1, 10000)
        self.bet_spin.setValue(self.config.get("bet_amount", 100))
        self.bet_spin.valueChanged.connect(self.update_bet_amount)
        controls_layout.addWidget(self.bet_spin, 2, 1)
        
        # Confidence threshold
        controls_layout.addWidget(QLabel("Detection Confidence:"), 3, 0)
        self.confidence_slider = QSlider(Qt.Horizontal)
        self.confidence_slider.setRange(1, 100)
        self.confidence_slider.setValue(int(self.confidence * 100))
        self.confidence_slider.valueChanged.connect(self.update_confidence)
        controls_layout.addWidget(self.confidence_slider, 3, 1)
        
        self.confidence_label = QLabel(f"Confidence: {self.confidence:.2f}")
        controls_layout.addWidget(self.confidence_label, 3, 2)
        
        main_tab_layout.addWidget(controls_group)
        
        # Buttons group
        buttons_group = QGroupBox("Actions")
        buttons_layout = QVBoxLayout(buttons_group)
        
        # Main control button
        self.toggle_btn = QPushButton("Start Auto-Click")
        self.toggle_btn.clicked.connect(self.toggle_auto_click)
        buttons_layout.addWidget(self.toggle_btn)
        
        # Manual actions
        manual_layout = QHBoxLayout()
        
        test_discord_btn = QPushButton("Test Discord")
        test_discord_btn.clicked.connect(self.test_discord_detection)
        manual_layout.addWidget(test_discord_btn)
        
        test_button_btn = QPushButton("Test Button Detection")
        test_button_btn.clicked.connect(self.test_button_detection)
        manual_layout.addWidget(test_button_btn)
        
        manual_respawn_btn = QPushButton("Manual Respawn")
        manual_respawn_btn.clicked.connect(self.perform_respawn)
        manual_layout.addWidget(manual_respawn_btn)
        
        buttons_layout.addLayout(manual_layout)
        
        # Debug mode checkbox
        self.debug_check = QCheckBox("Debug Mode")
        self.debug_check.setChecked(self.debug_mode)
        self.debug_check.stateChanged.connect(self.toggle_debug_mode)
        buttons_layout.addWidget(self.debug_check)
        
        main_tab_layout.addWidget(buttons_group)
        
        # Settings tab
        settings_tab = QWidget()
        settings_layout = QVBoxLayout(settings_tab)
        tabs.addTab(settings_tab, "Settings")
        
        # Image selection
        image_group = QGroupBox("Button Images")
        image_layout = QVBoxLayout(image_group)
        
        self.image_list_label = QLabel("No images loaded")
        self.update_image_list_label()
        image_layout.addWidget(self.image_list_label)
        
        image_buttons_layout = QHBoxLayout()
        
        add_image_btn = QPushButton("Add Image")
        add_image_btn.clicked.connect(self.add_button_image)
        image_buttons_layout.addWidget(add_image_btn)
        
        capture_image_btn = QPushButton("Capture Image")
        capture_image_btn.clicked.connect(self.capture_button_image)
        image_buttons_layout.addWidget(capture_image_btn)
        
        clear_images_btn = QPushButton("Clear Images")
        clear_images_btn.clicked.connect(self.clear_button_images)
        image_buttons_layout.addWidget(clear_images_btn)
        
        image_layout.addLayout(image_buttons_layout)
        settings_layout.addWidget(image_group)
        
        # Message box location calibration
        message_group = QGroupBox("Message Box Location")
        message_layout = QGridLayout(message_group)
        
        message_layout.addWidget(QLabel("X Position Ratio:"), 0, 0)
        self.message_x_slider = QSlider(Qt.Horizontal)
        self.message_x_slider.setRange(1, 100)
        self.message_x_slider.setValue(int(self.config.get("message_input_x_ratio", 0.5) * 100))
        self.message_x_slider.valueChanged.connect(self.update_message_x)
        message_layout.addWidget(self.message_x_slider, 0, 1)
        
        self.message_x_label = QLabel(f"X Ratio: {self.config.get('message_input_x_ratio', 0.5):.2f}")
        message_layout.addWidget(self.message_x_label, 0, 2)
        
        message_layout.addWidget(QLabel("Y Position Ratio:"), 1, 0)
        self.message_y_slider = QSlider(Qt.Horizontal)
        self.message_y_slider.setRange(1, 100)
        self.message_y_slider.setValue(int(self.config.get("message_input_y_ratio", 0.95) * 100))
        self.message_y_slider.valueChanged.connect(self.update_message_y)
        message_layout.addWidget(self.message_y_slider, 1, 1)
        
        self.message_y_label = QLabel(f"Y Ratio: {self.config.get('message_input_y_ratio', 0.95):.2f}")
        message_layout.addWidget(self.message_y_label, 1, 2)
        
        test_message_btn = QPushButton("Test Message Box Click")
        test_message_btn.clicked.connect(self.test_message_click)
        message_layout.addWidget(test_message_btn, 2, 0, 1, 3)
        
        settings_layout.addWidget(message_group)
        
    def update_image_list_label(self):
        """Update the image list label with current images."""
        if not self.button_images:
            self.image_list_label.setText("No images loaded")
            return
        
        image_list = "\n".join([f"- {Path(img).name}" for img in self.button_images])
        self.image_list_label.setText(f"Loaded Images:\n{image_list}")
    
    def add_button_image(self):
        """Add a button image file."""
        file_path, _ = QFileDialog.getOpenFileName(
            self, "Select Button Image", "", "Images (*.png *.jpg *.bmp)"
        )
        
        if file_path:
            # Copy the image to our images directory
            images_dir = Path(self.config["images_dir"])
            images_dir.mkdir(parents=True, exist_ok=True)
            
            dest_path = images_dir / Path(file_path).name
            try:
                import shutil
                shutil.copy(file_path, dest_path)
                
                # Add to our list
                if str(dest_path) not in self.button_images:
                    self.button_images.append(str(dest_path))
                    self.config["button_images"] = self.button_images
                    self.save_config()
                    self.update_image_list_label()
                    self.status_label.setText(f"Added image: {dest_path.name}")
            except Exception as e:
                self.status_label.setText(f"Error adding image: {e}")
    
    def capture_button_image(self):
        """Capture a portion of the screen for button detection."""
        self.status_label.setText("Click and drag to capture the 'Spin Again' button...")
        
        # Start a thread to handle the screen capture
        threading.Thread(target=self._screen_capture_thread, daemon=True).start()
    
    def _screen_capture_thread(self):
        """Thread function to capture screen region."""
        try:
            # Inform user to select region
            # Use mouseInfo to select a region
            print("Select the 'Spin Again' button by clicking and dragging...")
            print("After selection, the screenshot will be automatically saved")
            
            # Let user manually select region with mouse
            input("Press Enter when ready to capture (you'll have 3 seconds to position)...")
            time.sleep(3)  # Give user time to position mouse
            
            # Capture current mouse position
            start_x, start_y = pyautogui.position()
            print(f"Starting position: {start_x}, {start_y}")
            input("Now move mouse to bottom-right of button and press Enter...")
            end_x, end_y = pyautogui.position()
            print(f"Ending position: {end_x}, {end_y}")
            
            # Calculate region dimensions
            region_left = min(start_x, end_x)
            region_top = min(start_y, end_y)
            region_width = abs(end_x - start_x)
            region_height = abs(end_y - start_y)
            
            region = pyautogui.screenshot("temp_screenshot.png", region=(region_left, region_top, region_width, region_height))
            
            if region:
                # Save to images directory
                images_dir = Path(self.config["images_dir"])
                images_dir.mkdir(parents=True, exist_ok=True)
                
                timestamp = time.strftime("%Y%m%d-%H%M%S")
                dest_path = images_dir / f"button-{timestamp}.png"
                
                # Convert to PNG and save
                img = cv2.imread("temp_screenshot.png")
                cv2.imwrite(str(dest_path), img)
                
                # Clean up temp file
                os.remove("temp_screenshot.png")
                
                # Add to our list
                if str(dest_path) not in self.button_images:
                    self.button_images.append(str(dest_path))
                    self.config["button_images"] = self.button_images
                    self.save_config()
                
                # Update UI from main thread
                QApplication.instance().processEvents()
                self.update_image_list_label()
                self.status_label.setText(f"Captured button image: {dest_path.name}")
        except Exception as e:
            self.status_label.setText(f"Error capturing image: {e}")
    
    def clear_button_images(self):
        """Clear all button images."""
        self.button_images = []
        self.config["button_images"] = []
        self.save_config()
        self.update_image_list_label()
        self.status_label.setText("Cleared all button images")
    
    def update_click_interval(self, value: int):
        """Update the click interval."""
        self.click_interval = value
        self.config["click_interval"] = value
        self.save_config()
    
    def update_respawn_interval(self, value: int):
        """Update the respawn interval."""
        self.respawn_interval = value
        self.config["respawn_interval"] = value
        self.save_config()
    
    def update_bet_amount(self, value: int):
        """Update the bet amount."""
        self.config["bet_amount"] = value
        self.save_config()
    
    def update_confidence(self, value: int):
        """Update the confidence threshold."""
        self.confidence = value / 100.0
        self.config["confidence_threshold"] = self.confidence
        self.confidence_label.setText(f"Confidence: {self.confidence:.2f}")
        self.save_config()
    
    def update_message_x(self, value: int):
        """Update the message input X ratio."""
        ratio = value / 100.0
        self.config["message_input_x_ratio"] = ratio
        self.message_x_label.setText(f"X Ratio: {ratio:.2f}")
        self.save_config()
    
    def update_message_y(self, value: int):
        """Update the message input Y ratio."""
        ratio = value / 100.0
        self.config["message_input_y_ratio"] = ratio
        self.message_y_label.setText(f"Y Ratio: {ratio:.2f}")
        self.save_config()
    
    def toggle_debug_mode(self, state):
        """Toggle debug mode on/off."""
        self.debug_mode = state == Qt.Checked
        self.config["debug_mode"] = self.debug_mode
        self.save_config()
    
    def toggle_auto_click(self):
        """Toggle auto-clicking on/off."""
        self.auto_click = not self.auto_click
        if self.auto_click:
            self.toggle_btn.setText("Stop Auto-Click")
            self.status_label.setText(f"Status: Running")
            self.last_click_time = time.time()  # Start immediately
        else:
            self.toggle_btn.setText("Start Auto-Click")
            self.status_label.setText("Status: Ready")
            self.countdown_label.setText("Next Action: N/A")
    
    def test_discord_detection(self):
        """Test if Discord window can be found."""
        try:
            window = self.find_discord_window()
            if window:
                x, y, width, height = window
                self.status_label.setText(f"Found Discord: {width}x{height} at ({x},{y})")
            else:
                self.status_label.setText("Discord window not found!")
        except Exception as e:
            self.status_label.setText(f"Error: {str(e)}")
    
    def test_button_detection(self):
        """Test if button can be detected."""
        window = self.find_discord_window()
        if not window:
            self.status_label.setText("Discord window not found!")
            return
        
        x, y, width, height = window
        found, button_x, button_y, image_used = self.find_button_in_window(x, y, width, height)
        
        if found:
            if self.debug_mode:
                # Show the matched region
                self.highlight_region(button_x, button_y)
            
            self.status_label.setText(f"Button found at: {button_x}, {button_y} using {Path(image_used).name}")
        else:
            self.status_label.setText("Button not found!")
    
    def highlight_region(self, x, y):
        """Highlight a region briefly for debugging."""
        orig_pos = pyautogui.position()
        pyautogui.moveTo(x, y, duration=0.2)
        time.sleep(0.5)
        pyautogui.moveTo(orig_pos, duration=0.2)
    
    def test_message_click(self):
        """Test clicking the message input box."""
        window = self.find_discord_window()
        if not window:
            self.status_label.setText("Discord window not found!")
            return
        
        x, y, width, height = window
        message_x, message_y = self.get_message_box_position(x, y, width, height)
        
        orig_pos = pyautogui.position()
        pyautogui.moveTo(message_x, message_y, duration=0.5)
        pyautogui.click()
        pyautogui.moveTo(orig_pos, duration=0.5)
        
        self.status_label.setText(f"Clicked message box at: {message_x}, {message_y}")
    
    def find_discord_window(self) -> Optional[Tuple[int, int, int, int]]:
        """Find the Discord window and return its position and size."""
        try:
            # Try to use pygetwindow (part of pyautogui)
            try:
                import pygetwindow as gw
            except ImportError:
                print("Warning: pygetwindow not found, installing via pip...")
                import subprocess
                import sys
                subprocess.check_call([sys.executable, "-m", "pip", "install", "pygetwindow"])
                import pygetwindow as gw
                
            windows = gw.getWindowsWithTitle(self.config["discord_window_title"])
            if windows:
                window = windows[0]
                if window.isMinimized:
                    window.restore()
                
                if not window.isActive:
                    window.activate()
                
                return window.left, window.top, window.width, window.height
        except (ImportError, AttributeError):
            # Fallback if pygetwindow is not available
            try:
                # Try using Win32 API (Windows only)
                import win32gui
                def callback(hwnd, extra):
                    if win32gui.IsWindowVisible(hwnd) and self.config["discord_window_title"] in win32gui.GetWindowText(hwnd):
                        rect = win32gui.GetWindowRect(hwnd)
                        x = rect[0]
                        y = rect[1]
                        w = rect[2] - x
                        h = rect[3] - y
                        extra.append((x, y, w, h))
                        return False
                    return True
                
                result = []
                win32gui.EnumWindows(callback, result)
                if result:
                    x, y, w, h = result[0]
                    win32gui.SetForegroundWindow(win32gui.FindWindow(None, win32gui.GetWindowText(win32gui.GetForegroundWindow())))
                    return x, y, w, h
            except ImportError:
                # Last resort: manual positioning
                self.status_label.setText("Window detection failed. Please position Discord manually.")
                
        return None
    
    def find_button_in_window(self, win_x, win_y, win_width, win_height) -> Tuple[bool, int, int, str]:
        """Find the button in the Discord window."""
        if not self.button_images:
            return False, 0, 0, ""
        
        # Take a screenshot of the Discord window
        screenshot = pyautogui.screenshot(region=(win_x, win_y, win_width, win_height))
        
        try:
            # Convert screenshot to OpenCV format if libraries are available
            screenshot_np = np.array(screenshot)
            screenshot_np = cv2.cvtColor(screenshot_np, cv2.COLOR_RGB2BGR)
        except (AttributeError, NameError):
            # If using dummy implementations, just return not found
            self.status_label.setText("OpenCV not installed. Please install requirements.")
            return False, 0, 0, ""
        
        # Try each button image
        for button_img_path in self.button_images:
            try:
                button_img = cv2.imread(button_img_path)
                if button_img is None:
                    if self.debug_mode:
                        print(f"Could not load image: {button_img_path}")
                    continue
                
                # Check if image dimensions are valid
                if button_img.shape[0] <= 0 or button_img.shape[1] <= 0:
                    if self.debug_mode:
                        print(f"Invalid image dimensions: {button_img_path}")
                    continue
                
                # Use template matching to find the button
                try:
                    result = cv2.matchTemplate(screenshot_np, button_img, cv2.TM_CCOEFF_NORMED)
                    min_val, max_val, min_loc, max_loc = cv2.minMaxLoc(result)
                except Exception as e:
                    if self.debug_mode:
                        print(f"Template matching error: {e}")
                    continue
                
                if max_val >= self.confidence:
                    # Get button position
                    button_width, button_height = button_img.shape[1], button_img.shape[0]
                    button_x = win_x + max_loc[0] + button_width // 2
                    button_y = win_y + max_loc[1] + button_height // 2
                    
                    if self.debug_mode:
                        print(f"Found button with confidence: {max_val:.2f}")
                    
                    return True, button_x, button_y, button_img_path
            except Exception as e:
                if self.debug_mode:
                    print(f"Error processing {button_img_path}: {e}")
        
        return False, 0, 0, ""
    
    def get_message_box_position(self, win_x, win_y, win_width, win_height) -> Tuple[int, int]:
        """Calculate the position of the message input box based on window dimensions."""
        message_x = win_x + int(win_width * self.config["message_input_x_ratio"])
        message_y = win_y + int(win_height * self.config["message_input_y_ratio"])
        return message_x, message_y
    
    def perform_click(self):
        """Perform the click action on the button."""
        try:
            window = self.find_discord_window()
            if not window:
                self.status_label.setText("Discord window not found!")
                return False
            
            x, y, width, height = window
            found, button_x, button_y, image_used = self.find_button_in_window(x, y, width, height)
            
            if found:
                # Save original mouse position
                orig_pos = pyautogui.position()
                
                # Click the button
                pyautogui.moveTo(button_x, button_y, duration=0.1)
                pyautogui.click()
                
                # Return to original position
                pyautogui.moveTo(orig_pos, duration=0.1)
                
                # Update execution count
                self.execution_count += 1
                self.executions_label.setText(f"Executions: {self.execution_count}")
                
                self.status_label.setText(f"Clicked at {time.strftime('%H:%M:%S')}")
                return True
            else:
                # If button not found and it's been long enough, try respawning
                current_time = time.time()
                if current_time - self.last_respawn_time >= self.respawn_interval:
                    self.perform_respawn()
                    return True
                else:
                    self.status_label.setText("Button not found, waiting to respawn...")
                    return False
        except Exception as e:
            self.status_label.setText(f"Error clicking: {str(e)}")
            return False
    
    def perform_respawn(self):
        """Perform the respawn sequence."""
        try:
            window = self.find_discord_window()
            if not window:
                self.status_label.setText("Discord window not found!")
                return
            
            x, y, width, height = window
            message_x, message_y = self.get_message_box_position(x, y, width, height)
            
            # Save original mouse position
            orig_pos = pyautogui.position()
            
            # Click the message input box
            pyautogui.moveTo(message_x, message_y, duration=0.1)
            pyautogui.click()
            
            # Type /slots command
            bet_amount = self.config.get("bet_amount", 100)
            pyautogui.typewrite(f"/slots {bet_amount}")
            pyautogui.press("enter")
            time.sleep(2)  # Wait for Discord to process
            
            # Type /shop icons to get an ephemeral message
            pyautogui.click(message_x, message_y)
            pyautogui.typewrite("/shop icons")
            pyautogui.press("enter")
            time.sleep(1)
            
            # Type it again for good measure
            pyautogui.click(message_x, message_y)
            pyautogui.typewrite("/shop icons")
            pyautogui.press("enter")
            time.sleep(1)
            
            # Scroll up a bit to freeze chat position
            pyautogui.scroll(3)
            
            # Return to original position
            pyautogui.moveTo(orig_pos, duration=0.1)
            
            # Update respawn count
            self.respawn_count += 1
            self.respawns_label.setText(f"Respawns: {self.respawn_count}")
            self.last_respawn_time = time.time()
            
            self.status_label.setText(f"Respawned at {time.strftime('%H:%M:%S')}")
        except Exception as e:
            self.status_label.setText(f"Error respawning: {str(e)}")
    
    def update(self):
        """Main update loop."""
        if not self.auto_click:
            return
        
        current_time = time.time()
        time_since_click = current_time - self.last_click_time
        
        # Update countdown
        seconds_left = max(0, self.click_interval - time_since_click)
        self.countdown_label.setText(f"Next Action: {seconds_left:.1f}s")
        
        # Perform click if it's time
        if time_since_click >= self.click_interval:
            success = self.perform_click()
            if success:
                self.last_click_time = current_time

def main():
    # Initialize the application
    app = QApplication(sys.argv)
    
    # Enable high DPI scaling
    app.setAttribute(Qt.AA_EnableHighDpiScaling, True)
    app.setAttribute(Qt.AA_UseHighDpiPixmaps, True)
    
    # Create and show the main window
    window = SlotFarmer()
    window.show()
    
    # Start the event loop
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
