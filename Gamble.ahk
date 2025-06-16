#Persistent
SetTitleMatchMode, 2 ; Allows matching part of the window title
F8:: ; Press F8 to start or stop
    toggle := !toggle
    if (toggle) {
        MsgBox, Script Started. Press F8 to stop.
    } else {
        MsgBox, Script Stopped.
    }
return

Loop {
    if (!toggle)
        break
    ; Adjust "Discord" if needed to match the window title
    ControlClick, x100 y200, ahk_exe Discord.exe
    Sleep, 10000 ; Wait 10 seconds
}
return
