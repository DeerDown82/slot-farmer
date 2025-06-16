; === GUI ===
; Original GUI from Gamble.ahk

; Create the GUI
Gui, Add, Text, vStatusText, Status: Not Running
Gui, Add, Text, vCountdownText, Next Click In: N/A
Gui, Add, Text, vExecCountText, Executions: 0
Gui, Add, Text, vRespawnText, Respawns: 0
Gui, Add, Button, gToggleScript w150 h30, Start/Stop
Gui, Add, Button, gTestImageSearch w150 h30, Test Image Search
Gui, Add, Button, gTestDiscordDetection w150 h30, Test Discord Detection
Gui, Add, Checkbox, vTopToggle gToggleTop, Stay on Top
Gui, Show,, Auto Clicker Status

; Set up the timer for the main loop
SetTimer, ClickLoop, 50

; === GUI EVENT HANDLERS ===

; Toggle the script on/off
ToggleScript:
    global g_Toggle, g_NextClick
    g_Toggle := !g_Toggle
    if (g_Toggle) {
        g_NextClick := A_TickCount + (Config.DefaultInterval * 1000)
        GuiControl,, StatusText, Status: Running
    } else {
        GuiControl,, StatusText, Status: Not Running
        GuiControl,, CountdownText, Next Click In: N/A
    }
return

; Toggle always on top
ToggleTop:
    global TopToggle
    Gui, Submit, NoHide
    if (TopToggle)
        Gui, +AlwaysOnTop
    else
        Gui, -AlwaysOnTop
return

; Test image search
TestImageSearch:
    if (!IsDiscordActive()) {
        MsgBox, Discord window not found.
        Return
    }
    
    result := ImageManager.SearchImage(Config.ButtonImage)
    if (result.found) {
        x_center := result.x + 36
        y_center := result.y + 12
        MsgBox, Image Found:`nTop-Left: %result.x%, %result.y%`nCenter: %x_center%, %y_center%
    } else {
        MsgBox, Image Not Found
    }
return

; Test Discord detection
TestDiscordDetection:
    if (IsDiscordActive()) {
        MsgBox, Discord detected
    } else {
        MsgBox, Discord not detected
    }
return

; Handle GUI close
GuiClose:
ExitApp

; === MAIN LOOP ===
ClickLoop:
    if (!g_Toggle)
        return

    timeLeft := Round((g_NextClick - A_TickCount) / 1000)
    if (timeLeft < 0)
        timeLeft := 0
    GuiControl,, CountdownText, Next Click In: %timeLeft% seconds

    if (A_TickCount >= g_NextClick) {
        if (IsDiscordActive()) {
            result := ImageManager.SearchImage(Config.ButtonImage)
            if (result.found) {
                x := result.x + 36
                y := result.y + 12
                SendFakeClick(x, y)
                g_ExecCount += 1
                GuiControl,, ExecCountText, % "Executions: " . g_ExecCount
            } else {
                if (A_TickCount - g_LastRespawn > 15000) {
                    RunSlotsAndFreeze()
                    g_LastRespawn := A_TickCount
                    g_RespawnCount += 1
                    GuiControl,, RespawnText, % "Respawns: " . g_RespawnCount
                }
            }
        }
        g_NextClick := A_TickCount + (Config.DefaultInterval * 1000)
    }
return

; Hotkey for manual trigger
F8::RunSlotsAndFreeze()

; === UI CLASS ===
class UI {
    ; Store control Hwnds
    GuiControlGet, StatusTextHwnd, Hwnd, StatusText
    GuiControlGet, CountdownHwnd, Hwnd, CountdownText
    GuiControlGet, ExecCountHwnd, Hwnd, ExecCountText
    GuiControlGet, RespawnHwnd, Hwnd, RespawnText
    
    ; Update the status text
    static UpdateStatus(text) {
        GuiControl,, StatusText, % "Status: " text
    }
    
    ; Update the countdown text
    static UpdateCountdown(seconds) {
        if (seconds < 0)
            seconds := 0
        GuiControl,, CountdownText, % "Next Click In: " seconds " seconds"
    }
    
    ; Update the execution counter
    static UpdateExecCount(count) {
        GuiControl,, ExecCountText, % "Executions: " count
    }
    
    ; Update the respawn counter
    static UpdateRespawnCount(count) {
        GuiControl,, RespawnText, % "Respawns: " count
    }
    
    ; Toggle the always on top state
    static ToggleAlwaysOnTop() {
        global TopToggle
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

; Include guard
if (A_LineFile = A_ScriptFullPath) {
    MsgBox % "UI module loaded. This is a support file and should be included by the main script."
    ExitApp
}
