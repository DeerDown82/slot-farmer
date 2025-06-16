; === GLOBAL CONFIGURATION ===
#Warn All, Off
#SingleInstance Force
#Persistent
SetTitleMatchMode, 2
SetDefaultMouseSpeed, 0
SendMode, Event
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; === APPLICATION CONSTANTS ===
class Config {
    ; Discord window settings
    static DiscordWindowTitle := "ahk_exe Discord.exe"
    
    ; Timing settings (in milliseconds)
    static ClickDelay := 10
    static DefaultInterval := 8
    static CommandDelay := 100
    static UIUpdateInterval := 50
    
    ; Image paths
    static ImageDir := "C:\Users\k1ngzly\Documents\AutoHotkey"
    static ButtonImage := "button.bmp"
    
    ; UI Defaults
    static DefaultWindowTitle := "Auto Clicker Status"
    static GuiWidth := 300
    static GuiHeight := 250
    
    ; Slots command
    static SlotsCommand := "/slots 5000"
    
    ; Respawn cooldown (15 seconds)
    static RespawnCooldown := 15000
    
    ; Image search settings
    static ImageVariation := 30  ; 0-255, higher allows more variation in image matching
    
    ; Get full image path
    GetImagePath(imageName) {
        return this.ImageDir "\" imageName
    }
}

; === GLOBAL VARIABLES ===
; These are kept in the global scope for backward compatibility
global g_Config := new Config()
global g_Toggle := false
global g_ExecCount := 0
global g_RespawnCount := 0
global g_NextClick := 0
global g_LastRespawn := 0

; === HELPER FUNCTIONS ===
IsDiscordActive() {
    return WinExist(Config.DiscordWindowTitle)
}

; Include guard
if (A_LineFile = A_ScriptFullPath) {
    ; This script was run directly, not included
    MsgBox % "Config module loaded. This is a configuration file and should be included by the main script."
    ExitApp
}
