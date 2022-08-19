VDP_CONTROL	equ	$00C00004
VDP_DATA	equ $00C00000

MD_VWait
   MoveQ #1,D0
   
MD_VWait_Frames
   SubQ #1,D0
   
VBlank_End
   move.w VDP_CONTROL,d1 ; Move VDP status word to d0
   andi.w #$0008,d1     ; AND with bit 4 (vblank), result in status register
   beq    VBlank_End   ; Branch if equal (to zero)
   
VBlank_Start
   move.w VDP_CONTROL,d1 ; Move VDP status word to d0
   andi.w #$0008,d1     ; AND with bit 4 (vblank), result in status register
   bne    VBlank_Start ; Branch if not equal (to zero)
   DBra D0,VBlank_End
   rts

;Do the stuff here!
MD_IsResetButtonPressed
	tst.w $00A10008  ; Test mystery reset (expansion port reset?)
	BNE MD_True
	tst.w $00A1000C  ; Test reset button
	BNE MD_True	
	BRA MD_False

MD_ClearRAM
	move.l (A7),D2
	move.l #$00000000,d0     ; Place a 0 into d0, ready to copy to each longword of RAM
	move.l #$00000000,a0     ; Starting from address $0, clearing backwards
	move.l #$00003FFF,d1     ; Clearing 64k's worth of longwords (minus 1, for the loop to be correct)
Clear:
	move.l d0,-(a0)           ; Decrement the address by 1 longword, before moving the zero from d0 to it
	dbra d1,Clear            ; Decrement d0, repeat until depleted
	move.l d2,(A7)
	moveq #0,d2
	RTS
	
MD_Setup
	move.b $00A10001,d0      ; Move Megadrive hardware version to d0
	andi.b #$0F,d0           ; The version is stored in last four bits, so mask it with 0F
	beq .Skip                  ; If version is equal to 0, skip TMSS signature
	move.l #$53454741,$00A14000 ; Move the string "SEGA" to $A14000
.Skip:


	move.w #$0100,$00A11100    ; Request access to the Z80 bus, by writing $0100 into the BUSREQ port
	move.w #$0100,$00A11200    ; Hold the Z80 in a reset state, by writing $0100 into the RESET port
.WaitZ80:
	btst #$0,$00A11100      ; Test bit 0 of A11100 to see if the 68k has access to the Z80 bus yet
	bne .WaitZ80                  ; If we dont yet have control, branch back up to Wait
	move.l #ZEightyData,a0        ; Load address of data into a0
	move.l #$00A00000,a1     ; Copy Z80 RAM address to a1
	move.l #$29,d0           ; 42 bytes of init data
.CopyZ80:
	move.b (a0)+,(a1)+        ; Copy data, and increment the source/dest addresses
	dbra d0,.CopyZ80

	move.w #$0000,$00A11200    ; Release reset state
	move.w #$0000,$00A11100    ; Release control of bus


	move.l #PSGData,a0        ; Load address of PSG data into a0
	move.l #$03,d0           ; 4 bytes of data
.CopyPSG:
	move.b (a0)+,$00C00011   ; Copy data to PSG RAM
	dbra d0,.CopyPSG
	

	move.l #VDPRegisters,a0   ; Load address of register table into a0
	move.l #$18,d0           ; 24 registers to write
	move.l #$00008000,d1     ; 'Set register 0' command (and clear the rest of d1 ready)

.CopyVDP:
	move.b (a0)+,d1           ; Move register value to lower byte of d1
	move.w d1,VDP_CONTROL      ; Write command and value to VDP control port
	add.w #$0100,d1          ; Increment register #
	dbra d0,.CopyVDP

	move.b #$00,$000A10009  ; Controller port 1 CTRL
	move.b #$00,$000A1000B  ; Controller port 2 CTRL
	move.b #$00,$000A1000D  ; EXP port CTRL
	
	;Wipe out everything except A7
	move.l #$00FF0000,a0     ; Move address of first byte of ram (contains zero, RAM has been cleared) to a0
	movem.l (a0),d0-d7/a1-a6  ; Multiple move zero to all registers
	move.l #$00000000,a0     ; Clear a0
	; Init status register (no trace, A7 is Interrupt Stack Pointer, no interrupts, clear condition code bits)
	move #$2700,sr

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

    move.w #$8F02,VDP_CONTROL      ; Set autoincrement to 2 bytes
	
	;Set up target address
	Swap.w D1
	And.l #$00FF0000,D1
	Or.l #$C0000000,D1	
    move.l D1,VDP_CONTROL
	
	move.l d0,a0                 ; Load palette address into a0	
    subq #$01,d2                ; Subtract 1 from the number of colors to transfer

PalettteTransfer:
    move.l (a0)+,VDP_DATA    ; Move data to VDP port and increment source address
    dbra d2,PalettteTransfer      ; stop iterating if all of palette has been sent
	RTS
	
MD_ModeRegister4
	;Width 320 wide??
	and.w #%10000001,D0
	or.w #$8C00,D0
	move.w D0,$c00004 ;256 window
	RTS
	
MD_SetPlaneSize
	lsl.w #4,D1
	or.w D1,D0
	or.w #$9000,D0
	move.w D0,VDP_CONTROL
	RTS
	
MD_SetBackgroundColor
	or.w #$8700,D0
	move.w D0,VDP_CONTROL
	RTS

MD_LoadPatterns:
	
	;Convert the pattern number into the memory offset
	LSL #5,D1
	Move.l D1,D3
	And.w #$3fff,D1
	SWAP D1
	
	And.w #$c000,D3
	SWAP D3
	LSL #2,D3
	Or.w D3,D1	
	Or.l #$40000000,D1
    move.l D1,VDP_CONTROL

	move.l d0,a0             ; Load address of Characters into a0
	subq.b   #1,d2            ; Num patterns - 1
	;Copy one pattern
CopyPattern:
	move.l (a0)+,VDP_DATA       ; Move data to VDP data port, and increment source address
	move.l (a0)+,VDP_DATA       ; Move data to VDP data port, and increment source address
	move.l (a0)+,VDP_DATA       ; Move data to VDP data port, and increment source address
	move.l (a0)+,VDP_DATA       ; Move data to VDP data port, and increment source address
	move.l (a0)+,VDP_DATA       ; Move data to VDP data port, and increment source address
	move.l (a0)+,VDP_DATA       ; Move data to VDP data port, and increment source address
	move.l (a0)+,VDP_DATA       ; Move data to VDP data port, and increment source address
	move.l (a0)+,VDP_DATA       ; Move data to VDP data port, and increment source address	
	dbra     d2,CopyPattern
	RTS
	
MD_True:
	MoveQ #-1,D0
	RTS
	
MD_False:
	MoveQ #0,D0
	RTS
	