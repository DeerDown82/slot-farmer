#Requires AutoHotkey v2.0
SendMode("Event")
CoordMode("Pixel", "Screen")
CoordMode("Mouse", "Screen")

; === CONFIGURATION ===
imagePath := "C:\Users\k1ngzly\Documents\AutoHotkey\button.bmp"
windowTitle := "ahk_exe Discord.exe"
intervalSeconds := 10
nextClick := 0
isRunning := false

; === FUNCTION: Real Hardware-Level Click ===
SendRealClick(x, y) {
    DllCall("SetCursorPos", "int", x, "int", y)
    DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0) ; Mouse down
    Sleep(50)
    DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0) ; Mouse up
}

; === GUI SETUP ===
gui := Gui()
gui.Add("Text", "vStatusText", "Status: Not Running")
gui.Add("Text", "vCountdownText", "Next Click In: N/A")
gui.Add("Button", "w150", "Start/Stop").OnEvent("Click", ToggleScript)
gui.Add("Button", "w150", "Test Image Search").OnEvent("Click", TestImageSearch)
gui.Add("Button", "w150", "Test Discord Detection").OnEvent("Click", TestDiscordDetection)
gui.Show("AutoSize Center", "Auto Clicker Status")

statusText := gui["StatusText"]
countdownText := gui["CountdownText"]

; === TIMER LOOP ===
SetTimer(ClickLoop, 100)

ClickLoop(*) {
	global isRunning, nextClick, intervalSeconds, imagePath, windowTitle, gui

	if !isRunning
		return

	timeLeft := Round((nextClick - A_TickCount()) / 1000)
	if (timeLeft < 0)
		timeLeft := 0
	gui["CountdownText"].Value := "Next Click In: " timeLeft " seconds"

	if A_TickCount() >= nextClick {
		WinGetPos(&winX, &winY, &winW, &winH, windowTitle)
		if (winW && winH) {
			rightX := winX + winW
			bottomY := winY + winH
			ImageSearch(&x, &y, winX, winY, rightX, bottomY, "*50 " imagePath)
			if (ErrorLevel = 0) {
				x := x + 36
				y := y + 12
				SendRealClick(x, y)
			}
		}
		nextClick := A_TickCount() + (intervalSeconds * 1000)
	}
}

; === BUTTON HANDLERS ===
ToggleScript(*) {
	global isRunning, nextClick, intervalSeconds, gui

	isRunning := !isRunning
	if (isRunning) {
		nextClick := A_TickCount() + (intervalSeconds * 1000)
		gui["StatusText"].Value := "Status: Running"
	else {
		gui["StatusText"].Value := "Status: Not Running"
		gui["CountdownText"].Value := "Next Click In: N/A"
	}
}

TestImageSearch(*) {
	global imagePath, windowTitle

	WinGetPos(&winX, &winY, &winW, &winH, windowTitle)
	if (!winW || !winH) {
		MsgBox("Discord window not found.")
		return
	}

	rightX := winX + winW
	bottomY := winY + winH
	ImageSearch(&x, &y, winX, winY, rightX, bottomY, "*50 " imagePath)
	if (ErrorLevel = 0) {
		MsgBox("Image Found at:`nTop-Left: " x ", " y "`nCenter: " x+36 ", " y+12)
	} else if (ErrorLevel = 1) {
		MsgBox("Image Not Found (ErrorLevel 1)")
	} else if (ErrorLevel = 2) {
		MsgBox("Error Reading Image File (ErrorLevel 2)")
	}
}

TestDiscordDetection(*) {
	global windowTitle
	if WinExist(windowTitle)
		MsgBox("Discord detected and ready.")
	else
		MsgBox("Discord not detected.")
}
