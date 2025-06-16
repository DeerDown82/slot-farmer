; Set the coordinates (replace these with your actual coords from Window Spy)
CoordMode, Mouse, Screen
x := 2296  ; Replace with actual X coordinate
y := 728  ; Replace with actual Y coordinate

; Press F8 to start or stop the script
toggle := true

F8::
toggle := !toggle
if (toggle) {
    MsgBox, Script Started. Press F8 to stop.
} else {
    MsgBox, Script Stopped.
}
return

; Main Loop
Loop {
    if (!toggle)
        break
    MouseMove, x, y
    Sleep, 100
    Click
    Sleep, 10000 ; 10 seconds
}
return
