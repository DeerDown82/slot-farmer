#Requires AutoHotkey v2.0+
#Persistent
SetTimer(TestLoop, 1000)

counter := 0

TestLoop() {
    global counter
    counter += 1
    ToolTip("Timer has run " counter " times.")
}
