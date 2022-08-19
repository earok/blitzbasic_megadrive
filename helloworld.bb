;adapted from https://blog.bigevilcorporation.co.uk/2012/03/23/sega-megadrive-4-hello-world/
DefType .w

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

VBlankInterrupt:
   rte   ; Return from Subroutine

Exception:
	MD_Stop
	
#Space = 0
#H = 1
#E = 2
#L = 3
#O = 4
#W = 5
#R = 6
#D = 7

;At least one variable must be present, otherwise Blitz2Sega will mess up
;Use MD_True or a constant like -1 rather than True - using "True" will attempt to add an Amiga library!
MyVar.l = MD_True

__main:
	MD_LoadPalette ?Pal,0,16 ;Load the palette below
	MD_LoadPatterns ?Characters,1,7 ;Load the characters below
	MD_VDP_Write $C000,2 ;Set the VDP to write to $C000 (plane A address) in video memory. Two bytes per MoveW
	MD_VDP_MoveW #H
	MD_VDP_MoveW #E
	MD_VDP_MoveW #L
	MD_VDP_MoveW #L
	MD_VDP_MoveW #O
	MD_VDP_MoveW #Space
	MD_VDP_MoveW #W
	MD_VDP_MoveW #O
	MD_VDP_MoveW #R
	MD_VDP_MoveW #L
	MD_VDP_MoveW #D
	
.EndLoop
	Goto EndLoop
	
Pal:
   dc.w $0000 ; Colour 0 - Transparent
   dc.w $000E ; Colour 1 - Red
   dc.w $00E0 ; Colour 2 - Green
   dc.w $0E00 ; Colour 3 - Blue
   dc.w $0000 ; Colour 4 - Black
   dc.w $0EEE ; Colour 5 - White
   dc.w $00EE ; Colour 6 - Yellow
   dc.w $008E ; Colour 7 - Orange
   dc.w $0E0E ; Colour 8 - Pink
   dc.w $0808 ; Colour 9 - Purple
   dc.w $0444 ; Colour A - Dark grey
   dc.w $0888 ; Colour B - Light grey
   dc.w $0EE0 ; Colour C - Turquoise
   dc.w $000A ; Colour D - Maroon
   dc.w $0600 ; Colour E - Navy blue
   dc.w $0060 ; Colour F - Dark green
	
Characters:
   dc.l $11000110 ; Character 0 - H
   dc.l $11000110
   dc.l $11000110
   dc.l $11111110
   dc.l $11000110
   dc.l $11000110
   dc.l $11000110
   dc.l $00000000
 
   dc.l $11111110 ; Character 1 - E
   dc.l $11000000
   dc.l $11000000
   dc.l $11111110
   dc.l $11000000
   dc.l $11000000
   dc.l $11111110
   dc.l $00000000
 
   dc.l $11000000 ; Character 2 - L
   dc.l $11000000
   dc.l $11000000
   dc.l $11000000
   dc.l $11000000
   dc.l $11111110
   dc.l $11111110
   dc.l $00000000
 
   dc.l $01111100 ; Character 3 - O
   dc.l $11101110
   dc.l $11000110
   dc.l $11000110
   dc.l $11000110
   dc.l $11101110
   dc.l $01111100
   dc.l $00000000
 
   dc.l $11000110 ; Character 4 - W
   dc.l $11000110
   dc.l $11000110
   dc.l $11000110
   dc.l $11010110
   dc.l $11101110
   dc.l $11000110
   dc.l $00000000
 
   dc.l $11111100 ; Character 5 - R
   dc.l $11000110
   dc.l $11001100
   dc.l $11111100
   dc.l $11001110
   dc.l $11000110
   dc.l $11000110
   dc.l $00000000
 
   dc.l $11111000 ; Character 6 - D
   dc.l $11001110
   dc.l $11000110
   dc.l $11000110
   dc.l $11000110
   dc.l $11001110
   dc.l $11111000
   dc.l $00000000

	 
__end

