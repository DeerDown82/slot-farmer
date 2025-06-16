; === MAIN SCRIPT ===
; Slot Farmer - Automated Discord Slots Bot
; Modular version with resolution independence

; Include required libraries
#Include src\Config.ahk
#Include src\ImageManager.ahk
#Include src\DiscordController.ahk
#Include src\UI.ahk

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

; === GUI EVENTS ===
; These are handled by the UI class

; === EXIT HANDLER ===
OnExit("ExitHandler")
ExitHandler(ExitReason, ExitCode) {
    ; Clean up resources if needed
    return 0  ; Call ExitApp
}
