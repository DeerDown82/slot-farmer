F9::
MsgBox, Starting image search...
ImageSearch, x, y, 0, 0, A_ScreenWidth, A_ScreenHeight, *50 C:\Users\k1ngzly\Documents\AutoHotkey\button.bmp
if (ErrorLevel = 0)
    MsgBox, Image Found at X: %x% Y: %y%
else if (ErrorLevel = 1)
    MsgBox, Image Not Found (ErrorLevel 1)
else if (ErrorLevel = 2)
    MsgBox, Error Reading Image (ErrorLevel 2) — check path or format!
return
