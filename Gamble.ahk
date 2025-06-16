#Persistent
SetTitleMatchMode, 2
SetDefaultMouseSpeed, 0
SendMode, Event
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen

; === CONFIGURATION ===
imagePath := "C:\Users\k1ngzly\Documents\AutoHotkey\button.bmp"
windowTitle := "ahk_exe Discord.exe"
interval := 8
execCount := 0
nextClick := 0
toggle := false

; === REAL CLICK FUNCTION ===
SendRealClick(x, y) {
    DllCall("SetCursorPos", "int", x, "int", y)
    DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
    Sleep, 10
    DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
}

SendFakeClick(x, y) {
    DllCall("GetCursorPos", "Int64*", origPos)
    DllCall("SetCursorPos", "int", x, "int", y)
    DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0)
    DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0)
    MouseMove, % (origPos & 0xFFFFFFFF), % (origPos >> 32), 0
}

; === GUI ===
Gui, Add, Text, vStatusText, Status: Not Running
Gui, Add, Text, vCountdownText, Next Click In: N/A
Gui, Add, Text, vExecCountText, Executions: 0
Gui, Add, Button, gToggleScript w150 h30, Start/Stop
Gui, Add, Button, gTestImageSearch w150 h30, Test Image Search
Gui, Add, Button, gTestDiscordDetection w150 h30, Test Discord Detection
Gui, Show,, Auto Clicker Status

SetTimer, ClickLoop, 50
Return

; === LOOP ===
ClickLoop:
    if (!toggle)
        return

    timeLeft := Round((nextClick - A_TickCount) / 1000)
    if (timeLeft < 0)
        timeLeft := 0
    GuiControl,, CountdownText, Next Click In: %timeLeft% seconds

    if (A_TickCount >= nextClick) {
        WinGetPos, winX, winY, winW, winH, %windowTitle%
        if (winW && winH) {
            imagePathFinal := imagePath
            rightX := winX + winW
            bottomY := winY + winH
            ImageSearch, x, y, %winX%, %winY%, %rightX%, %bottomY%, *50 %imagePathFinal%
            if (ErrorLevel = 0) {
                x := x + 36
                y := y + 12
                SendFakeClick(x, y)
				execCount += 1
				GuiControl,, ExecCountText, Executions: %execCount%
            }
        }
        nextClick := A_TickCount + (interval * 1000)
    }
Return

; === TOGGLE ===
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

; === TEST IMAGE BUTTON ===
TestImageSearch:
    WinGetPos, winX, winY, winW, winH, %windowTitle%
    if (!winW || !winH) {
        MsgBox, Discord window not found.
        Return
    }

    imagePathFinal := imagePath
    rightX := winX + winW
    bottomY := winY + winH
    ImageSearch, x, y, %winX%, %winY%, %rightX%, %bottomY%, *50 %imagePathFinal%
    if (ErrorLevel = 0) {
        x_center := x + 36
        y_center := y + 12
        MsgBox, Image Found:`nTop-Left: %x%, %y%`nCenter: %x_center%, %y_center%
    } else if (ErrorLevel = 1) {
        MsgBox, Image Not Found
    } else if (ErrorLevel = 2) {
        MsgBox, Error Reading Image
    }
Return

; === TEST DISCORD DETECTION ===
TestDiscordDetection:
    if WinExist(windowTitle) {
        MsgBox, Discord detected
    } else {
        MsgBox, Discord not detected
    }
Return

; === EXIT ===
GuiClose:
ExitApp
