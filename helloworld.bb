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
	
;At least one variable must be present, otherwise Blitz2Sega will mess up
;Use MD_True or a constant like -1 rather than True - using "True" will attempt to add an Amiga library!

__main:
	MD_FadePalette ?Pal,0,64,0 ;Fade the palette to nothing

	MD_SetPlaneSize 1,0 ;512 * 256
	MD_ModeRegister4 MD_True ;320 wide
	MD_LoadPatterns ?Patterns,0,(?NameTable - ?Patterns) / 32
	MD_CopyTo_NameTable ?NameTable,$c000,40,32,40,64
	
	
	;Fade in
	for i = 0 to 100
		MD_FadePalette ?Pal,0,64,i / 100
		MD_VWait 1
	next	

.GameLoop
	MD_VWait
	Goto GameLoop
	
Pal: IncBin out.pal
Patterns: IncBin out.pat
NameTable: IncBin out.nt

	 
__end

