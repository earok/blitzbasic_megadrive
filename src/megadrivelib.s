
  include "blitz.i"

	libheader $89,0,0,blitz_finit,0
  ; BB2 library header
  
  astatement
    args
    libs
    subs MD_VWait,0,0
    args word
    libs
    subs MD_VWait_Frames,0,0		
  name "MD_VWait","MD_VWait [frames] Waits for the next vertical blank"
	
  astatement
    args long,word,word
    libs
    subs MD_LoadPalette,0,0	
  name "MD_LoadPalette","Palette address, first color index, num of colors"
	
  astatement
    args long,word,word,quick
    libs
    subs MD_FadePalette,0,0	
  name "MD_FadePalette","Palette address, first color index, num of colors,fade amount (quick)"
	
  astatement
    args byte
    libs
    subs MD_SetBackgroundColor,0,0	
  name "MD_SetBackgroundColor","Background color index"
	
  astatement
    args byte,byte
    libs
    subs MD_SetPlaneSize,0,0	
  name "MD_SetPlaneSize","Width,Height. 0=256 pixels 1=512pixels 3=1024pixels"
	
  astatement
    args word, word
    libs
    subs MD_ModeRegister2,0,0	
  name "MD_ModeRegister2","EnableDisplay,Height (-1=240,0=224)"

  astatement
    args word,word
    libs
    subs MD_ModeRegister4,0,0	
  name "MD_ModeRegister4","Width (-1=320,0=256),Highlight/Shadow mode"
	
  astatement
    args long,long,long
    libs
    subs MD_LoadPatterns,0,0	
  name "MD_LoadPatterns","Pattern address, first pattern index, num of patterns"
		
  astatement
    args long,long,long
    libs
    subs MD_LoadPatterns_DMA,0,0	
  name "MD_LoadPatterns_DMA","Pattern address, first pattern index, num of patterns"

  astatement
    args long,word,word,word
    libs
    subs MD_SetColor,0,0	
  name "MD_SetColor","Index,Red,Green,Blue (in 1-255 range)"

  astatement
    args word,long
    libs
    subs MD_CopyTo_VDP_W,0,0
  name "MD_CopyTo_VDP_W","Word Data,Dest Address"	

  astatement
    args long,long
    libs
    subs MD_CopyTo_VDP_L,0,0
  name "MD_CopyTo_VDP_L","Word Data,Dest Address"	

  astatement
    args long,long,long,long
    libs
    subs MD_CopyTo_VDP,0,0
  name "MD_CopyTo_VDP","Source Address,Length,Dest Address,Auto Increment"	
	
  astatement
    args long,long,long
    libs
    subs MD_DMA_Transfer,0,0
  name "MD_DMA_Transfer","Source Address,Length,Dest Address"	

  astatement
    args long,long,long,long,long,long
    libs
    subs MD_CopyTo_NameTable,0,0
  name "MD_CopyTo_NameTable","Source Address,Dest Address,XSize,YSize,Source Modulo,Dest Modulo"	
	
  astatement
    args word,word,word,word,long
    libs
    subs MD_Scroll,0,0
  name "MD_Scroll","FG X,FG Y,BG X,BG Y,HScroll Table Address"	

  afunction long
    args word,word
    libs
    subs MD_SetHorizontalScrollTable,0,0
  name "MD_SetHorizontalScrollTable","HScroll Table Address, Scroll mode (0/2/3). Returns value to feed into scroll function"	

  astatement
    args word
    libs
    subs MD_SetSpriteTable,0,0
  name "MD_SetSpriteTable","Sprite Table Address"	

  afunction word
    args
	libs
	subs MD_IsResetButtonPressed,0,0
  name "MD_IsResetButtonPressed","Returns -1 if button is pressed"
	
  astatement
    args
    libs
    subs MD_Setup,0,0	
  name "MD_Setup","Initialisation process for Mega Drive"

  astatement
    args
    libs
    subs MD_ClearVDP,0,0	
  name "MD_ClearVDP","Clears the VDP (tiles,map,palette etc)"

  astatement
    args
    libs
    subs MD_Stop,0,0	
  name "MD_Stop","Stop the MegaDrive CPU"

  astatement
    args
    libs
    subs MD_Fake_AllocMem,0,0	
  name "MD_Fake_AllocMem","A fake version of Exec.Library's AvailMem function"

  afunction word
	args
	libs
	subs MD_GamePad1_3Button,0,0
  name "MD_GamePad1_3Button","Button State for GamePad 1 - SACBRLDU"

  afunction word
	args
	libs
	subs MD_GamePad2_3Button,0,0
  name "MD_GamePad2_3Button","Button State for GamePad 2 - SACBRLDU"

  astatement
	args long
	libs
	subs MD_SetPlaneANameTable,0,0
  name "MD_SetPlaneANameTable","Set the address of Plane A Name Table"

  astatement
	args long
	libs
	subs MD_SetPlaneBNameTable,0,0
  name "MD_SetPlaneBNameTable","Set the address of Plane B Name Table"

  astatement
	args long
	libs
	subs MD_SetWindowNameTable,0,0
  name "MD_SetWindowNameTable","Set the address of Window Name Table"

  astatement
	args word,word,word,word
	libs
	subs MD_SetWindowPosition,0,0
  name "MD_SetWindowPosition","X Offset,Y Offset,From Right,From Bottom"

  astatement
	args long,long,long,word
	libs
	subs MD_MDSDRV_Init,0,0
  name "MD_MDSDRV_Init","Work area of >= 1024 bytes,Sequence pointer,PCM data pointer,DMA protection bytes"

  astatement
	args long
	libs
	subs MD_MDSDRV_Update,0,0
  name "MD_MDSDRV_Update","Work area of >= 1024 bytes"

  astatement
	args long,long,long
	libs
	subs MD_MDSDRV_Volume,0,0
  name "MD_MDSDRV_Volume","Volume (0-256), Priority, Work area of >= 1024 bytes"

  astatement
	args long,long,long
	libs
	subs MD_MDSDRV_GVolume,0,0
  name "MD_MDSDRV_GVolume","Music Volume (0-256), Sound Volume (0-256), Work area of >= 1024 bytes"

  astatement
	args long,long,long
	libs
	subs MD_MDSDRV_Request,0,0
  name "MD_MDSDRV_Request","Sound number,priority level,Work area of >= 1024 bytes"

blitz_finit:
	nullsub _blitz_ahx_lib_finit,0,0
	libfin

_blitz_ahx_lib_finit:
	rts	

	include "megadrivelib_functions.s"


	