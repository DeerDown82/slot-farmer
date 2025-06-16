#Persistent
SetTimer, TestLoop, 1000
Return

TestLoop:
    static n := 0
    n++
    ToolTip, Timer has run %n% times.
Return
