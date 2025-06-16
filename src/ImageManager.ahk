; === IMAGE MANAGER ===
; Handles all image-related operations including searching and clicking

class ImageManager {
    ; Search for an image within a window
    ; Returns: object with x, y, found or empty object if not found
    static SearchImage(imageName, windowTitle := "", variation := "") {
        if (variation = "")
            variation := Config.ImageVariation
            
        if (windowTitle = "")
            windowTitle := Config.DiscordWindowTitle
            
        ; Get window position and size
        WinGetPos, winX, winY, winW, winH, %windowTitle%
        if (!winW || !winH) {
            return {}
        }
        
        ; Build full image path
        imagePath := Config.GetImagePath(imageName)
        
        ; Perform image search
        ImageSearch, foundX, foundY, %winX%, %winY%, % winX + winW, % winY + winH, *%variation% %imagePath%
        
        if (ErrorLevel = 0) {
            return {x: foundX, y: foundY, found: true}
        }
        
        return {}
    }
    
    ; Click at the center of a found image with optional offset
    static ClickImage(imageName, offsetX := 0, offsetY := 0, useRealClick := false) {
        result := this.SearchImage(imageName)
        if (result.found) {
            targetX := result.x + offsetX
            targetY := result.y + offsetY
            
            if (useRealClick) {
                this.SendRealClick(targetX, targetY)
            } else {
                this.SendFakeClick(targetX, targetY)
            }
            return true
        }
        return false
    }
    
    ; Real click function - moves cursor and performs click
    static SendRealClick(x, y) {
        DllCall("SetCursorPos", "int", x, "int", y)
        DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
        Sleep, 10
        DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0, "UPtr", 0)
    }
    
    ; Fake click - moves cursor, clicks, and returns to original position
    static SendFakeClick(x, y) {
        DllCall("GetCursorPos", "Int64*", origPos)
        DllCall("SetCursorPos", "int", x, "int", y)
        DllCall("mouse_event", "UInt", 0x0002, "UInt", 0, "UInt", 0, "UInt", 0)
        DllCall("mouse_event", "UInt", 0x0004, "UInt", 0, "UInt", 0, "UInt", 0)
        MouseMove, % (origPos & 0xFFFFFFFF), % (origPos >> 32), 0
    }
}

; Include guard
if (A_LineFile = A_ScriptFullPath) {
    MsgBox % "ImageManager module loaded. This is a support file and should be included by the main script."
    ExitApp
}
