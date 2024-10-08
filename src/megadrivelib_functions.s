VDP_CONTROL	equ	$00C00004
VDP_DATA	equ $00C00000
VRAM_ADDR_CMD:  equ $40000000
CRAM_ADDR_CMD:  equ $C0000000
VSRAM_ADDR_CMD: equ $40000010
VRAM_SIZE:    equ 65536
CRAM_SIZE:    equ 128
VSRAM_SIZE:   equ 80

IoCtrl1: equ $A10009   ; 1P control port
IoCtrl2: equ $A1000B   ; 2P control port
IoData1: equ $A10003   ; 1P data port
IoData2: equ $A10005   ; 2P data port

EAMULTI_1P:   equ $0C  ; Controller #1
EAMULTI_2P:   equ $1C  ; Controller #2
EAMULTI_3P:   equ $2C  ; Controller #3
EAMULTI_4P:   equ $3C  ; Controller #4
EAMULTI_ID:   equ $7C  ; Multitap ID

Z80BusReq:  equ $A11100  ; Z80 bus request line

FastPauseZ80:Macro
    move.w  #$100,Z80BusReq
	EndM

ResumeZ80:Macro
    move.w  #$000,Z80BusReq
	EndM

;Put sample table at top of RAM for now ???
_global_xgmsample_ID_table: equ $FF0000

MD_VWait
   MoveQ #1,D0
   
MD_VWait_Frames
   SubQ #1,D0
   lea VDP_CONTROL,A0

VBlank_End
   move.w (A0),d1 ; Move VDP status word to d0
   andi.w #$0008,d1     ; AND with bit 4 (vblank), result in status register
   bne    VBlank_End ; Branch if not equal (to zero)
   
VBlank_Start
   move.w (A0),d1 ; Move VDP status word to d0
   andi.w #$0008,d1     ; AND with bit 4 (vblank), result in status register
   beq    VBlank_Start   ; Branch if equal (to zero)
   DBra D0,VBlank_End
   rts

;Do the stuff here!
MD_IsResetButtonPressed
	tst.w $00A10008  ; Test mystery reset (expansion port reset?)
	BNE MD_True
	tst.w $00A1000C  ; Test reset button
	BNE MD_True	
	BRA MD_False

MD_ClearVDP
	lea VDP_DATA,A0
	lea VDP_CONTROL,A1


;https://plutiedev.com/vdp-setup wiping out ALL VDP
    move.w #$8F02,(A1)      ; Set autoincrement to 2 bytes
    moveq   #0,d0          
    
    ; Clear CRAM
    move.l  #CRAM_ADDR_CMD,(A1)
    move.w  #(CRAM_SIZE/4)-1,d1
@ClearCram:
    move.l  d0,(A0)
    dbf     d1,@ClearCram    

    ; Clear VRAM
    move.l  #VRAM_ADDR_CMD,(A1)
    move.w  #(VRAM_SIZE/4)-1,d1
		
@ClearVram:
    move.l  d0,(A0)
    dbf     d1,@ClearVram
    
    ; Clear VSRAM
    move.l  #VSRAM_ADDR_CMD,(A1)
    move.w  #(VSRAM_SIZE/4)-1,d1
@ClearVsram:
    move.l  d0,(A0)
    dbf     d1,@ClearVsram
	RTS

Is_Pico
	Cmp.l #$20504943,$104 ;" PIC"
	Seq.b D0
	rts

Pico_Setup
	Move.l #$53454741,D0
	Lea $800019,A0
	MOVEP.l D0,0(A0)
	bra PicoSkip
	
MD_Setup
	Move #$2700,SR 	;Final setup steps ;DISABLE ALL INTERRUPTS

	;Is this a pico? Do the pico TMSS instead
	Cmp.l #$20504943,$104 ;" PIC"
	BEQ Pico_Setup

	move.b $00A10001,d0      ; Move Megadrive hardware version to d0
	andi.b #$0F,d0           ; The version is stored in last four bits, so mask it with 0F
	beq Skip                  ; If version is equal to 0, skip TMSS signature
	move.l #$53454741,$00A14000 ; Move the string "SEGA" to $A14000
Skip:

	move.w #$0100,$00A11100    ; Request access to the Z80 bus, by writing $0100 into the BUSREQ port
	move.w #$0100,$00A11200    ; Hold the Z80 in a reset state, by writing $0100 into the RESET port
.WaitZ80:
	btst #$0,$00A11100      ; Test bit 0 of A11100 to see if the 68k has access to the Z80 bus yet
	bne .WaitZ80                  ; If we dont yet have control, branch back up to Wait

	lea.l $00A00000,a1     ; Copy Z80 RAM address to a1
	move.l #$1fff,d0
	moveq #0,d1

.ClearZ80:
	move.b d1,(a1)+
	dbra d0,.ClearZ80

	lea.l ZEightyData,a0        ; Load address of data into a0
	lea.l $00A00000,a1     ; Copy Z80 RAM address to a1
	move.l ZEightyData_End-ZEightyData,d0           ; 42 bytes of init data
.CopyZ80:
	move.b (a0)+,(a1)+        ; Copy data, and increment the source/dest addresses
	dbra d0,.CopyZ80

	move.w #$0000,$00A11200    ; Release reset state
	move.w #$0000,$00A11100    ; Release control of bus
	move.w #$100,$00A11200	   ; Reset the Z80 again.

	move.l #PSGData,a0        ; Load address of PSG data into a0
	move.l #$03,d0           ; 4 bytes of data
.CopyPSG:
	move.b (a0)+,$00C00011   ; Copy data to PSG RAM
	dbra d0,.CopyPSG
	
	;These should not be done on the pico
	move.b #$00,IoCtrl1  ; Controller port 1 CTRL
	move.b #$00,IoCtrl2  ; Controller port 2 CTRL
	move.b #$00,$000A1000D  ; EXP port CTRL

PicoSkip:
	move.l #VDPRegisters,a0   ; Load address of register table into a0
	move.l #$18,d0           ; 24 registers to write
	move.l #$00008000,d1     ; 'Set register 0' command (and clear the rest of d1 ready)

.CopyVDP:
	move.b (a0)+,d1           ; Move register value to lower byte of d1
	move.w d1,VDP_CONTROL      ; Write command and value to VDP control port
	add.w #$0100,d1          ; Increment register #
	dbra d0,.CopyVDP
	
ClearSetup:
	move.l (A7),D2
	move.l #$00000000,d0     ; Place a 0 into d0, ready to copy to each longword of RAM
	move.l #$00000000,a0     ; Starting from address $0, clearing backwards
	move.l #$00003FFF,d1     ; Clearing 64k's worth of longwords (minus 1, for the loop to be correct)
Clear:
	move.l d0,-(a0)           ; Decrement the address by 1 longword, before moving the zero from d0 to it
	dbra d1,Clear            ; Decrement d0, repeat until depleted
	move.l d2,(A7)

	;Wipe out everything except A7
	move.l #$00FF0000,a0     ; Move address of first byte of ram (contains zero, RAM has been cleared) to a0
	movem.l (a0),d0-d7/a1-a6  ; Multiple move zero to all registers
	move.l #$00000000,a0     ; Clear a0

	;Reset the Blitz Basic stack???
	Move.l #$FF1008,$00FF1000
	Clr.l $00FF1004
	Clr.l $00FF1008	
	Move.l #$DFF8,$00FF100C	
	RTS
	
ZEightyData:
   dc.w $af01,$d91f
   dc.w $1127,$0021
   dc.w $2600,$f977
   dc.w $edb0,$dde1
   dc.w $fde1,$ed47
   dc.w $ed4f,$d1e1
   dc.w $f108,$d9c1
   dc.w $d1e1,$f1f9
   dc.w $f3ed,$5636
   dc.w $e9e9,$8104
   dc.w $8f01
ZEightyData_End:

PSGData:
   dc.w $9fbf,$dfff
      
VDPRegisters:
	dc.b $14 ; 0: H interrupt on, palettes on
	dc.b $74 ; 1: V interrupt on, display on, DMA on, Genesis mode on
	dc.b $30 ; 2: Pattern table for Scroll Plane A at VRAM $C000 (bits 3-5 = bits 13-15)
	dc.b $00 ; 3: Pattern table for Window Plane at VRAM $0000 (disabled) (bits 1-5 = bits 11-15)
	dc.b $05 ; 4: Pattern table for Scroll Plane B at $A000 (bits 0-2)
	dc.b $70 ; 5: Sprite table at $E000 (bits 0-6)
	dc.b $00 ; 6: Unused
	dc.b $00 ; 7: Background colour – bits 0-3 = colour, bits 4-5 = palette
	dc.b $00 ; 8: Unused
	dc.b $00 ; 9: Unused
	dc.b $08 ; 10: Frequency of Horiz. interrupt in Rasters (number of lines travelled by the beam)
	dc.b $00 ; 11: External interrupts off, V scroll fullscreen, H scroll fullscreen
	dc.b $81 ; 12: Shadows and highlights off, interlace off, H40 mode (320 x 224 screen res)
	dc.b $3F ; 13: Horiz. scroll table at VRAM $FC00 (bits 0-5)
	dc.b $00 ; 14: Unused
	dc.b $02 ; 15: Autoincrement 2 bytes
	dc.b $01 ; 16: Vert. scroll 32, Horiz. scroll 64
	dc.b $00 ; 17: Window Plane X pos 0 left (pos in bits 0-4, left/right in bit 7)
	dc.b $00 ; 18: Window Plane Y pos 0 up (pos in bits 0-4, up/down in bit 7)
	dc.b $FF ; 19: DMA length lo byte
	dc.b $FF ; 20: DMA length hi byte
	dc.b $00 ; 21: DMA source address lo byte
	dc.b $00 ; 22: DMA source address mid byte
	dc.b $80 ; 23: DMA source address hi byte, memory-to-VRAM mode (bits 6-7)
   	
	
MD_Stop
	Move #$2700,SR 	;Final setup steps ;DISABLE ALL INTERRUPTS
   	stop #$2700 ; Halt CPU
   
;MD_Fake_AvailMem:
;	MOVE	#$2000,SR		;00: 46fc2000
;	MOVEA.L	#$fffffffc,A7		;04: 2e7cfffffffc
;	MOVE.L	#$00ff1008,$FF1000	;0a: 23fc00ff100800ff1000
;	CLR.L	$FF1004		;14: 42b900ff1004
;	CLR.L	$FF1008		;1a: 42b900ff1008
;	MOVE.L	#$0000dff8,$FF100C	;20: 23fc0000dff800ff100c
;	JMP	$64CFA		;2a: 4ef900064cfa NOT IMPLEMENTED?

;MD_Fake_FreeMem:
;	RTS				;80: 4e75 - Looks like this code below is all junk?
;	MOVE.L	D0,D1			;82: 2200
;	MOVE.L	A1,D0			;84: 2009
;	MOVE.L	D2,-(A7)		;86: 2f02
;	LEA	$FF1000,A0		;88: 41f900ff1000
;LAB_0005:
;	MOVE.L	(A0),D2			;8e: 2410
;	BEQ	LAB_0009		;90: 673a
;	MOVEA.L	A0,A1			;92: 2248
;	MOVEA.L	D2,A0			;94: 2042
;	ADD.L	4(A0),D2		;96: d4a80004
;	CMP.L	D0,D2			;9a: b480
;	BEQ	LAB_0007		;9c: 671a
;	BCS	LAB_0005		;9e: 65ee
;	MOVE.L	D0,(A1)			;a0: 2280
;	MOVEA.L	D0,A1			;a2: 2240
;	ADD.L	D1,D0			;a4: d081
;	CMP.L	A0,D0			;a6: b088
;	BNE	LAB_0006		;a8: 6606
;	ADD.L	4(A0),D1		;aa: d2a80004
;	MOVEA.L	(A0),A0			;ae: 2050
;LAB_0006:
;	MOVE.L	A0,(A1)			;b0: 2288
;	MOVE.L	D1,4(A1)		;b2: 23410004
;	BRA	LAB_000A		;b6: 601e
;LAB_0007:
;	MOVEA.L	(A0),A1			;b8: 2250
;	ADD.L	D1,D0			;ba: d081
;	CMP.L	A1,D0			;bc: b089
;	BNE	LAB_0008		;be: 6606
;	ADD.L	4(A1),D1		;c0: d2a90004
;	MOVE.L	(A1),(A0)		;c4: 2091
;LAB_0008:
;	ADD.L	D1,4(A0)		;c6: d3a80004
;	BRA	LAB_000A		;ca: 600a
;LAB_0009:
;	MOVEA.L	D0,A1			;cc: 2240
;	CLR.L	(A1)			;ce: 4291
;	MOVE.L	D1,4(A1)		;d0: 23410004
;	MOVE.L	A1,(A0)			;d4: 2089
;LAB_000A:
;	MOVE.L	(A7)+,D2		;d6: 241f
	
;MD_Fake_AllocAbs:			;Not implemented at all!
;	RTS				;d8: 4e75

Halter:
	Bra Halter

MD_Fake_AllocMem:
	ADDQ.L	#7,D0			;30: 5e80
	ANDI.W	#$fff8,D0		;32: 0240fff8
	LEA	$FF1000,A0		;36: 41f900ff1000
	BTST	#16,D1			;3c: 08010010
	BEQ	LAB_0002		;40: 6700001e
	BSR	LAB_0002		;44: 6100001a
	MOVE.L	D2,-(A7)		;48: 2f02
	MOVEA.L	D0,A0			;4a: 2040
	LSR.L	#2,D1			;4c: e489
	BEQ	LAB_0001		;4e: 6700000c
	SUBQ.W	#1,D1			;52: 5341
	MOVEQ	#0,D2			;54: 7400
LAB_0000:
	MOVE.L	D2,(A0)+		;56: 20c2
	DBF	D1,LAB_0000		;58: 51c9fffc
LAB_0001:
	MOVE.L	(A7)+,D2		;5c: 241f
	RTS				;5e: 4e75
LAB_0002:
	MOVE.L	(A0),D1			;60: 2210
	BEQ	LAB_0004		;62: 6718
	MOVEA.L	A0,A1			;64: 2248
	MOVEA.L	D1,A0			;66: 2041
	CMP.L	4(A0),D0		;68: b0a80004
	BHI	LAB_0002		;6c: 62f2
	MOVE.L	A0,D1			;6e: 2208
	SUB.L	D0,4(A0)		;70: 91a80004
	BNE	LAB_0003		;74: 6602
	MOVE.L	(A0),(A1)		;76: 2290
LAB_0003:
	ADD.L	4(A0),D1		;78: d2a80004
LAB_0004:
	EXG	D0,D1			;7c: c141
	RTS				;7e: 4e75
	
MD_LoadPalette:
	Lea VDP_DATA,a1
    move.w #$8F02,4(a1)      ; Set autoincrement to 2 bytes
	
	;Set up target address
	Swap.w D1
	And.l #$00FF0000,D1
	Or.l #$C0000000,D1	
    move.l D1,4(a1)
	
	move.l d0,a0                 ; Load palette address into a0	
    subq #$01,d2                ; Subtract 1 from the number of colors to transfer

PalettteTransfer:
    move.w (a0)+,(a1)    ; Move data to VDP port and increment source address
    dbra d2,PalettteTransfer      ; stop iterating if all of palette has been sent
	RTS

;D0 = Source
;D1 = First Color
;D2 = Num Of Colors
;D3 = FadeAmount ;As quick, eg the top word is the whole number and the bottom word is the fraction
MD_FadePalette:
	lea VDP_DATA,A1
    move.w #$8F02,4(A1)      ; Set autoincrement to 2 bytes
	
	LSR.l #8,D3
	
	;Set up target address
	Swap.w D1
	And.l #$00FF0000,D1
	Or.l #$C0000000,D1	
    move.l D1,4(A1)
	
	move.l d0,a0                 ; Load palette address into a0	
    subq #$01,d2                ; Subtract 1 from the number of colors to transfer

PalettteTransferFade:
	moveq #0,D4 ;Clear the red, green and blue channels
	moveq #0,D5
	moveq #0,D6
    move.w (a0)+,D6    				  ;Load the palette entry into D5

	;blue First
	move.w D6,D4
	And.w #$000F,D4 ;blue only
	LSL.w #8,D4 ;Shift left by 8 so we can multiply
	MULU D3,D4
	SWAP D4
	
	;Green second
	move.w D6,D5
	And.w #$00F0,D5 ;green only
	LSL.w #4,D5 ;Shift left by 4 so we can multiply
	MULU D3,D5
	SWAP D5
	LSL.w #4,D5 ;Move back to the original position

	;Red third
	And.w #$0F00,D6 ;green only. No need to shift
	MULU D3,D6
	SWAP D6
	LSL.w #8,D6 ;Move back to the original position

	;Combine RED, GREEN AND BLUE
	or.w D4,D6
	or.w D5,D6
	move.w D6,(a1)				  ; Load the palette into the VDP
    dbra d2,PalettteTransferFade      ; stop iterating if all of palette has been sent
	RTS
	
MD_ModeRegister2

	;Enable display
	and.w #%01000000,D0

	;240 tall (pal) vs 224 tall (ntsc)
	and.w #%00001000,D1

	or.w D1,D0
	or.w #$8134,D0 ;DMA, Mega Drive mode and vertical interrupts regardless
	move.w D0,VDP_CONTROL 
	RTS

MD_ModeRegister3
	and.w #%011,D0 ;Only the first two bits are used for the horizontal register
	and.w #%100,D1 ;Only one bit used for the vertical register
	or.w D1,D0
	or.w #$8B00,D0
	move.w D0,VDP_CONTROL 
	RTS

MD_ModeRegister4
	;Width 320 wide??
	and.w #%10000001,D0
	;Highlight shadow mode
	and.w #%00001000,D1
	or.w D1,D0
	or.w #$8C00,D0
	move.w D0,VDP_CONTROL ;256 window

	RTS
	
MD_SetPlaneSize
	lsl.w #4,D1
	or.w D1,D0
	or.w #$9000,D0
	move.w D0,VDP_CONTROL
	RTS

;Returns the value to feed into the VDP for future writing operations
MD_SetHorizontalScrollTable

	;Set the address in memory
	Move.l D0,D4
	moveq #10,d2
	lsr.w d2,D0
	or.w #$8D00,D0
	move.w D0,VDP_CONTROL

	Move.l D4,D5
	And.w #$3fff,D4
	SWAP D4	
	ROL.w #2,D5
	And.w #$3,D5
	Or.w D5,D4
	Or.l #$40000000,D4
	Move.l D4,D0
	RTS	

;move.w #$8500+($xxxx>>9),($c00004).l
MD_SetSpriteTable
	moveq #9,D1
	lsr.w D1,D0
	or.w #$8500,D0
	move.w D0,VDP_CONTROL
	RTS		

MD_SetBackgroundColor
	or.w #$8700,D0
	move.w D0,VDP_CONTROL
	RTS

;Expects colors in 0-255 range, clamps appropriately
;D0 = index
;D1 = red
;D2 = green
;D3 = blue
MD_SetColor
	Lea VDP_DATA,A1

	;Blue
	LSL.w #4,D3
	And.w #$E00,D3

	;Green
	And.w #$E0,D2

	;Red
	LSR.w #$4,D1
	And.w #$E,D1

	;Combine
	Or.w D3,D1
	Or.w D2,D1

	;Now that the color is set..
	LSL.l #1,D0 ;Convert to word length
	Swap D0
	Or.l #CRAM_ADDR_CMD,D0
	move.l D0,4(A1) ;#$C0000000+($xx<<16)
	move.w D1,(A1)
	RTS

;D0 = Data
;D1 = Destination
;126 -> 122
MD_CopyTo_VDP_W
	Lea VDP_DATA,A1
	Move.w #$8F02,4(A1) ;Set to word length
	Move.l D1,D2
	And.w #$3fff,D1
	SWAP D1
	
	ROL.w #2,D2
	And.w #3,D2
	Or.w D2,D1
	Or.l #$40000000,D1
    move.l D1,4(A1)
	Move.w D0,(A1)
	RTS

;D0 = Data
;D1 = Destination
MD_CopyTo_VDP_L
	Lea VDP_DATA,A1
	Move.w #$8F02,4(A1) ;Set to word length
	Move.l D1,D2
	And.w #$3fff,D1
	SWAP D1
	
	ROL.w #2,D2
	And.w #3,D2
	Or.w D2,D1
	Or.l #$40000000,D1
    move.l D1,4(A1)
	Move.l D0,(A1)
	RTS

;D0 = Source address
;D1 = length
;D2 = Dest Address
MD_CopyTo_VDP
	Lea VDP_DATA,A1
	Move.w #$8F02,4(A1) ;Set to word length
	Move.l D2,D3
	And.w #$3fff,D2
	SWAP D2
	
	ROL.w #2,D3
	And.w #$3,D3
	Or.w D3,D2
	Or.l #$40000000,D2
    move.l D2,4(A1)

VDP_COPY_L_START
	Move.l D1,D3
	Move.l D0,A0	
	LSR.l #5,D1 ;Divide by 32, since we copy 8x long words at a time (the size of 1x pattern)
	SubQ #1,D1
	BLT VDP_Copy_L4

VDP_COPY_L8
	Move.l (A0)+,(A1)
	Move.l (A0)+,(A1)
	Move.l (A0)+,(A1)
	Move.l (A0)+,(A1)
	Move.l (A0)+,(A1)
	Move.l (A0)+,(A1)
	Move.l (A0)+,(A1)
	Move.l (A0)+,(A1)	
	DBra D1,VDP_COPY_L8

VDP_Copy_L4
	BTST #4,D3 ;Do we need to copy four long words
	BEQ VDP_Copy_L2
	Move.l (A0)+,(A1)
	Move.l (A0)+,(A1)
	Move.l (A0)+,(A1)
	Move.l (A0)+,(A1)	

VDP_Copy_L2
	BTST #3,D3 ;Do we need to copy two long words
	BEQ VDP_Copy_L
	Move.l (A0)+,(A1)
	Move.l (A0)+,(A1)

VDP_Copy_L 
	BTST #2,D3 ;Do we need to copy a single long word
	BEQ VDP_Copy_W
	Move.l (A0)+,(A1)

VDP_Copy_W
	BTST #1,D3 ;Do we need to copy a word
	BEQ VDP_COPY_DONE
	Move.w (A0)+,(A1)

VDP_COPY_DONE
	RTS
	
;D0 = The source address
;D1 = The destination address
;D2 = X Tiles
;D3 = Y Tiles
;D4 = Source modulo
;D5 = Destination modulo
MD_CopyTo_NameTable
	Lea VDP_DATA,A1

	;Set the auto increment to 2
	Move.w #$8F02,4(A1)
	
	;Convert the modulos to word length
	Add.w D4,D4
	Add.w D5,D5
	
	SubQ #1,D2; Subtract one from the loop sizes
	SubQ #1,D3; 
	
	;Store the original destination in A1
	Move.l D1,A1

MD_CopyTo_NameTable_LoopY

	;Could be improved - calculate the destination address?
	Move.l A1,D1
	Move.l D1,D6
	And.w #$3fff,D1
	SWAP D1
	
	ROL.w #2,D6
	And.w #$3,D6
	Or.w D6,D1
	Or.l #$40000000,D1
    move.l D1,4(A1)
	
	;The actual copy
	Move.l D0,A0
	Move.w D2,D7
MD_CopyTo_NameTable_LoopX ;Todo - unroll for performance reasons? Also offer a long-length solution?
	Move.w (A0)+,(A1)
	dbra D7,MD_CopyTo_NameTable_LoopX

	Add.l D4,D0 ;Update the source address
	Add.l D5,A1 ;Update the destination address
	dbra D3,MD_CopyTo_NameTable_LoopY
	RTS

;Test if a Sega Multitap is in player 1 port, and configure appropriately
MD_Plutie_IsSegaMultitap
	lea IoData1,A0
	bsr MD_Plutie_GetPeripheralId	
	cmp.w #%0111,D0 ;Is this a multi tap
	bne NotSega

	;This is a multitap, so configure appropriately
    move.b  #$60,IoCtrl1
    move.b  #$60,IoData1
	MoveQ #-1,D0
	RTS

NotSega
	MoveQ #0,D0
	RTS

;Detect if there's an EA multitap
MD_Plutie_IsEAMultitap
    FastPauseZ80
    
    ; Set up ports to check for
    ; EA multitap
    move.b  #$40,IoCtrl1
    move.b  #$7F,IoCtrl2
    move.b  #$40,IoData1
    
    ; Read from controller #1
    move.b  #EAMULTI_1P,IoData2
    nop
    nop
    moveq   #%0000011,d0
    and.b   IoData1,d0
    
    ; Read from multitap ID
    move.b  #EAMULTI_ID,IoData2
    nop
    nop
    moveq   #%0000011,d1
    and.b   IoData1,d1
    
    ; We can let the Z80 run now
    ResumeZ80
    
    ; Check if both are valid
    tst.b   d0
    beq     @NotEA
    tst.b   d1
    bne     @NotEA
	MoveQ #-1,D0
	RTS

@NotEA
	MoveQ #0,D0
	RTS

;D0 is the place where we save the results
;D1 is the number of loops (being 7 for six button or 2 for two button)
MD_Plutie_ReadEAMultitap
    lea     IoData1,a0
    lea     IoData2,a1
    move.l D0,a2 ;Buffer goes into D0
    
    ; Keep the Z80 out of the way
    ; while we touch the I/O ports
    FastPauseZ80
    
    ; Read all the controller values
    ; (see below for how many times)
	subq.w   #1,d1 ;Loops are in D1
    moveq   #$40,d0
@Loop:
    ; Toggle select line
    move.b  d0,(a0)
    
    ; Read controller #1
    move.b  #EAMULTI_1P,(a1)
    nop
    nop
    nop
    move.b  (a0),(a2)+
    
    ; Read controller #2
    move.b  #EAMULTI_2P,(a1)
    nop
    nop
    nop
    move.b  (a0),(a2)+
    
    ; Read controller #3
    move.b  #EAMULTI_3P,(a1)
    nop
    nop
    nop
    move.b  (a0),(a2)+
    
    ; Read controller #4
    move.b  #EAMULTI_4P,(a1)
    nop
    nop
    nop
    move.b  (a0),(a2)+
    
    ; Onto next value
    ; Clever trick here: d1 will swap
    ; between $40 and $00 (remember
    ; we used moveq earlier!)
    swap    d0
    dbf     d1,@Loop
    
    ; Z80 can run again now
    ResumeZ80
    
    ; We're done
    rts

MD_Plutie_ReadSegaMultitap
    lea    IoData1,a0
	move.l D0,A1 ;Address to results buffer in D0

    ; 1st multitap check
    move.b  #$60,(A0)
    nop
    nop
    nop
    moveq   #$0F,d0
    and.b   (a0),d0
    cmp.b   #$03,d0
    bne     @Error
    
    ; 2nd multitap check
    move.b  #$20,(a0)
    nop
    nop
    nop
    moveq   #$0F,d0
    and.b   (a0),d0
    cmp.b   #$0F,d0
    bne     @Error

	;Time to read the nibbles
	bsr ReadSegaNibble 
	tst.b D0 
	bne @Error ;First two nibbles must be zero

	bsr ReadSegaNibble 
	tst.b D0 
	bne @Error ;First two nibbles must be zero

	bsr ReadSegaNibble 
	move.b D0,D2 ;First controller type
	bsr ReadSegaNibble 
	move.b D0,D3 ;Second controller type
	bsr ReadSegaNibble 
	move.b D0,D4 ;Third controller type
	bsr ReadSegaNibble 
	move.b D0,D5 ;Fourth controller type

	move.b D2,D0 
	bsr ReadSegaMultitapDevice ;First controller nibbles
	move.b D3,D0 
	bsr ReadSegaMultitapDevice ;Second controller nibbles
	move.b D4,D0 
	bsr ReadSegaMultitapDevice ;Third controller nibbles
	move.b D5,D0 
	bsr ReadSegaMultitapDevice ;Fourth controller nibbles

	;We're done! Put the data port back to 60
    move.b  #$60,(A0)
	rts

ReadSegaMultitapDevice
	Cmp.b #%0000,D0
	BNE Not3Button
	;This is a 3 button controller, just read two nibbles
	BSR ReadSegaNibble 
	move.b D0,(A1)+
	BSR ReadSegaNibble
	move.b D0,(A1)+
	AddQ.l #4,A1
	RTS

Not3Button
	;Maybe this is a six button?
	Cmp.b #%0001,D0
	BNE Not6Button
	BSR ReadSegaNibble 
	move.b D0,(A1)+
	BSR ReadSegaNibble 
	move.b D0,(A1)+
	BSR ReadSegaNibble 
	move.b D0,(A1)+
	AddQ.l #3,A1
	RTS

Not6Button
	;Maybe this is a mouse?
	Cmp.b #%0010,D0
	BNE Nothing
	BSR ReadSegaNibble 
	move.b D0,(A1)+
	BSR ReadSegaNibble 
	move.b D0,(A1)+
	BSR ReadSegaNibble 
	move.b D0,(A1)+
	BSR ReadSegaNibble 
	move.b D0,(A1)+
	BSR ReadSegaNibble 
	move.b D0,(A1)+
	BSR ReadSegaNibble 
	move.b D0,(A1)+
	RTS

Nothing
	Cmp.b #%1111,D0
	BNE DeviceError
	;This isn't anything	
	Addq.l #6,A1 ;Move ahead six bytes
	RTS

DeviceError
	ILLEGAL
	RTS


; Read a nibble from the Sega multitap
; in a0.l = pointer to IoData1/2
; in d0.b = nibble (-1 on error)

ReadSegaNibble:
    ; Flip bit 5
    bchg    #5,(a0)
    
    ; 68000 trick: BCHG will set the
    ; zero flag to the new value of
    ; the bit (0 if clear, 1 if set)
    ; so we use SEQ which sets d0 to
    ; either 0 (if Z=0) or $FF (if Z=1)
    ; then AND to leave only bit 4
    seq.b   d0
    and.b   #1<<4,d0
    
    ; Now wait until bit 4 gets set
    ; to the same value we want
    ; If it takes too long we return
    ; an error (unplugged?)
    moveq   #$7F,d7
@Wait:
    moveq   #1<<4,d1
    and.b   (a0),d1
    cmp.b   d0,d1
    beq.s   @GotNibble
    dbf     d7,@Wait
    bra     @Error
    
@GotNibble:
    ; Get the nibble in d0
    moveq   #$0F,d0
    and.b   (a0),d0
    rts
    
@Error:
    ; Whoops
    moveq   #-1,d0
    rts	

;D0 = Foreground scroll X
;D1 = Foreground scroll y
;D2 = Background scroll x
;D3 = Background scroll y
;D4 = HScroll (value to feed to VDP_Control)
MD_Scroll:
	Lea VDP_DATA,A1

	;X Scroll is negative
	NEG.w D0
	NEG.w D2

	;Combine the words for scrolling
	SWAP D0
	Move.w D2,D0
	SWAP D1
	Move.w D3,D1

    move.l D4,4(A1) ;Set the address of the H Scroll memory
	move.l D0,(A1) ;Load the X position

	;Write to the first two words of VSRAM
	move.l #$40000010,4(A1)
	move.l D1,(A1) ;Load the Y position
	RTS

MD_GamePad1_3Button
	moveq	#$40,d0
	move.b	d0,IoCtrl1	; TH pin to write, others to read
	move.b	d0,IoData1	; TH to 1
	nop
	nop
	move.b	IoData1,d0
	andi.b	#$3F,d0		; d0 = 00CBRLDU
	moveq	#0,d1
	move.b	#0,IoData1	; TH to 0
	nop
	nop
	move.b	IoData1,d1
	andi.b	#$30,d1		; d1 = 00SA0000
	lsl.b	#2,d1		; d1 = SA000000
	or.b	d1,d0		; d0 = SACBRLDU
	not.b	d0
	RTS

MD_GamePad2_3Button
	moveq	#$40,d0
	move.b	d0,IoCtrl2	; TH pin to write, others to read
	move.b	d0,IoData2	; TH to 1
	nop
	nop
	move.b	IoData2,d0
	andi.b	#$3F,d0		; d0 = 00CBRLDU
	moveq	#0,d1
	move.b	#0,IoData2	; TH to 0
	nop
	nop
	move.b	IoData2,d1
	andi.b	#$30,d1		; d1 = 00SA0000
	lsl.b	#2,d1		; d1 = SA000000
	or.b	d1,d0		; d0 = SACBRLDU
	not.b	d0
	RTS
	
MD_GamePad1_6Button
	moveq	#$40,d0
	move.b	d0,IoCtrl1	; TH pin to write, others to read
	move.b	d0,IoData1	; TH to 1
	nop
	nop
	move.b	IoData1,d0
	andi.b	#$3F,d0		; d0 = 00CBRLDU
	moveq	#0,d1
	move.b	#0,IoData1	; TH to 0
	nop
	nop
	move.b	IoData1,d1
	andi.b	#$30,d1		; d1 = 00SA0000
	lsl.b	#2,d1		; d1 = SA000000
	or.b	d1,d0		; d0 = SACBRLDU
	moveq	#0,d1
	move.b	#$40,IoData1 ; TH to 1
	nop
	nop
	move.b	#0,IoData1	; TH to 0
	nop
	nop

	;Check if we ACTUALLY have a six button 
	move.b IoData1,d1
	and.b #$f,d1
	bne NOT_MD_GamePad_6Button

	move.b	#$40,IoData1 ; TH to 1
	nop
	nop
	move.b	IoData1,d1
	move.b	#0,IoData1	; TH to 0
	andi.w	#$F,d1		; d1 = 0000MXYZ
	lsl.w	#8,d1		; d1 = 0000MXYZ00000000
	or.w	d1,d0		; d0 = 0000MXYZSACBRLDU
	not.w	d0 ;Reverse the state
	and.w   #$fff,d0 ;Clear the top bits
	RTS

NOT_MD_GamePad_6Button
	not.w	d0 ;Reverse the state
	and.w   #$ff,d0 ;Clear the top bits
	RTS

MD_GamePad2_6Button
	moveq	#$40,d0
	move.b	d0,IoCtrl2	; TH pin to write, others to read
	move.b	d0,IoData2	; TH to 1
	nop
	nop
	move.b	IoData2,d0
	andi.b	#$3F,d0		; d0 = 00CBRLDU
	moveq	#0,d1
	move.b	#0,IoData2	; TH to 0
	nop
	nop
	move.b	IoData2,d1
	andi.b	#$30,d1		; d1 = 00SA0000
	lsl.b	#2,d1		; d1 = SA000000
	or.b	d1,d0		; d0 = SACBRLDU
	moveq	#0,d1
	move.b	#$40,IoData2 ; TH to 1
	nop
	nop
	move.b	#0,IoData2	; TH to 0
	nop
	nop

	;Check if we ACTUALLY have a six button 
	move.b IoData2,d1
	and.b #$f,d1
	bne NOT_MD_GamePad_6Button

	move.b	#$40,IoData2 ; TH to 1
	nop
	nop
	move.b	IoData2,d1
	move.b	#0,IoData2	; TH to 0
	andi.w	#$F,d1		; d1 = 0000MXYZ
	lsl.w	#8,d1		; d1 = 0000MXYZ00000000
	or.w	d1,d0		; d0 = 0000MXYZSACBRLDU
	not.w	d0 ;Reverse the state
	and.w   #$fff,d0 ;Clear the top bits
	RTS

;D0 = The source address
;D1 = The pattern index
;D2 = The number of patterns
MD_LoadPatterns:
	TST.w D2 ;If we have no patterns, do nothing
	BEQ JustReturn

	;Leave source address as D0
	LSL.l #5,D1 ;Pattern index needs to be multiplied by 32
	LSL.l #5,D2 ;Number of patterns needs to be multiplied by 32
	EXG D2,D1
	BRA MD_CopyTo_VDP

;D0 = The source address
;D1 = The pattern index
;D2 = The number of patterns
MD_LoadPatterns_DMA:
	;Leave source address as D0
	LSL.l #5,D1 ;Pattern index needs to be multiplied by 32
	LSL.l #4,D2 ;Number of patterns needs to be multiplied by 16
	EXG D2,D1
	Bra MD_DMA_Transfer_SkipSize

;D0 - Source address in 68K memory
;D1 - Length
;D2 - Destination address in VDP memory
MD_DMA_Transfer

	;Divide the size by half
	lsr.l #1,D1

MD_DMA_Transfer_SkipSize	
	Lea VDP_CONTROL,A3

	;Divide the source by half
	lsr.l #1,D0	

	;Check if crosses 128 boundary
	Move.w D0,D7
	Add.w D1,D7
	BCC MD_DMA_Transfer_Ready

	;Here is where we want to handle the 128 boundary
	;How many words from start to boundary?
	MoveQ #0,D6
	Sub.w D0,D6  ;D6 now contains how many words we need to copy in our first run

	MoveM.l D0-D3,-(sp) ;Backup our source variables
	Move.w D6,D1 ;We want to copy the first set of words
	BSR MD_DMA_Transfer_Ready	
	MoveM.l (sp)+,D0-D3 ;Restore our original variables
	Sub.l D6,D1 ;Subtract the length of words we've already copied from our length
	BEQ MD_DMA_Transfer_Done ;=== FIX FOR BUG ===

	Add.l D6,D0 ;Add the length of words we've already copied to our source

	Add.l D6,D2 ;Add to our destination address twice
	Add.l D6,D2

MD_DMA_Transfer_Ready
	;DMA Length lower byte
	move.w #$9300,D3
	move.b D1,D3
	move.w D3,(A3)

	;DMA length upper byte
	move.w #$9400,D3
	lsr.w #8,D1
	move.b D1,D3
	move.w D3,(A3)

	;DMA source low byte
	move.w #$9500,D3
	move.b D0,D3
	move.w D3,(A3)

	;DMA source middle byte
	move.w #$9600,D3
	lsr.l #8,D0
	move.b D0,D3
	move.w D3,(A3)

	;DMA source top byte
	move.w #$9700,D3
	lsr.l #8,D0
	move.b D0,D3
	move.w D3,(A3)

	;Finally, copy to destination
	move.l #$40000080,D3
	MoveQ #0,D4
	
	move.w D2,D4
	and.w #$3FFF,D4
	swap.w D4
	or.l D4,D3

	move.w D2,D4
	and.w #$C000,D4
	rol.w #2,D4
	or.w D4,D3

	move.l D3,(A3)

MD_DMA_Transfer_Done
	RTS

;D0 = source
MD_DMA_CRAM
	Lea VDP_CONTROL,A3

	;Divide the source by half
	lsr.l #1,D0	

	MoveQ #64,D1 ;Always 128 bytes / 64 words of CRAM

	;DMA Length lower byte
	move.w #$9300,D3
	move.b D1,D3
	move.w D3,(A3)

	;DMA length upper byte
	move.w #$9400,D3
	lsr.w #8,D1
	move.b D1,D3
	move.w D3,(A3)

	;DMA source low byte
	move.w #$9500,D3
	move.b D0,D3
	move.w D3,(A3)

	;DMA source middle byte
	move.w #$9600,D3
	lsr.l #8,D0
	move.b D0,D3
	move.w D3,(A3)

	;DMA source top byte
	move.w #$9700,D3
	lsr.l #8,D0
	move.b D0,D3
	move.w D3,(A3)

	;Finally, copy to destination
	move.l #$C0000080,(A3)
	RTS

;D0 = source
MD_DMA_VSRAM
	Lea VDP_CONTROL,A3

	;Divide the source by half
	lsr.l #1,D0	

	MoveQ #40,D1 ;Always 80 bytes / 40 words of VSRAM

	;DMA Length lower byte
	move.w #$9300,D3
	move.b D1,D3
	move.w D3,(A3)

	;DMA length upper byte
	move.w #$9400,D3
	lsr.w #8,D1
	move.b D1,D3
	move.w D3,(A3)

	;DMA source low byte
	move.w #$9500,D3
	move.b D0,D3
	move.w D3,(A3)

	;DMA source middle byte
	move.w #$9600,D3
	lsr.l #8,D0
	move.b D0,D3
	move.w D3,(A3)

	;DMA source top byte
	move.w #$9700,D3
	lsr.l #8,D0
	move.b D0,D3
	move.w D3,(A3)

	;Finally, copy to destination
	move.l #$40000090,(A3)
	RTS

;D0 = The name table address	
MD_SetPlaneANameTable
	;Move right 10
	LSR #8,D0
	LSR #2,D0
	Add.w #$8200,D0
	move.w D0,VDP_CONTROL
	RTS

;D0 = The name table address	
MD_SetPlaneBNameTable
	;Move right 13
	LSR #8,D0
	LSR #5,D0
	Add.w #$8400,D0
	move.w D0,VDP_CONTROL
	RTS

;D0 = The name table address	
MD_SetWindowNameTable
	;Move right 10
	LSR #8,D0
	LSR #2,D0
	Add.w #$8300,D0
	move.w D0,VDP_CONTROL
	RTS
	
MD_SetWindowPosition
	;X Position
	and.w #$80,D2
	or.w D2,D0
	and.w #$9F,D0
	or.w #$9100,D0 
	move.w D0,VDP_CONTROL

	;Y Position
	and.w #$80,D3
	or.w D3,D1
	and.w #$9F,D1
	or.w #$9200,D1 
	move.w D1,VDP_CONTROL	
	RTS

MD_True:
	MoveQ #-1,D0
	RTS
	
MD_False:
	MoveQ #0,D0
	RTS
	
;D0 = Work area of at least 1062 bytes
;D1 = Sequence Data
;D2 = PCM data
;D3 = DMA protection size in bytes (0 if none, else 40-220 with 100 recommended)
;D4 = MDSDRV blob
MD_MDSDRV_Init:

	Move.l D0,A0
	Move.l D1,A1
	Move.l D2,A2

	Move.l D4,A3

	Move.w D3,-(SP) ;Store DMA protection amount
    movem.l a0-a6,-(SP) ;Store address registers
	JSR (A3) ;MDSDRV
    movem.l (SP)+,a0-a6	;Restore address registers
	Move.w (SP)+,D3 ;Restore DMA protection amount

	;Wait until the Z80 is ready
MD_MDSDRV_WaitForZ80
	moveq	#$12,d0				; get Z80 pcm mode
	Move.w D3,-(SP) ;Store DMA protection amount
    movem.l a0-a6,-(SP) ;Store address registers	
	jsr $0c(A3) ;bsr.w	MDSDRV+$0c
    movem.l (SP)+,a0-a6	;Restore address registers
	Move.w (SP)+,D3 ;Restore DMA protection amount	
	tst.b	d0
	beq.s	MD_MDSDRV_WaitForZ80	
	
	moveq	#$11,d0			; set_pcmmode
	moveq	#$3,d1			; mixing = 3 channel
	moveq   #0,D2			; Clear the whole longword
	move.w	D3,D2			; DMA protection on

    movem.l a0-a6,-(SP) ;Store address registers

	jsr $0c(A3) ;bsr.w	MDSDRV+$0c
    movem.l (SP)+,a0-a6	;Restore address registers

MD_MDSDRV_Init_Finished
	RTS
	
;D0 = Work area of at least 1062 bytes
;D1 = MDSDRV blob
MD_MDSDRV_Update:
	Move.l D1,A3

    movem.l a0-a6,-(SP)	
	Move.l D0,A0
	JSR 4(A3) ;MDSDRV+4
    movem.l (SP)+,a0-a6		
	RTS

;Clamps D7 to range where 127 is minimum, 0 is maximum. Trashes D6-D7. D6 is in, D7 is out
ClampSound

	;The new volume level goes into D2
	;Clamp to 255
	CMP.w #255,D6
	BLT NoClamp
	Move.w #255,D6
NoClamp
	LSR.w #1,D6 ;Divide by 2. 255 -> 127
	MoveQ #127,D7
	Sub.w D6,D7 ;Reverse the volume level	
	RTS


;D0 = Volume
;D1 = Priority level
;D2 = Work area of at least 1062 bytes
;D3 = MDSDRV mapper
MD_MDSDRV_Volume:
   	Move.l D3,A3

	movem.l a0-a6,-(SP)	
	Move.l D2,A0

	Exg D0,D6
	BSR ClampSound
	Exg D7,D2

	MoveQ #$D,D0

	JSR 12(A3) ;MDSDRV+12

    movem.l (SP)+,a0-a6	
	RTS
	

;D0 = Volume for Music
;D1 = Volume for SFX
;D2 = Work area of at least 1062 bytes
;D3 = MDSDRV mapper
MD_MDSDRV_GVolume:
    Move.l D3,A3

	movem.l a0-a6,-(SP)	
	Move.l D2,A0

	;Upper eight bits is music
	Move.w D0,D6
	BSR ClampSound
	LSL.w #8,D7
	Move.w D7,D0

	;Lower eight bits is SFX
	Move.w D1,D6
	BSR ClampSound
	Move.b D7,D0

	Move.w D0,D1
	MoveQ #$7,D0

	JSR 12(A3);MDSDRV+12

    movem.l (SP)+,a0-a6	
	RTS


;D0 = Sound number
;D1 = Priority level
;D2 = Work area of at least 1062 bytes
;D3 = MDSDRV blob
MD_MDSDRV_Request:
    Move.l D3,A3
    movem.l a0-a6,-(SP)	
	Move.l D2,A0
	JSR 8(A3) ; MDSDRV+8
    movem.l (SP)+,a0-a6	
	RTS
	
JustReturn
	RTS




MD_Plutie_GetPeripheralId:
    ; Make sure pin direction is
    ; set correctly for this
    FastPauseZ80
    move.b  #$40,6(a0)
    
    ; Get bits 3-2 of peripheral ID
    move.b  #$40,(a0)
    nop
    nop
    lea     @Table1(pc),a1
    moveq   #$0F,d1
    and.b   (a0),d1
    move.b  (a1,d1.w),d1
    
    ; Get bits 1-0 of peripheral ID
    move.b  #$00,(a0)
    nop
    nop
    lea     @Table2(pc),a1
    moveq   #$0F,d0
    and.b   (a0),d0
    move.b  (a1,d0.w),d0
    
    ; Leave peripheral alone
    move.b  #$40,(a0)
    ResumeZ80
    
    ; Put bits together
    or.b    d1,d0
    
    ; Result is in d0
    rts
    
    ; Look-up table to extract ID
    ; bits from the first read
@Table1:
    dc.b  %0000,%0100,%0100,%0100
    dc.b  %1000,%1100,%1100,%1100
    dc.b  %1000,%1100,%1100,%1100
    dc.b  %1000,%1100,%1100,%1100
    
    ; Look-up table to extract ID
    ; bits from the second read
@Table2:
    dc.b  %0000,%0001,%0001,%0001
    dc.b  %0010,%0011,%0011,%0011
    dc.b  %0010,%0011,%0011,%0011
    dc.b  %0010,%0011,%0011,%0011

	;34 Cycles / 12 bytes
;	Lea 8(PC),A0
;	JMP 4(A0)
;	Move.l A0,32(A1)

	;42 Cycles / 8 bytes
;	JSR 4(A0)
;	Move.l (A7)+,32(A1)
