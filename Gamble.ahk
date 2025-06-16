#Persistent
SetTitleMatchMode, 2
CoordMode, Pixel, Screen ; Keep pixel search in screen space
CoordMode, Mouse, Screen

; Path to your image
imagePath := "C:\Users\k1ngzly\Documents\AutoHotkey\button.bmp"
windowTitle := "ahk_exe Discord.exe"
interval := 10 ; Time in seconds between clicks

; Create GUI Window
Gui, Add, Text, vStatusText, Status: Not Running
Gui, Add, Text, vCountdownText, Next Click In: N/A
Gui, Add, Button, gToggleScript w150 h30, Start/Stop
Gui, Add, Button, gTestImageSearch w150 h30, Test Image Search
Gui, Add, Button, gTestDiscordDetection w150 h30, Test Discord Detection
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
    if (toggle) {
        ; Update countdown
        timeLeft := Round((nextClick - A_TickCount) / 1000)
        if (timeLeft < 0) {
            timeLeft := 0
        }
        GuiControl,, CountdownText, Next Click In: %timeLeft% seconds

        ; Perform click if time has elapsed
        if (A_TickCount >= nextClick) {
            ; Get Discord's window position
            WinGetPos, winX, winY, winWidth, winHeight, %windowTitle%
            if (winWidth && winHeight) {
                ; Search within Discord window only
                ImageSearch, x, y, %winX%, %winY%, % winX + winWidth, % winY + winHeight, *50 %imagePath%
                if (ErrorLevel = 0) {
                    ControlClick, x%x% y%y%, %windowTitle%
                    Tooltip, Clicked "Spin Again" Button!
                } else {
                    Tooltip, "Spin Again" Button Not Found!
                }
            } else {
                Tooltip, Discord window not detected.
            }
            nextClick := A_TickCount + (interval * 1000)
        }
    }
Return

; Test Image Search within Discord
TestImageSearch:
    WinGetPos, winX, winY, winWidth, winHeight, %windowTitle%
    if (!winWidth || !winHeight) {
        MsgBox, Discord window not found. Make sure it's visible.
        Return
    }

    ImageSearch, x, y, %winX%, %winY%, %winX% + %winWidth%, %winY% + %winHeight%, *50 %imagePath%
    if (ErrorLevel = 0) {
        MsgBox, Image Found at X: %x% Y: %y%
    } else {
        MsgBox, Image Not Found. ErrorLevel: %ErrorLevel%
    }
Return

; Test Discord Detection
TestDiscordDetection:
    if WinExist(windowTitle) {
        MsgBox, Discord detected and ready.
    } else {
        MsgBox, Discord not detected. Make sure it's open and visible.
    }
Return

GuiClose:
ExitApp
