#Persistent
SendMode, Event
CoordMode, Pixel, Screen
CoordMode, Mouse, Screen
SetTitleMatchMode, 2

; === CONFIGURATION ===
imagePath := "C:\Users\k1ngzly\Documents\AutoHotkey\button.bmp"
windowTitle := "ahk_exe Discord.exe"

; === FUNCTION: Hardware-Level Click ===
SendRealClick(x, y)
{
    ; Move the cursor to the specified position
    DllCall("SetCursorPos", "int", x, "int", y)
    DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0) ; Mouse down
    Sleep, 50
    DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0) ; Mouse up
}

; === F1: ImageSearch + Real Click Test ===
F1::
{
    WinGetPos, winX, winY, winW, winH, %windowTitle%
    if (!winW || !winH) {
        MsgBox, ❌ Discord window not found.
        return
    }

    rightX := winX + winW
    bottomY := winY + winH
    imagePathFinal := imagePath

    ImageSearch, x, y, %winX%, %winY%, %rightX%, %bottomY%, *50 %imagePathFinal%

    if (ErrorLevel = 0) {
        ; ✅ Offset to center of the button (72x24)
        x := x + 36
        y := y + 12

        MsgBox, ✅ Image Found at:`nTop-Left: %x%-36, %y%-12`nClicking Center at: %x%, %y%`n`nDiscord Window:`n%winX%,%winY% to %rightX%,%bottomY%

        SendRealClick(x, y)
        MsgBox, 🖱️ Real Click Sent at %x%, %y%`nDid it click properly?

    } else if (ErrorLevel = 1) {
        MsgBox, ❌ Image not found inside Discord window.
    } else if (ErrorLevel = 2) {
        MsgBox, ⚠️ Error reading the image file.
    }
}
return

; === F2: Basic MouseMove + Click at 200,200 (AHK) ===
F2::
MouseMove, 200, 200, 0
Click
MsgBox, 🧪 AHK Clicked at (200,200)
return

; === F3: Basic Move/Click test ===
F3::
MouseMove, 100, 100, 0
Click
return

; === F4: Show current mouse position ===
F4::
MouseGetPos, posX, posY
MsgBox, 📍 Current Mouse Position:`nX: %posX%`nY: %posY%
return

; === ESC: Exit Program ===
Esc::ExitApp
