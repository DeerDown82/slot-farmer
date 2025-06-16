; === DEBUG TOOLS ===
; Provides various debugging and testing utilities for the slot farmer

class DebugTools {
    ; Show mouse position in a tooltip
    static ShowMousePosition() {
        static isActive := false
        
        if (isActive) {
            SetTimer, ShowMousePosition, Off
            ToolTip
            isActive := false
            return
        }
        
        isActive := true
        SetTimer, ShowMousePosition, 100
        
        ShowMousePosition() {
            MouseGetPos, x, y
            ToolTip, X: %x%`nY: %y%, 0, 0
        }
    }
    
    ; Test image search with current settings
    static TestImageSearch() {
        if (!IsDiscordActive()) {
            UI.ShowTestResult("Error", "Discord window not found.")
            return
        }
        
        result := ImageManager.SearchImage(Config.ButtonImage)
        if (result.found) {
            x_center := result.x + 36
            y_center := result.y + 12
            UI.ShowTestResult("Image Found", 
                "Top-Left: " result.x ", " result.y "`n"
                . "Center: " x_center ", " y_center "`n"
                . "Image: " Config.GetImagePath(Config.ButtonImage))  
        } else {
            UI.ShowTestResult("Image Not Found", 
                "Could not find the button image.`n"
                . "Searched in: " Config.DiscordWindowTitle "`n"
                . "Image: " Config.GetImagePath(Config.ButtonImage))
        }
    }
    
    ; Test Discord detection
    static TestDiscordDetection() {
        if (IsDiscordActive()) {
            WinGetPos, x, y, w, h, % Config.DiscordWindowTitle
            UI.ShowTestResult("Discord Detected", 
                "Window found!`n"
                . "Position: " x ", " y "`n"
                . "Size: " w "x" h)
        } else {
            UI.ShowTestResult("Discord Not Found", 
                "Discord window not detected.`n"
                . "Looking for: " Config.DiscordWindowTitle)
        }
    }
    
    ; Test click at current mouse position
    static TestClickAtMouse() {
        MouseGetPos, x, y
        ImageManager.SendRealClick(x, y)
        UI.ShowTestResult("Click Test", "Sent click at: " x ", " y)
    }
    
    ; Show debug information
    static ShowDebugInfo() {
        WinGetPos, dX, dY, dW, dH, % Config.DiscordWindowTitle
        MouseGetPos, mX, mY
        
        info := "=== Debug Information ===`n"
        info .= "Discord Window:`n"
        info .= "  Position: " dX ", " dY "`n"
        info .= "  Size: " dW "x" dH "`n`n"
        info .= "Mouse Position:`n"
        info .= "  Screen: " mX ", " mY "`n"
        info .= "  Relative: " (mX-dX) ", " (mY-dY) "`n`n"
        info .= "Status:`n"
        info .= "  Running: " (g_Toggle ? "Yes" : "No") "`n"
        info .= "  Executions: " g_ExecCount "`n"
        info .= "  Last Respawn: " (A_TickCount - g_LastRespawn) "ms ago"
        
        UI.ShowTestResult("Debug Information", info)
    }
}

; Include guard
if (A_LineFile = A_ScriptFullPath) {
    MsgBox % "DebugTools module loaded. This is a support file and should be included by the main script."
    ExitApp
}
