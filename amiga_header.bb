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
