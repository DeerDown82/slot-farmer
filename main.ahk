; === MAIN SCRIPT ===
; Slot Farmer - Automated Discord Slots Bot
; Modular version with resolution independence

; Set working directory to script location
#SingleInstance Force
#NoEnv
#Persistent
SetWorkingDir %A_ScriptDir%
SendMode Event
SetTitleMatchMode, 2
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; Include required libraries with relative paths
#Include %A_ScriptDir%\src\Config.ahk
#Include %A_ScriptDir%\src\ImageManager.ahk
#Include %A_ScriptDir%\src\DiscordController.ahk
#Include %A_ScriptDir%\src\UI.ahk
#Include %A_ScriptDir%\utils\DebugTools.ahk

; Initialize global variables
global g_Toggle := false
global g_NextClick := 0
global g_ExecCount := 0
global g_RespawnCount := 0
global g_LastRespawn := 0

; Initialize the application
InitUI()

; Set up timer for main loop
SetTimer, MainLoop, 100
Return

; === MAIN LOOP ===
MainLoop:
    ; Check if we should run
    if (!g_Toggle) {
        return
    }
    
    ; Check if it's time to click
    currentTime := A_TickCount
    if (currentTime >= g_NextClick) {
        ; Try to find and click the play button
        if (DiscordController.IsPlayAgainButtonVisible()) {
            if (DiscordController.ClickPlayAgain()) {
                g_ExecCount++
                UI.UpdateExecCount(g_ExecCount)
            }
        } else if (A_TickCount - g_LastRespawn > Config.RespawnCooldown) {
            ; If button not found and cooldown passed, try to respawn
            DiscordController.RunSlotsAndFreeze()
            g_LastRespawn := A_TickCount
            g_RespawnCount++
            UI.UpdateRespawnCount(g_RespawnCount)
        }
        
        ; Schedule next click
        g_NextClick := A_TickCount + (Config.DefaultInterval * 1000)
    }
return

; === HOTKEYS ===
F8::DiscordController.RunSlotsAndFreeze()
^!r::Reload  ; Ctrl+Alt+R to reload the script
F6::ToggleScript()
F7::
    MsgBox, % "Debug Info:`n`n"
           . "Executions: " g_ExecCount "`n"
           . "Respawns: " g_RespawnCount "`n"
           . "Image Path: " Config.ImageDir "`n"
           . "Window Title: " Config.WindowTitle "`n"
           . "Interval: " Config.DefaultInterval "ms"
return
^!x::ExitApp  ; Ctrl+Alt+X to exit

; === GUI EVENTS ===
; These are handled by the UI class

; === EXIT HANDLER ===
OnExit("ExitHandler")
ExitHandler(ExitReason, ExitCode) {
    ; Clean up resources if needed
    return 0  ; Call ExitApp
}

; Function to check if Discord is active
IsDiscordActive() {
    return WinExist(Config.WindowTitle)
}

; Function to toggle the script
ToggleScript() {
    global g_Toggle, g_NextClick
    g_Toggle := !g_Toggle
    if (g_Toggle) {
        g_NextClick := A_TickCount + (Config.DefaultInterval * 1000)
        UI.UpdateStatus("Running")
    } else {
        UI.UpdateStatus("Not Running")
        UI.UpdateCountdown("N/A")
    }
}

; Show a message when the script loads
MsgBox, 64, Slot Farmer, Slot Farmer is running!`n`nPress F6 to start/stop`nPress F7 for debug info`nCtrl+Alt+X to exit
