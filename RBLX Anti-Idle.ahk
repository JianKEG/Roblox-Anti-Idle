#NoEnv
#SingleInstance Force
SetBatchLines, -1
SendMode Input

global isClicking := false
global clickDelay := 50
global capturedX := 0
global capturedY := 0
global positionCaptured := false
global previousActiveWindow := 0
global wasPreviouslyMinimized := false
global useSpacebar := false

global IdleMethod
global Minutes
global Seconds
global Millisecs
global PositionText
global Button5
global Button6

CreateClickerGUI()

CreateClickerGUI() {
    Gui, New, +AlwaysOnTop, Roblox Anti-Idle
    Gui, Font, s10
    
    Gui, Add, GroupBox, x10 y10 w280 h110, Click Interval
    
    Gui, Add, Text, x85 y35 w60 h25, Minutes:
    Gui, Add, Edit, x150 y32 w50 h25 vMinutes, 0
    Gui, Add, UpDown, Range0-19, 0
    
    Gui, Add, Text, x20 y70 w60 h25, Seconds:
    Gui, Add, Edit, x85 y67 w50 h25 vSeconds, 0
    Gui, Add, UpDown, Range0-59, 0
    
    Gui, Add, Text, x145 y70 w60 h25, Millisecs:
    Gui, Add, Edit, x210 y67 w50 h25 vMillisecs, 50
    Gui, Add, UpDown, Range0-999, 50
    
    Gui, Add, Button, x30 y105 w100 h30 gUpdateInterval, Apply Interval
    Gui, Add, Button, x160 y105 w100 h30 gResetInterval, Reset
    
    Gui, Add, GroupBox, x10 y140 w280 h90, Click Position
    
    Gui, Add, Text, x20 y160 w150 h20, Current Position:
    Gui, Add, Text, x170 y160 w120 h20 vPositionText, Not captured
    
    Gui, Add, Button, x30 y190 w230 h25 gCapturePositionBtn, Capture Position

    Gui, Add, GroupBox, x10 y235 w280 h60, Anti-Idle Method
    Gui, Add, Radio, x30 y255 w120 h30 vIdleMethod gSpaceMethod Checked, Mouse Click
    Gui, Add, Radio, x160 y255 w100 h30 gSpaceMethod, Jump

    Gui, Add, Button, x30 y305 w100 h30 gStartClickingBtn vButton5, Start
    Gui, Add, Button, x160 y305 w100 h30 gStopClickingBtn vButton6 +Disabled, Stop
    
    Gui, Add, Text, x10 y345 w280 h20 cGray, Created by jiankeg
    
    GuiControl,, PositionText, Not captured
    
    Gui, Show, w300 h370
    return
}

UpdateInterval:
    Gui, Submit, NoHide

    if (Minutes > 19){
        Minutes := 19
        GuiControl,, Minutes, 19
    }

    if (Seconds > 59){
        Seconds := 59
        GuiControl,, Seconds, 59
    }

    if (Millisecs > 999){
        Millisecs := 999
        GuiControl,, Millisecs, 999
    }

    newDelay := (Minutes * 60000) + (Seconds * 1000) + Millisecs
    if (newDelay < 1)
        newDelay := 1
    clickDelay := newDelay
    if (isClicking) {
        SetTimer, PerformMacro, Off
        SetTimer, PerformMacro, %clickDelay%
    }
    ToolTip, Click Delay set to %clickDelay%ms, 5, 5
    Sleep, 1000
    ToolTip
    return

ResetInterval:
    GuiControl,, Hours, 0
    GuiControl,, Minutes, 0
    GuiControl,, Seconds, 0
    GuiControl,, Millisecs, 50
    clickDelay := 50
    if (isClicking) {
        SetTimer, PerformMacro, Off
        SetTimer, PerformMacro, %clickDelay%
    }
    ToolTip, Click Delay reset to 50ms, 5, 5
    Sleep, 1000
    ToolTip
    return

CapturePositionBtn:
    CapturePosition()
    return

F1::
    StartClickingBtn:
        StartClicking()
        return
    return
F2::
    StopClickingBtn:
        StopClicking()
        return
    return
F5::
    ;shows or hides the gui
    global isClicking

    DetectHiddenWindows, On
    if WinExist("Roblox Anti-Idle") {
        WinGet, windowState, Style, Roblox Anti-Idle
        isVisible := (windowState & 0x10000000) 
        
        if (isVisible) {
         
            WinHide, Roblox Anti-Idle
            TrayTip, Roblox Anti-Idle, GUI hidden. Press F5 to show again., 2, 17
        } else {

            WinShow, Roblox Anti-Idle
            
            if (isClicking) {
                GuiControl, Disable, Button5
                GuiControl, Enable, Button6
            } else {
                GuiControl, Enable, Button5
                GuiControl, Disable, Button6
            }
        }
    } 

    DetectHiddenWindows, Off
    return

SpaceMethod:
    Gui, Submit, NoHide

    useSpacebar := (IdleMethod = 2)
        
    if (useSpacebar) {
        GuiControl, Disable, Capture Position
        GuiControl,, PositionText, Not needed
        ToolTip, Spacebar mode selected - position not needed, 5, 5
        Sleep, 1000
        ToolTip
    } else {
        GuiControl, Enable, Capture Position
        if (positionCaptured)
            GuiControl,, PositionText, X: %capturedX%, Y: %capturedY%
        else
            GuiControl,, PositionText, Not captured
    }
    return

CapturePosition() {
    if (!WinExist("ahk_exe RobloxPlayerBeta.exe")) {
        ToolTip, Error: Roblox is not running., 5, 5
        Sleep, 2000
        ToolTip
        return
    }
    
    WinGet, previousWindow, ID, A
    
    WinActivate, ahk_exe RobloxPlayerBeta.exe
    Sleep, 100  
    
    ToolTip, Now hover your mouse over the desired position and press F4, 5, 5
    KeyWait, F4, D
    KeyWait, F4
    
    MouseGetPos, capturedX, capturedY, capturedWin
    
    WinGet, capturedExe, ProcessName, ahk_id %capturedWin%
    if (capturedExe != "RobloxPlayerBeta.exe") {
        ToolTip, Error: Position not captured on Roblox window, 5, 5
        Sleep, 2000
        ToolTip

        WinActivate, ahk_id %previousWindow%
        return
    }
    
    positionCaptured := true
    GuiControl,, PositionText, X: %capturedX%, Y: %capturedY%
    
    ToolTip, Position captured successfully!, 5, 5
    Sleep, 1000
    ToolTip
    
    WinActivate, ahk_id %previousWindow%
}

StartClicking() {
    global isClicking, positionCaptured, useSpacebar
    
    if (!useSpacebar && !positionCaptured) {
        ToolTip, Please capture a position first!, 5, 5
        Sleep, 1000
        ToolTip
        return
    }
    
    isClicking := true
    
    SetTimer, PerformMacro, %clickDelay%
    TrayTip, Roblox Anti Idle, Auto Clicker: RUNNING. Press F2 to stop. Press F5 to show gui., 2, 17
    GuiControl, Disable, Button5
    GuiControl, Enable, Button6

    WinHide, Roblox Anti-Idle
}

StopClicking() {
    global isClicking
    isClicking := false
    
    SetTimer, PerformMacro, Off
    TrayTip, Roblox Anti Idle, Auto Clicker: STOPPED. Press F1 to start again., 2, 17
    GuiControl, Enable, Button5
    GuiControl, Disable, Button6

    WinShow, Roblox Anti-Idle
}

PerformMacro() {
    global isClicking, capturedX, capturedY, previousActiveWindow, wasPreviouslyMinimized, useSpacebar
    
    if (!isClicking)
        return
    
    if (WinExist("ahk_exe RobloxPlayerBeta.exe")) {
        WinGet, previousActiveWindow, ID, A
        
        WinGet, activeWin, ID, A
        WinGet, activeExe, ProcessName, ahk_id %activeWin%
        robloxIsActive := (activeExe = "RobloxPlayerBeta.exe")
        
        WinGet, robloxID, ID, ahk_exe RobloxPlayerBeta.exe
        WinGet, robloxMinMax, MinMax, ahk_id %robloxID%
        
        wasPreviouslyMinimized := (robloxMinMax = -1)
        
        if (!robloxIsActive) {
            if (useSpacebar){
                WinSet, Transparent, 0, ahk_exe RobloxPlayerBeta.exe
            }

            if (wasPreviouslyMinimized) {
                WinRestore, ahk_exe RobloxPlayerBeta.exe
            }
            
            WinActivate, ahk_exe RobloxPlayerBeta.exe
            Sleep, 250
        }
        
        if (useSpacebar) {
            Send, {Space down}
            Sleep, 50
            Send, {Space up}
        } else {
            MouseMove, capturedX+1, capturedY+1, 0 
            MouseMove, %capturedX%, %capturedY%, 0  
            Click, %capturedX% %capturedY%
            Sleep, 150
            MouseMove, capturedX+1, capturedY+1, 0 
            MouseMove, %capturedX%, %capturedY%, 0  
            Click, %capturedX% %capturedY%
        }
        
        Sleep, 250
        
        if (!robloxIsActive) {
            WinSet, Bottom,, ahk_exe RobloxPlayerBeta.exe
            
            if (wasPreviouslyMinimized) {
                WinMinimize, ahk_exe RobloxPlayerBeta.exe
            }
            
            if (useSpacebar){
            WinSet, Transparent, 255, ahk_exe RobloxPlayerBeta.exe
            }
            
            WinActivate, ahk_id %previousActiveWindow%
        }
    } else {
        StopClicking()
        ToolTip, Roblox window not found. Anti-Idle stopped., 5, 5
        Sleep, 3000
        ToolTip
    }
}

GuiClose:
    ExitApp
    return

Esc::ExitApp
