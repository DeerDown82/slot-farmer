
; === UI MANAGER ===
; Handles all user interface elements and interactions

; Initialize the GUI
InitUI() {
    global
    ; Create the main GUI
    Gui, New, +HwndGuiHwnd, %DefaultWindowTitle%
    
    ; Create menu
    Menu, DebugMenu, Add, Show Mouse Position, DebugShowMousePosition
    Menu, DebugMenu, Add, Test Click at Mouse, DebugTestClickAtMouse
    Menu, DebugMenu, Add  ; Add a separator line
    Menu, DebugMenu, Add, Show Debug Info, DebugShowDebugInfo
    
    Menu, MenuBar, Add, &Debug, :DebugMenu
    Gui, Menu, MenuBar
    
    ; Add controls
    Gui, Add, Text, vStatusText, Status: Not Running
    Gui, Add, Text, vCountdownText, Next Click In: N/A
    Gui, Add, Text, vExecCountText, Executions: 0
    Gui, Add, Text, vRespawnText, Respawns: 0
    Gui, Add, Button, gToggleScript w150 h30, Start/Stop
    Gui, Add, Button, gTestImageSearch w150 h30, Test Image Search
    Gui, Add, Button, gTestDiscordDetection w150 h30, Test Discord Detection
    Gui, Add, Checkbox, vTopToggle gToggleTop, Stay on Top
    
    ; Set window size and show
    Gui, Show, w300 h250
}

; Update the status text
UpdateStatus(text) {
    GuiControl,, StatusText, % "Status: " text
}

; Update the countdown text
UpdateCountdown(seconds) {
    if (seconds < 0)
        seconds := 0
    GuiControl,, CountdownText, % "Next Click In: " seconds " seconds"
}

; Update the execution counter
UpdateExecCount(count) {
    GuiControl,, ExecCountText, % "Executions: " count
}

; Update the respawn counter
UpdateRespawnCount(count) {
    GuiControl,, RespawnText, % "Respawns: " count
}

; Toggle the always on top state
ToggleAlwaysOnTop() {
    Gui, Submit, NoHide
    if (TopToggle)
        Gui, +AlwaysOnTop
    else
        Gui, -AlwaysOnTop
}

; Show a test result message
ShowTestResult(title, message) {
    MsgBox, % message
}

; === GLOBAL GUI FUNCTIONS ===
; These are called from the GUI events
ToggleScript() {
    global g_Toggle, g_NextClick, DefaultInterval
    g_Toggle := !g_Toggle
    if (g_Toggle) {
        g_NextClick := A_TickCount + (DefaultInterval * 1000)
        UpdateStatus("Running")
    } else {
        UpdateStatus("Not Running")
        UpdateCountdown(-1)  ; Show N/A
    }
}

ToggleTop() {
    ToggleAlwaysOnTop()
}

TestImageSearch() {
    if (!IsDiscordActive()) {
        ShowTestResult("Error", "Discord window not found.")
        return
    }
    
    result := SearchImage(ButtonImage)
    if (result.found) {
        x_center := result.x + 36
        y_center := result.y + 12
        ShowTestResult("Success", "Image Found!`nTop-Left: " result.x ", " result.y "`nCenter: " x_center ", " y_center)
    } else {
        ShowTestResult("Not Found", "Image not found.")
    }
}

TestDiscordDetection() {
    if (IsDiscordActive()) {
        ShowTestResult("Success", "Discord window detected!")
    } else {
        ShowTestResult("Error", "Discord window not found.")
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
