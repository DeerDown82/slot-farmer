#Persistent
SetTitleMatchMode, 2
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; ✅ CONFIGURATION
imagePath := "C:\Users\k1ngzly\Documents\AutoHotkey\button.bmp" ; Use BMP format!
; Ensure the file exists before we try to use it
if !FileExist(imagePath) {
    MsgBox, ⚠️ Image file not found at:`n%imagePath%`nMake sure the file exists and the path is correct.
    ExitApp
}
windowTitle := "ahk_exe Discord.exe"
interval := 10 ; seconds between clicks

; ✅ GUI SETUP
Gui, Add, Text, vStatusText, Status: Not Running
Gui, Add, Text, vCountdownText, Next Click In: N/A
Gui, Add, Button, gToggleScript w150 h30, Start/Stop
Gui, Add, Button, gTestImageSearch w150 h30, Test Image Search
Gui, Add, Button, gTestDiscordDetection w150 h30, Test Discord Detection
Gui, Show,, Auto Clicker Status

toggle := false
nextClick := 0

Return

; ✅ TOGGLE START/STOP
ToggleScript:
    toggle := !toggle
    if (toggle) {
        nextClick := A_TickCount + (interval * 1000)
        GuiControl,, StatusText, Status: Running
    } else {
        GuiControl,, StatusText, Status: Not Running
        GuiControl,, CountdownText, Next Click In: N/A
        Tooltip
    }
Return

; ✅ MAIN TIMER LOOP
SetTimer, ClickLoop, 100
Return

ClickLoop:
    if (toggle) {
        ; Update countdown display
        timeLeft := Round((nextClick - A_TickCount) / 1000)
        if (timeLeft < 0) {
            timeLeft := 0
        }
        GuiControl,, CountdownText, Next Click In: %timeLeft% seconds

        ; Time to click?
        if (A_TickCount >= nextClick) {
            WinGetPos, winX, winY, winW, winH, %windowTitle%
            if (winW && winH) {
                ; Search within the bounds of the Discord window
                ImageSearch, x, y, %winX%, %winY%, % winX + winW, % winY + winH, *50 %imagePath%
                if (ErrorLevel = 0) {
                    ControlClick, x%x% y%y%, %windowTitle%
                    Tooltip, Clicked "Spin Again" at %x%, %y%
                } else if (ErrorLevel = 1) {
                    Tooltip, "Spin Again" button NOT found.
                } else if (ErrorLevel = 2) {
                    Tooltip, Error: could not read image file!
                }
            } else {
                Tooltip, Discord window not found!
            }
            nextClick := A_TickCount + (interval * 1000)
        }
    }
Return

; ✅ TEST IMAGE SEARCH BUTTON
TestImageSearch:
    WinGetPos, winX, winY, winW, winH, %windowTitle%
    if (!winW || !winH) {
        MsgBox, Discord window not found. Make sure it's visible and not minimized.
        Return
    }

    ImageSearch, x, y, %winX%, %winY%, %winX% + %winW%, %winY% + %winH%, *50 %imagePath%
    if (ErrorLevel = 0) {
        MsgBox, ✅ Image Found at X: %x% Y: %y%
    } else if (ErrorLevel = 1) {
        MsgBox, ❌ Image Not Found (ErrorLevel 1)
    } else if (ErrorLevel = 2) {
        MsgBox, ⚠️ Error Reading Image File (ErrorLevel 2)
    }
Return

; ✅ TEST DISCORD DETECTION BUTTON
TestDiscordDetection:
    if WinExist(windowTitle) {
        MsgBox, ✅ Discord detected and ready.
    } else {
        MsgBox, ❌ Discord not detected. Make sure it's open and visible.
    }
Return

; ✅ CLOSE GUI EXITS SCRIPT
GuiClose:
ExitApp
