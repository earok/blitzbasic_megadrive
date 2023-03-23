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
;adapted from https://blog.bigevilcorporation.co.uk/2012/03/23/sega-megadrive-4-hello-world/
#XRes = 320
#YRes = 224

	; ******************************************************************
	; Sega Megadrive ROM header
	; ******************************************************************
	dc.l   $00FFFFFC      ; Initial stack pointer value 00FFE00000000200
	dc.l   EntryPoint      ; Start of program
	dc.l   Exception       ; Bus error
	dc.l   Exception       ; Address error
	dc.l   Exception       ; Illegal instruction
	dc.l   Exception       ; Division by zero
	dc.l   Exception       ; CHK exception
	dc.l   Exception       ; TRAPV exception
	dc.l   Exception       ; Privilege violation
	dc.l   Exception       ; TRACE exception
	dc.l   Exception       ; Line-A emulator
	dc.l   Exception       ; Line-F emulator
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Spurious exception
	dc.l   Exception       ; IRQ level 1
	dc.l   Exception       ; IRQ level 2
	dc.l   Exception       ; IRQ level 3
	dc.l   HBlankInterrupt ; IRQ level 4 (horizontal retrace interrupt)
	dc.l   Exception       ; IRQ level 5
	dc.l   VBlankInterrupt ; IRQ level 6 (vertical retrace interrupt)
	dc.l   Exception       ; IRQ level 7
	dc.l   Exception       ; TRAP #00 exception
	dc.l   Exception       ; TRAP #01 exception
	dc.l   Exception       ; TRAP #02 exception
	dc.l   Exception       ; TRAP #03 exception
	dc.l   Exception       ; TRAP #04 exception
	dc.l   Exception       ; TRAP #05 exception
	dc.l   Exception       ; TRAP #06 exception
	dc.l   Exception       ; TRAP #07 exception
	dc.l   Exception       ; TRAP #08 exception
	dc.l   Exception       ; TRAP #09 exception
	dc.l   Exception       ; TRAP #10 exception
	dc.l   Exception       ; TRAP #11 exception
	dc.l   Exception       ; TRAP #12 exception
	dc.l   Exception       ; TRAP #13 exception
	dc.l   Exception       ; TRAP #14 exception
	dc.l   Exception       ; TRAP #15 exception
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)
	dc.l   Exception       ; Unused (reserved)

	dc.b "SEGA GENESIS    "									; Console name
	dc.b "(C)SEGA 1992.SEP"									; Copyrght holder and release date
	dc.b "YOUR GAME HERE                                  "	; Domestic name
	dc.b "YOUR GAME HERE                                  "	; International name
	dc.b "GM XXXXXXXX-XX"									; Version number
	dc.w $0000												; Checksum
	dc.b "J               "									; I/O support
	dc.l $00000000											; Start address of ROM
	dc.l __end												; End address of ROM
	dc.l $00FF0000											; Start address of RAM
	dc.l $00FFFFFF											; End address of RAM
	dc.l $00000000											; SRAM enabled
	dc.l $00000000											; Unused
	dc.l $00000000											; Start address of SRAM
	dc.l $00000000											; End address of SRAM
	dc.l $00000000											; Unused
	dc.l $00000000											; Unused
	dc.b "                                        "			; Notes (unused)
	dc.b "JUE             "									; Country codes	

;Fake EXEC
MD_Fake_AllocMem
Dc.w $4e75;	-192
Dc.w $4e75,$4e75;	-190
Dc.w $4e75,$4e75;	-186
Dc.w $4e75,$4e75;	-182
Dc.w $4e75,$4e75;	-178
Dc.w $4e75,$4e75;	-174
Dc.w $4e75,$4e75;	-170
Dc.w $4e75,$4e75;	-166
Dc.w $4e75,$4e75;	-162
Dc.w $4e75,$4e75;	-158
Dc.w $4e75,$4e75;	-154
Dc.w $4e75,$4e75;	-150
Dc.w $4e75,$4e75;	-146
Dc.w $4e75,$4e75;	-142
Dc.w $4e75,$4e75;	-138
Dc.w $4e75,$4e75;	-134
Dc.w $4e75,$4e75;	-130
Dc.w $4e75,$4e75;	-126
Dc.w $4e75,$4e75;	-122
Dc.w $4e75,$4e75;	-118
Dc.w $4e75,$4e75;	-114
Dc.w $4e75,$4e75;	-110
Dc.w $4e75,$4e75;	-106
Dc.w $4e75,$4e75;	-102
Dc.w $4e75,$4e75;	-98
Dc.w $4e75,$4e75;	-94
Dc.w $4e75,$4e75;	-90
Dc.w $4e75,$4e75;	-86
Dc.w $4e75,$4e75;	-82
Dc.w $4e75,$4e75;	-78
Dc.w $4e75,$4e75;	-74
Dc.w $4e75,$4e75;	-70
Dc.w $4e75,$4e75;	-66
Dc.w $4e75,$4e75;	-62
Dc.w $4e75,$4e75;	-58
Dc.w $4e75,$4e75;	-54
Dc.w $4e75,$4e75;	-50
Dc.w $4e75,$4e75;	-46
Dc.w $4e75,$4e75;	-42
Dc.w $4e75,$4e75;	-38
Dc.w $4e75,$4e75;	-34
Dc.w $4e75,$4e75;	-30
Dc.w $4e75,$4e75;	-26
Dc.w $4e75,$4e75;	-22
Dc.w $4e75,$4e75;	-18
Dc.w $4e75,$4e75;	-14
Dc.w $4e75,$4e75;	-10
Dc.w $4e75,$4e75;	-6
Dc.w $4e75;	-2

EntryPoint:           ; Entry point address set in ROM header
	if MD_IsResetButtonPressed
		BRA SkipSetup
	endif
	
	MD_ClearRAM
	MD_Setup
	
	Move #$2000,SR 	;Final setup steps
	Lea $FFFFFFFC,A7 ;Reset the stack
	dc.l $424C545A,$494E4954 ;This is to be overwritten by the initial Blitz setup jump	(ASCII for BLTZINIT)
	
	.SkipSetup

	jmp __main ; Begin external main

HBlankInterrupt:
   rte   ; Return from Subroutine

Exception:
	MD_Stop
	
;At least one variable must be present, otherwise Blitz2Sega will mess up
;Use a constant like -1 rather than True - using "True" will attempt to add an Amiga library!

Pal: IncBin "palette.megadrive"
Tiles: IncBin "tiles.megadrive"
NameTable: IncBin "nametable.megadrive"

MDSSeq: IncBin "mdsseq.bin"

;NOTE - THIS SHOULD BE ALIGNED IN THE ROM AT A 32KB BOUNDARY. THIS ISN'T HANDLED BY THIS DEMO.
MDSPCM: IncBin "mdspcm.bin"

Macro Setup
	MD_LoadPatterns ?Tiles,0,256
	MD_SetPlaneSize 1,1 ;512 * 512
	MD_ModeRegister4 -1 ;320 wide
	MD_SetPlaneANameTable $C000
	MD_SetPlaneBNameTable $C000
	MD_CopyTo_VDP ?NameTable,$2000,$C000,2
End Macro

Macro WaitForVBlank
	MD_VWait
End Macro

Macro Fade_Palette
	MD_FadePalette ?Pal,0,16,`1
End Macro

Function.w ReadJoy{}
	Function Return MD_GamePad1_3Button
End Statement

Macro ScrollCamera
	MD_Scroll `1,`2,`1,`2,$FC00
End Macro

NEWTYPE .MegaDriveSprite
	Y.w
	Size.b
	NextSprite.b
	PatternId.w
	X.w
End NEWTYPE

__main:
	Dim WorkAreaArray.b(1062-1)
	Dim MDSprites.MegaDriveSprite(1)

	while MD_MDSDRV_Init(&WorkAreaArray(0),?MDSSeq,?MDSPCM)
	wend
	WorkArea.l = &WorkAreaArray(0)
	MD_MDSDRV_Request 1,3,WorkArea	

	Goto Game

VBlankInterrupt:

	;Put everything on the stack
	MOVEM.l D0-D7/A0-A6,-(A7) 

	if WorkArea
		MD_MDSDRV_Update WorkArea
	endif

	;Pop everything from the stack
	MOVEM.l (A7)+,D0-D7/A0-A6

	rte   ; Return from Subroutine

Statement RenderSprite{SpriteId,X,Y}

	Shared MDSprites.MegaDriveSprite()
	MDSprites(0)\PatternId = SpriteId * 4
	MDSprites(0)\Size = %101
	MDSprites(0)\X = 128 + X
	MDSprites(0)\Y = 128 + Y
	MD_CopyTo_VDP &MDSprites(0),SizeOf .MegaDriveSprite,$E000,2

End Statement;This is the main game file, shared between Mega Drive and Amiga
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
