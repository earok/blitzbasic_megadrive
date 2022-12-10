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
;The resource importer imports the CSV and IFF, converting for both Mega Drive and Amiga formats
BitMap 0,128,128,4
LoadBitMap 0,"resources/tilemap.iff",0

Use Bitmap 0

;Do the palette first - doesn't take into account VDP ramp
InitBank 0,16 * 2,0

BankAddress.l = Bank(0)
PaletteInfo 0
PalRGB 0,0,0,0,0 ;Set the first color of the palette to black
for i = 0 to 15
    R = PalRed(i) & %1110
    G = PalGreen(i) & %1110
    B = PalBlue(i) & %1110
    Poke.w BankAddress,(B LSL 8) | (G LSL 4) | R
    BankAddress + 2
next
SaveBank 0,"palette.megadrive"
SavePalette 0,"palette.amiga"

;There are two pixels per byte
InitBank 0,(#TilemapWidth * #TilemapHeight) / 2,0
BankAddress = Bank(0)

;Do the tiles (patterns) second. We're converting to 16 by 16
for TileY = 0 to #TilemapHeight / 16 - 1
    for TileX = 0 to #TilemapWidth / 16 - 1

        for SubTileX = 0 to 1
            for SubTileY = 0 to 1

                for PY = 0 to 7
                    for PX = 0 to 7

                        Col = Point(TileX * 16 + SubTileX * 8 + PX,TileY * 16 + SubTileY * 8 + PY)

                        if PX & 1 = 0
                            ;Left side of pixel pair
                            PixelPair.b = Col LSL 4
                        else
                            ;Right side of pixel pair
                            PixelPair.b | Col
                            Poke.b BankAddress,PixelPair
                            BankAddress + 1
                        endif
                        

                    next
                next

            next
        next
    next

next

SaveBitmap 0,"tiles.amiga"
SaveBank 0,"tiles.megadrive"

;Finally, parse the map (nametable)
LoadBank 0,"resources/tilemap.csv",0
BankAddress = Bank(0)
Dim Tiles.b(#MWidth/16 - 1,#MHeight/16 - 1)

For TileY = 0 to #MWidth / 16 - 1
    for TileX = 0 to #MHeight / 16 - 1
        
        ;CSV parse
        TileID = 0
        DigitIsFound = false        

        Repeat
            Char = Peek.b(BankAddress)
            if Char >= 48 and Char <= 57
                ;This is a valid digit
                DigitIsFound = true
                TileID * 10
                TileID + (Char - 48)
            endif
            BankAddress + 1            
        Until (Char < 48 or Char > 57) and DigitIsFound
        Tiles(TileX,TileY) = TileID

    next
next

;Convert the name table into Mega Drive format, with four 8x8 tiles per one 16x16 tile
Dim MDNameTable.w(#MWidth/8 - 1,#MHeight/8 - 1)
For TileY = 0 to #MWidth / 16 - 1
    for TileX = 0 to #MHeight / 16 - 1

        TileID = Tiles(TileX,TileY) * 4
        MDNameTable(TileX * 2 + 0,TileY * 2 + 0) = TileID
        MDNameTable(TileX * 2 + 0,TileY * 2 + 1) = TileID + 1
        MDNameTable(TileX * 2 + 1,TileY * 2 + 0) = TileID + 2
        MDNameTable(TileX * 2 + 1,TileY * 2 + 1) = TileID + 3

    next
next

if WriteFile(0,"nametable.amiga")
    WriteMem 0,&Tiles(0,0),(#MWidth/16) * (#MHeight/16)
    CloseFile 0
endif

if WriteFile(0,"nametable.megadrive")
    WriteMem 0,&MDNameTable(0,0),(#MWidth/8) * (#MHeight/8) * 2
    CloseFile 0
endif


End
