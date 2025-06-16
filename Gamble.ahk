#Persistent
SetTitleMatchMode, 2
CoordMode, Pixel, Screen ; Search on the entire screen
CoordMode, Mouse, Screen

; Set your variables
imagePath := "C:\Users\k1ngzly\Documents\AutoHotkey\button.png"
windowTitle := "ahk_exe Discord.exe"
interval := 10 ; Time in seconds between clicks

; Create GUI Window
Gui, Add, Text, vStatusText, Status: Not Running
Gui, Add, Text, vCountdownText, Next Click In: N/A
Gui, Add, Button, gToggleScript w150 h30, Start/Stop
Gui, Show,, Auto Clicker Status

toggle := false
nextClick := 0

Return

; Toggle the script on/off
ToggleScript:
    toggle := !toggle
    if (toggle) {
        nextClick := A_TickCount + (interval * 1000)
        GuiControl,, StatusText, Status: Running
    } else {
        GuiControl,, StatusText, Status: Not Running
        GuiControl,, CountdownText, Next Click In: N/A
    }
Return

; Main Loop
SetTimer, ClickLoop, 100
Return

ClickLoop:
    ; Update countdown
    if (toggle) {
        timeLeft := Round((nextClick - A_TickCount) / 1000)
        if (timeLeft < 0) {
            timeLeft := 0
        }
        GuiControl,, CountdownText, Next Click In: %timeLeft% seconds
    }

    ; Perform click if time has elapsed
    if (toggle && A_TickCount >= nextClick) {
        ; Search for the button
        ImageSearch, x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, %imagePath%
        if (ErrorLevel = 0) {
            ControlClick, x%x% y%y%, %windowTitle%
        } else {
            Tooltip, Spin Again button not found!
        }
        nextClick := A_TickCount + (interval * 1000)
    }
Return

GuiClose:
ExitApp
