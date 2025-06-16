; === GLOBAL CONFIGURATION ===
#SingleInstance Force
#Persistent
SetTitleMatchMode, 2
SetDefaultMouseSpeed, 0
SendMode Event
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; === GLOBAL VARIABLES ===
; Discord window settings
global DiscordWindowTitle := "ahk_exe Discord.exe"

; Timing settings (in milliseconds)
global ClickDelay := 10
global DefaultInterval := 8
global CommandDelay := 100
global UIUpdateInterval := 50

; Image paths
global ImageDir := A_ScriptDir "\..\images\main"
global ButtonImage := "button_v2.bmp"

; UI Defaults
global DefaultWindowTitle := "Auto Clicker Status"
global GuiWidth := 300
global GuiHeight := 250

; Slots command
global SlotsCommand := "/slots 5000"

; Respawn cooldown (15 seconds)
global RespawnCooldown := 15000

; Image search settings
global ImageVariation := 30  ; 0-255, higher allows more variation in image matching

; === FUNCTIONS ===
GetFullImagePath() {
    return ImageDir "\" ButtonImage
}

GetImagePath(imageName) {
    return ImageDir "\" imageName
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
