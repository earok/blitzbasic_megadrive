;This is the main game file, shared between Mega Drive and Amiga
;All code in here should be abstracted to work with both Amiga and Mega Drive
.Game
CameraX.q = 0
CameraY.q = 0

PlayerX.q = 64
PlayerY.q = 64

WalkCycle.q = 0
PlayerDirection.w = 0

;Replacement for QLimit function that don't rely on external libraries
Function.q Limit{Value.q,MinValue.q,MaxValue.q}
    if Value < MinValue
        Function Return MinValue
    endif
    if Value > MaxValue
        Function Return MaxValue
    endif
    Function return Value
End Function

;Fade to nothing
!Setup
!Fade_Palette{0}
RenderSprite{#FirstSprite,PlayerX - CameraX,PlayerY - CameraY}

;Fade in the palette over a second before starting game
for i = 1 to 50 
    !WaitForVBlank
    !Fade_Palette{i/50}
next

While #IsTrue

    Joy.w = ReadJoy{}

    if Joy BITTST #GamePad_Right
        PlayerX + 1
        PlayerDirection = 2
        WalkCycle + .1
    else
        if Joy BITTST #GamePad_Left
            PlayerX - 1
            PlayerDirection = 3
            WalkCycle + .1
        endif
    endif

    if Joy BITTST #GamePad_Down
        PlayerY + 1
        PlayerDirection = 1
        WalkCycle + .1
    else
        if Joy BITTST #GamePad_Up
            PlayerY - 1
            PlayerDirection = 0
            WalkCycle + .1
        endif
    endif    

    CameraX = Limit{PlayerX - #XRes / 2,0,512-#XRes}
    CameraY = Limit{PlayerY - #YRes / 2,0,512-#YRes}   

    if WalkCycle >= 4
        WalkCycle - 4
    endif

    !WaitForVBlank
    !ScrollCamera{CameraX,CameraY}
    RenderSprite{PlayerDirection * 4 + #FirstSprite + WalkCycle,PlayerX - CameraX,PlayerY - CameraY}
    
Wend

__end
