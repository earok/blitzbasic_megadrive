
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
    args byte
    libs
    subs MD_ModeRegister4,0,0	
  name "MD_ModeRegister4","Width (MD_TRUE=320,MD_FALSE=256)"
	
  astatement
    args long,long,long
    libs
    subs MD_LoadPatterns,0,0	
  name "MD_LoadPatterns","Pattern address, first pattern index, num of patterns"
	
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
    subs MD_Stop,0,0	
  name "MD_Stop","Stop the MegaDrive CPU"

  astatement
    args
    libs
    subs MD_ClearRAM,0,0	
  name "MD_ClearRAM","Clear all RAM (except the current stack pointer)"

  astatement
    args
    libs
    subs MD_Fake_AllocMem,0,0	
  name "MD_Fake_AllocMem","A fake version of Exec.Library's AvailMem function"

  afunction long
	args
	libs
	subs MD_True,0,0
  name "True","Substitute for Amiga true"

  afunction long
	args
	libs
	subs MD_False,0,0
  name "False","Substitute for Amiga false"

blitz_finit:
	nullsub _blitz_ahx_lib_finit,0,0
	libfin

_blitz_ahx_lib_finit:
	rts	

	include "megadrivelib_functions.s"


	