DEFTYPE.w

;SACBRLDU
#GamePad_Up = 0
#GamePad_Down = 1
#GamePad_Left = 2
#GamePad_Right = 3
#GamePad_B = 4
#GamePad_C = 5
#GamePad_A = 6
#GamePad_Start = 7

#IsTrue = -1 ;Don't use the "TRUE" or "FALSE" keywords, these trigger the addition of the MATHFFP library
#IsFalse = 0

#FirstSprite = 8

#TilemapWidth = 128
#TilemapHeight = 128
#MWidth = 512
#MHeight = 512
#XRes = 320
#YRes = 256

Macro Setup

    InitPalette 0,32
    InitPalette 1,32
    LoadPalette 0,"palette.amiga",16
    LoadPalette 0,"palette.amiga"
    BitMap 0,#TilemapWidth,#TilemapHeight,4
    LoadBitmap 0,"tiles.amiga"

    for TileY = 0 to #TilemapHeight / 16 - 1
        for TileX = 0 to #TilemapWidth / 16 - 1
            GetaShape 0,TileX*16,TileY*16,16,16
            GetaSprite SpriteID,0
            SpriteID + 1
        next
    next

    BitMap 1,#MWidth,#MHeight,4
    Dim Tiles.b(#MWidth/16 - 1,#MHeight/16 - 1)

    if ReadFile(0,"nametable.amiga")
        ReadMem 0,&Tiles(0,0),(#MWidth/16) * (#MHeight/16)
        CloseFile 0
    endif

    BLITZ
    InitCopList 0,44,#YRes,$10 + $4,8,32,0
    !Fade_Palette{0}
    CreateDisplay 0

    Use Bitmap 1
    for TileY = 0 to #MWidth/16 - 1
        for TileX = 0 to #MHeight / 16 -1

            SourceTileX = (Tiles(TileX,TileY) mod (#MWidth / 16)) * 16
            SourceTileY = (Tiles(TileX,TileY) / (#MHeight / 16)) * 16
            BlockScroll SourceTileX,SourceTileY,16,16,TileX*16,TileY*16,0

        next
    next

    DisplayBitMap 0,1
End macro

Macro Fade_Palette
    FadePalette 0,1,`1
    DisplayPalette 0,1
End Macro

Macro WaitForVBlank
    VWait
End Macro

Function.w ReadJoy{}
    Result.w
    
    if JoyY(1)
        if JoyY(1) < 0
            Result BITSET #GamePad_Up
        else
            Result BITSET #GamePad_Down
        endif
    endif

    if JoyX(1)
        if JoyX(1) < 0
            Result BITSET #GamePad_Left
        else
            Result BITSET #GamePad_Right
        endif
    endif

    if JoyB(1)
        Result BITSET #GamePad_B
    endif
    
	Function Return Result

End Statement

Macro ScrollCamera
    DisplayBitMap 0,1,`1,`2
End Macro

Statement RenderSprite{SpriteID,X,Y}
    DisplaySprite 0, SpriteID,X,Y,0
End Statement

Goto Game
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
