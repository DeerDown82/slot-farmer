#Requires AutoHotkey v2.0

counter := 0

TestLoop(*) {
	global counter
	counter += 1
	ToolTip("Timer has run " counter " times.")
}

SetTimer(TestLoop, 1000)
