F9:: ; Press F9 to test image search
    ImageSearch, x, y, 1920, 0, 3840, 1080, *50 C:\Users\k1ngzly\Documents\AutoHotkey\button.png
    if (ErrorLevel = 0) {
        MsgBox, Image Found at X: %x% Y: %y%
    } else {
        MsgBox, Image Not Found. ErrorLevel: %ErrorLevel%
    }
return