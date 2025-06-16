#Persistent
SendMode, Event
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
SetTitleMatchMode, 2

; Set your image path here:
imagePath := "C:\Users\k1ngzly\Documents\AutoHotkey\button.bmp"
windowTitle := "ahk_exe Discord.exe"

; F1: Run image detection and click test
F1::
{
    ; Get Discord window position
    WinGetPos, winX, winY, winW, winH, %windowTitle%
    if (!winW || !winH) {
        MsgBox, ❌ Discord window not found.
        return
    }

    rightX := winX + winW
    bottomY := winY + winH

    ; Try to detect the image
    imagePathFinal := imagePath
    ImageSearch, x, y, %winX%, %winY%, %rightX%, %bottomY%, *50 %imagePathFinal%

    if (ErrorLevel = 0) {
        MsgBox, ✅ Image Found at:`nX: %x%`nY: %y%`n`nDiscord Window:`n%winX%,%winY% to %rightX%,%bottomY%
        
        ; Try clicking
        MouseGetPos, prevX, prevY
        MouseMove, %x%, %y%, 0
        Sleep, 300
        Click
        Sleep, 300
        MouseMove, %prevX%, %prevY%, 0
        MsgBox, 🖱️ Click attempt complete.`nDid anything happen?

    } else if (ErrorLevel = 1) {
        MsgBox, ❌ Image not found inside Discord window.
    } else if (ErrorLevel = 2) {
        MsgBox, ⚠️ Error reading the image file.
    }
}
return

; F2: Move mouse and click at a test point (basic)
F2::
MouseMove, 200, 200, 0
Click
MsgBox, 🧪 Clicked at (200,200)
return

; F3: Confirm mouse is controllable
F3::
MouseMove, 100, 100, 0
Click
return

; F4: Get current mouse position
F4::
MouseGetPos, posX, posY
MsgBox, 📍 Current Mouse Position:`nX: %posX%`nY: %posY%
return

; Exit with ESC
Esc::ExitApp
