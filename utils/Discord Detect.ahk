F10:: ; Press F10 to check Discord detection
    if WinExist("ahk_exe Discord.exe") {
        MsgBox, Discord is detected.
    } else {
        MsgBox, Discord is not detected. Make sure it's running.
    }
return
