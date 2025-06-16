; === DISCORD CONTROLLER ===
; Handles all Discord-specific automation

class DiscordController {
    ; Run the slots command and handle the UI
    static RunSlotsAndFreeze() {
        ; Save original cursor position
        DllCall("GetCursorPos", "Int64*", origPos)
        
        ; Open chat input
        this.FocusChatInput()
        
        ; Send slots command
        this.SendSlotsCommand()
        
        ; Open shop icons
        this.OpenShopIcons()
        
        ; Scroll up a bit to anchor
        this.ScrollUp()
        
        ; Return mouse to original position
        MouseMove, % (origPos & 0xFFFFFFFF), % (origPos >> 32), 0
    }
    
    ; Focus the chat input area
    static FocusChatInput() {
        ; This is a placeholder - actual implementation will depend on Discord's UI
        ; We'll need to find a better way to locate the chat input
        Click, 620, 1306
        Sleep, % Config.CommandDelay
    }
    
    ; Send the slots command
    static SendSlotsCommand() {
        SendInput, % Config.SlotsCommand "{Enter}"
        Sleep, 4000  ; Wait for slots to appear
    }
    
    ; Open shop icons
    static OpenShopIcons() {
        this.FocusChatInput()
        
        ; Type /shop icons
        SendRaw, /
        Sleep, % Config.CommandDelay
        SendRaw, shop
        Sleep, % Config.CommandDelay
        Send, {Space}
        Sleep, % Config.CommandDelay
        SendRaw, icons
        Sleep, % Config.CommandDelay
        SendInput, {Space}
        Sleep, % Config.CommandDelay
        SendInput, {Enter}
        Sleep, 2000  ; Wait for UI to update
    }
    
    ; Scroll up in the chat
    static ScrollUp() {
        ; Move to a position where scrolling will work
        Click, 767, 1052
        Sleep, % Config.CommandDelay
        
        ; Scroll up
        Loop, 2 {
            SendInput, {WheelUp}
            Sleep, 30
        }
    }
    
    ; Check if the play again button is visible
    static IsPlayAgainButtonVisible() {
        return ImageManager.SearchImage(Config.ButtonImage).found
    }
    
    ; Click the play again button
    static ClickPlayAgain() {
        ; Click at the button's center with a small offset if needed
        return ImageManager.ClickImage(Config.ButtonImage, 36, 12)
    }
}

; Include guard
if (A_LineFile = A_ScriptFullPath) {
    MsgBox % "DiscordController module loaded. This is a support file and should be included by the main script."
    ExitApp
}
