DEFTYPE .l

if NumPars < 2
	NPrint "Usage: Blitz2Sega [input] [output] (32x) (neogeo)"
	End
endif

if Exists(Par$(1)) = false
	NPrint "Input file doesn't exist"
	End
endif

LoadBank 0,Par$(1)

if Peek.l(Bank(0)) <> $3f3
	NPrint "Not an Amiga executable"
	End
endif

CodeStart = Bank(0) + $20 ;Skip the Initalisation hunk
CodeLength = Peek.l(CodeStart - 4) * 4
Relocates = Peek.l(CodeStart + CodeLength + 4)
RelocateStart = CodeStart + CodeLength + 12

CodeOffset.l = -8
if NumPars > 2
	select Par$(3)
		case "32x"
			CodeOffset + $880000
		case "neogeo"
			IsNeoGeo = true
		Default
			NPrint "Unknown options"
			End
	end select
endif

;Fix the address offsets
for i = 0 to Relocates - 1
	Address = Peek.l(RelocateStart)
	NewValue = Peek.l(CodeStart + Address) + CodeOffset
	Poke.l CodeStart+Address, NewValue
	RelocateStart + 4
next

;Move the blitz initialisation address further into the program
Address = CodeStart
BlitzInitFixed = false
While BlitzInitFixed = false
	if Address > CodeStart + CodeLength
		NPrint "Unable to find BLTZINIT ($424C545A,$494E4954)"
		End
	endif
	if Peek.l(Address) = $424C545A and Peek.l(Address+4) = $494E4954
		Poke.l Address,Peek.l(CodeStart)
		Poke.l Address+4,Peek.l(CodeStart+4)
		BlitzInitFixed = true
	else
		Address + 2
	endif	
Wend

;The first eight bytes are no longer needed
CodeStart+8
CodeLength-8

;We only fix the check sum and code size on Mega Drive
if IsNeoGeo = false

	;Set the ROM Size
	Poke.l CodeStart + $1A4,CodeLength-1

	;Set the MDChecksum
	MDChecksum = 0
	Address = CodeStart + $200
	While Address < CodeStart + CodeLength
		MDChecksum + Peek.w(Address)
		Address + 2	
	Wend

	Poke.w CodeStart + $18E,MDChecksum

endif

;Final check to see if there's a reference to ".lib", implying that an Amiga library is present
HasLibraryReference = false
Address = CodeStart
While Address < CodeStart + CodeLength
	if Peek.l(Address) = $2E6C6962
		HasLibraryReference = true
	endif
	Address + 1
Wend


if WriteFile(0,Par$(2))
	WriteMem 0,CodeStart,CodeLength
	CloseFile 0	
else
	if IsNeoGeo
		NPrint "Could not save Neo Geo file"
	else
		NPrint "Could not save Mega Drive file"
	endif
	End
endif

if HasLibraryReference
NPrint "Probable error - library detected. Are you using a Blitz lib"
NPrint "that refers to Amiga libraries?"
NPrint "(even the True or False keywords could trigger that)"
else
if IsNeoGeo
NPrint "Successfully(?) generated Neo Geo file. Good luck!"
else
NPrint "Successfully(?) generated Mega Drive file. Good luck!"
endif
endif

End
