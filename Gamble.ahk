#Persistent
SetTitleMatchMode, 2
SendMode, Event
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; === CONFIGURATION ===
imagePath := "C:\Users\k1ngzly\Documents\AutoHotkey\button.bmp"
windowTitle := "ahk_exe Discord.exe"
interval := 10 ; seconds between clicks

; === FUNCTION: Real Hardware-Level Click ===
SendRealClick(x, y)
{
    DllCall("SetCursorPos", "int", x, "int", y)
    DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0) ; Mouse down
    Sleep, 50
    DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0) ; Mouse up
}

; === GUI SETUP ===
Gui, Add, Text, vStatusText, Status: Not Running
Gui, Add, Text, vCountdownText, Next Click In: N/A
Gui, Add, Button, gToggleScript w150 h30, Start/Stop
Gui, Add, Button, gTestImageSearch w150 h30, Test Image Search
Gui, Add, Button, gTestDiscordDetection w150 h30, Test Discord Detection
Gui, Show,, Auto Clicker Status

toggle := false
nextClick := 0

Return

; === TOGGLE START/STOP ===
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

; === MAIN TIMER LOOP ===
SetTimer, ClickLoop, 100
Return

ClickLoop:
    if (toggle) {
        timeLeft := Round((nextClick - A_TickCount) / 1000)
        if (timeLeft < 0) {
            timeLeft := 0
        }
        GuiControl,, CountdownText, Next Click In: %timeLeft% seconds

        if (A_TickCount >= nextClick) {
            WinGetPos, winX, winY, winW, winH, %windowTitle%
            if (winW && winH) {
                imagePathFinal := imagePath
                rightX := winX + winW
                bottomY := winY + winH
                ImageSearch, x, y, %winX%, %winY%, %rightX%, %bottomY%, *50 %imagePathFinal%
                if (ErrorLevel = 0) {
                    ; Offset to center of button (72x24)
                    x := x + 36
                    y := y + 12
                    SendRealClick(x, y)
                    Tooltip, Clicked "Spin Again" at %x%, %y%
                } else if (ErrorLevel = 1) {
                    Tooltip, "Spin Again" button NOT found.
                } else if (ErrorLevel = 2) {
                    Tooltip, Error reading image file!
                }
            } else {
                Tooltip, Discord window not found!
            }
            nextClick := A_TickCount + (interval * 1000)
        }
    }
Return

; === TEST IMAGE SEARCH BUTTON ===
TestImageSearch:
    WinGetPos, winX, winY, winW, winH, %windowTitle%
    if (!winW || !winH) {
        MsgBox, Discord window not found. Make sure it's visible and not minimized.
        Return
    }

    imagePathFinal := imagePath
    rightX := winX + winW
    bottomY := winY + winH
    ImageSearch, x, y, %winX%, %winY%, %rightX%, %bottomY%, *50 %imagePathFinal%
    if (ErrorLevel = 0) {
        x_center := x + 36
        y_center := y + 12
        MsgBox, Image Found at:`nTop-Left: %x%, %y%`nClick Center: %x_center%, %y_center%
    } else if (ErrorLevel = 1) {
        MsgBox, Image Not Found (ErrorLevel 1)
    } else if (ErrorLevel = 2) {
        MsgBox, Error Reading Image File (ErrorLevel 2)
    }
Return

; === TEST DISCORD DETECTION BUTTON ===
TestDiscordDetection:
    if WinExist(windowTitle) {
        MsgBox, Discord detected and ready.
    } else {
        MsgBox, Discord not detected. Make sure it's open and visible.
    }
Return

; === DEBUG HOTKEY: TEST CLICK ===
F9::
MouseMove, 100, 100, 0
Click
return

; === CLOSE GUI EXITS SCRIPT ===
GuiClose:
ExitApp
