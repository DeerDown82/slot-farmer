; === DISCORD SLOTS FUNCTIONALITY ===
; Original RunSlotsAndFreeze function from Gamble.ahk

RunSlotsAndFreeze() {
    DllCall("GetCursorPos", "Int64*", origPos)

    ; Open /slots
    DllCall("SetCursorPos", "int", 620, "int", 1306)
    Sleep, 10
    DllCall("mouse_event", "UInt", 0x0002)
    DllCall("mouse_event", "UInt", 0x0004)
    Sleep, 50
    SendInput, /slots 5000{Enter}
    Sleep, 4000

    ; Open /shop icons
    DllCall("SetCursorPos", "int", 620, "int", 1306)
    Sleep, 80
    DllCall("mouse_event", "UInt", 0x0002)
    DllCall("mouse_event", "UInt", 0x0004)
    Sleep, 100
    SendRaw, /
    Sleep, 80
    SendRaw, shop
    Sleep, 100
    Send, {Space}
    Sleep, 80
    SendRaw, icons
    Sleep, 150
    SendInput, {Space}
    Sleep, 150
    SendInput, {Enter}
    Sleep, 2000  ; Wait for Discord to load UI

    ; Scroll up a bit to anchor
    DllCall("SetCursorPos", "int", 767, "int", 1052)
    Sleep, 80
    Loop, 2 {
        SendInput, {WheelUp}
        Sleep, 30
    }

    ; Return mouse
    MouseMove, % (origPos & 0xFFFFFFFF), % (origPos >> 32), 0
}
