; === MAIN SCRIPT ===
; Slot Farmer - Automated Discord Slots Bot
; Modular version with resolution independence

; Include required libraries
#SingleInstance Force
#NoEnv
SetWorkingDir %A_ScriptDir%
SendMode Event
SetTitleMatchMode 2

#Include src\Config.ahk
#Include src\ImageManager.ahk
#Include src\DiscordController.ahk
#Include src\UI.ahk
#Include utils\DebugTools.ahk

; Initialize global variables
global g_Toggle := false
global g_NextClick := 0
global g_ExecCount := 0
global g_RespawnCount := 0
global g_LastRespawn := 0

; Initialize the application
Initialize()

; Main timer for the auto-clicker
SetTimer, MainLoop, % Config.UIUpdateInterval
return

; === INITIALIZATION ===
Initialize() {
    ; Create required directories
    if !FileExist(Config.ImageDir)
        FileCreateDir, % Config.ImageDir
    
    ; Initialize the UI
    UI.Init()
    
    ; Show welcome message
    UI.UpdateStatus("Ready")
}

; === MAIN LOOP ===
MainLoop:
    if (!g_Toggle)
        return
    
    ; Update countdown
    timeLeft := Round((g_NextClick - A_TickCount) / 1000)
    UI.UpdateCountdown(timeLeft)
    
    ; Check if it's time to click
    if (A_TickCount >= g_NextClick) {
        if (IsDiscordActive()) {
            ; Try to find and click the play button
            if (DiscordController.IsPlayAgainButtonVisible()) {
                if (DiscordController.ClickPlayAgain()) {
                    g_ExecCount += 1
                    UI.UpdateExecCount(g_ExecCount)
                }
            } else if (A_TickCount - g_LastRespawn > Config.RespawnCooldown) {
                ; If button not found and cooldown passed, try to respawn
                DiscordController.RunSlotsAndFreeze()
                g_LastRespawn := A_TickCount
                g_RespawnCount += 1
                UI.UpdateRespawnCount(g_RespawnCount)
            }
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
