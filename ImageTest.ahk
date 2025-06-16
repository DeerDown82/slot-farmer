F9:: ; Press F9 to test
    ImageSearch, x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 C:\Users\k1ngzly\Documents\AutoHotkey\button.png
    if (ErrorLevel = 0) {
        MsgBox, Image Found at X: %x% Y: %y%
    } else if (ErrorLevel = 1) {
        MsgBox, Image Not Found.
    } else if (ErrorLevel = 2) {
        MsgBox, Problem with the image path or command.
    }
return
