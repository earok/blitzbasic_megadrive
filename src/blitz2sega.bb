DEFTYPE .l

if NumPars < 2
	NPrint "Usage: Blitz2Sega [input] [output]"
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

;Fix the address offsets
for i = 0 to Relocates - 1
	Address = Peek.l(RelocateStart)
	NewValue = Peek.l(CodeStart + Address) - 8
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

;Set the ROM Size
Poke.l CodeStart + $1A4,CodeLength-1

;Set the Checksum
Checksum = 0
Address = CodeStart + $200
While Address < CodeStart + CodeLength
	Checksum + Peek.w(Address)
	Address + 2	
Wend

;Final check to see if there's a reference to ".lib", implying that an Amiga library is present
HasLibraryReference = false
Address = CodeStart
While Address < CodeStart + CodeLength
	if Peek.l(Address) = $2E6C6962
		HasLibraryReference = true
	endif
	Address + 1
Wend

Poke.w CodeStart + $18E,Checksum

if WriteFile(0,Par$(2))
	WriteMem 0,CodeStart,CodeLength
	CloseFile 0	
else
	NPrint "Could not save Mega Drive file"
	End
endif

if HasLibraryReference
NPrint "Probable error - library detected. Are you using a Blitz lib"
NPrint "that refers to Amiga libraries?"
NPrint "(even the True or False keywords could trigger that)"
else
NPrint "Successfully(?) generated Mega Drive file. Good luck!"
endif

End
