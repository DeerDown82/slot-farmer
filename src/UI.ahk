; === UI MANAGER ===
; Handles all user interface elements and interactions

class UI {
    static GuiHwnd := 0
    static StatusTextHwnd := 0
    static CountdownHwnd := 0
    static ExecCountHwnd := 0
    static RespawnHwnd := 0
    
    ; Initialize the GUI
    static Init() {
        ; Create the main GUI
        Gui, New, +HwndGuiHwnd, % Config.DefaultWindowTitle
        this.GuiHwnd := GuiHwnd
        
        ; Add controls
        Gui, Add, Text, vStatusTextHwnd, Status: Not Running
        Gui, Add, Text, vCountdownHwnd, Next Click In: N/A
        Gui, Add, Text, vExecCountHwnd, Executions: 0
        Gui, Add, Text, vRespawnHwnd, Respawns: 0
        Gui, Add, Button, gToggleScript w150 h30, Start/Stop
        Gui, Add, Button, gTestImageSearch w150 h30, Test Image Search
        Gui, Add, Button, gTestDiscordDetection w150 h30, Test Discord Detection
        Gui, Add, Checkbox, vTopToggle gToggleTop, Stay on Top
        
        ; Set window size and show
        Gui, Show, w%Config.GuiWidth% h%Config.GuiHeight%
        
        ; Store control Hwnds
        GuiControlGet, StatusTextHwnd, Hwnd, StatusTextHwnd
        GuiControlGet, CountdownHwnd, Hwnd, CountdownHwnd
        GuiControlGet, ExecCountHwnd, Hwnd, ExecCountHwnd
        GuiControlGet, RespawnHwnd, Hwnd, RespawnHwnd
    }
    
    ; Update the status text
    static UpdateStatus(text) {
        GuiControl,, StatusTextHwnd, % "Status: " text
    }
    
    ; Update the countdown text
    static UpdateCountdown(seconds) {
        if (seconds < 0)
            seconds := 0
        GuiControl,, CountdownHwnd, % "Next Click In: " seconds " seconds"
    }
    
    ; Update the execution counter
    static UpdateExecCount(count) {
        GuiControl,, ExecCountHwnd, % "Executions: " count
    }
    
    ; Update the respawn counter
    static UpdateRespawnCount(count) {
        GuiControl,, RespawnHwnd, % "Respawns: " count
    }
    
    ; Toggle the always on top state
    static ToggleAlwaysOnTop() {
        Gui, Submit, NoHide
        if (TopToggle)
            Gui, +AlwaysOnTop
        else
            Gui, -AlwaysOnTop
    }
    
    ; Show a test result message
    static ShowTestResult(title, message) {
        MsgBox, % message
    }
}

; === GLOBAL GUI FUNCTIONS ===
; These need to be in the global scope for GUI events
ToggleScript() {
    global g_Toggle, g_NextClick
    g_Toggle := !g_Toggle
    if (g_Toggle) {
        g_NextClick := A_TickCount + (Config.DefaultInterval * 1000)
        UI.UpdateStatus("Running")
    } else {
        UI.UpdateStatus("Not Running")
        UI.UpdateCountdown(-1)  ; Show N/A
    }
}

ToggleTop() {
    UI.ToggleAlwaysOnTop()
}

TestImageSearch() {
    if (!IsDiscordActive()) {
        UI.ShowTestResult("Error", "Discord window not found.")
        return
    }
    
    result := ImageManager.SearchImage(Config.ButtonImage)
    if (result.found) {
        x_center := result.x + 36
        y_center := result.y + 12
        UI.ShowTestResult("Success", "Image Found!`nTop-Left: " result.x ", " result.y "`nCenter: " x_center ", " y_center)
    } else {
        UI.ShowTestResult("Not Found", "Image not found.")
    }
}

TestDiscordDetection() {
    if (IsDiscordActive()) {
        UI.ShowTestResult("Success", "Discord window detected!")
    } else {
        UI.ShowTestResult("Error", "Discord window not found.")
    }
}

; Handle GUI close
GuiClose() {
    ExitApp
}

; Include guard
if (A_LineFile = A_ScriptFullPath) {
    MsgBox % "UI module loaded. This is a support file and should be included by the main script."
    ExitApp
}
