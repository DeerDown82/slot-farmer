; === IMAGE MANAGER ===
; Handles all image-related operations including searching and clicking

; Search for an image within a window
; Returns: object with x, y, found or empty object if not found
SearchImage(imageName, windowTitle = "", variation = "") {
    if (variation = "")
        variation := ImageVariation
        
    if (windowTitle = "")
        windowTitle := DiscordWindowTitle
    
    ; Get window position and size first
    WinGetPos, winX, winY, winW, winH, %windowTitle%
    if (!winW || !winH) {
        return {}
    }
    
    ; Build full image path relative to script location
    scriptDir := A_ScriptDir
    if (FileExist(scriptDir "\..\images\main\" imageName)) {
        imagePath := scriptDir "\..\images\main\" imageName
    } else if (FileExist(scriptDir "\images\main\" imageName)) {
        imagePath := scriptDir "\images\main\" imageName
    } else {
        return {}
    }
    
    ; Perform image search with the full path
    ImageSearch, foundX, foundY, %winX%, %winY%, % winX + winW, % winY + winH, *%variation% %imagePath%
    
    if (ErrorLevel = 0) {
        return {x: foundX, y: foundY, found: true}
    }
    
    return {}
}

; Click at the center of a found image with optional offset
ClickImage(imageName, offsetX = 0, offsetY = 0, useRealClick = false) {
    result := SearchImage(imageName)
    if (result.found) {
        targetX := result.x + offsetX
        targetY := result.y + offsetY
        
        if (useRealClick) {
            SendRealClick(targetX, targetY)
        } else {
            SendFakeClick(targetX, targetY)
        }
        return true
    }
    return false
}

; Real click function - moves cursor and performs click
SendRealClick(x, y) {
    DllCall("SetCursorPos", "int", x, "int", y)
    DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
    Sleep, 10
    DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
}

; Fake click - moves cursor, clicks, and returns to original position
SendFakeClick(x, y) {
    DllCall("GetCursorPos", "Int64*", origPos)
    DllCall("SetCursorPos", "int", x, "int", y)
    DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0)
    DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0)
    MouseMove, % (origPos & 0xFFFFFFFF), % (origPos >> 32), 0
}
