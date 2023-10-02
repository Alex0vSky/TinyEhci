; Copyright 2023 Alex0vSky (https://github.com/Alex0vSky)
; BootTime/markedSectorsAndFddSize.inl - stub which usually goes at the end of the bootsector, but the code used is also located in eight sectors

; Number of sectors for "recognizable" padding
;	one "qTD" can "transport" 5 buffers, one buffer fits 8 "sectors" / logical unit from a USB flash drive
%assign uCntAddingSectors_ ( 5 * 8 )
; Convert the size of the code and data located above to the default value
%assign value_ ( $ - $$ )
; Adjust values ​​due to the introduction of the SECTION directive
%ifdef def_$BootTime$markedSectorsAndFddSize$bCorrection
	%assign value_ ( value_ + 512 )
%endif
; Number of bytes in flop
%assign uCntBytesInFdd_ ( 1474560 )
; The last occupied sector (I’m announcing everything here just so I don’t forget to undef)
%assign uNumOccupiedSector_ ( 1 )
; ; Number of free bytes in the last occupied sector (I declare everything here just so as not to forget to do undef)
; %warning value_
; %assign uCntLeftBytesInSector_ ( value_ %% 512 ) ; 249
; %warning uCntLeftBytesInSector_
; %assign uCntLeftBytesInSector_ ( 512 - ( value_ %% 512 ) )
; %warning uCntLeftBytesInSector_
; Index (I declare everything here just so I don’t forget to undef)
%define i_

; With "marking" of sectors to recognize them by "signatures", and disguised as "Fdd" by size
;	as if
; Let's count the number of sectors filled with code
%assign i_ ( 1 )
%rep ( uCntAddingSectors_ + 1 )
	; If it goes beyond sector number N
	%if value_ > ( 512*i_ )
		%assign uNumOccupiedSector_ ( i_ + 1 )
	%endif
	%assign i_ ( i_ + 1 )
%endrep

; %warning uNumOccupiedSector_
; %warning uCntAddingSectors_

; If the number of occupied sectors exceeds the number of provided sectors
%if ( uNumOccupiedSector_ > ( uCntAddingSectors_ + 1 ) )
	%assign x_ ( uCntAddingSectors_ + 1 )
	%error Amount occupied sectors: uNumOccupiedSector_, exceeds amount provided sectors: x_
	%undef x_
%endif

; Stuffing a sector that is already occupied with zeros
times ( ( 512 * ( uNumOccupiedSector_ ) ) - value_ ) db 0

%assign i_ ( 1 )
%rep ( uCntAddingSectors_ + 1 )
	; If it goes beyond sector number N
	%if i_ > ( uNumOccupiedSector_ )
		%ifdef def_$BootTime$markedSectorsAndFddSize$bSignature
			%if i_ != ( 0x29 )
				db 0x00
				times ( 512 - 1 ) db ( i_ )
			%else
				; this is a signature 0x90B1FDE9=( ( c_cMsdId << 24 ) | ( ( ( ( -c_dvc$Pci$Usb$Ehci$wLastSector ) & 0xFFFF ) - 3 ) << 8 ) | ( 0xE9 ) )
				;	mnemonic code for instructions "jmp word/near"
				db 0xE9
				;	offset where to jump (signed short/word) and minus three (full length of the instruction)
				dw ( -3 ) + ( -( c_dvc$Pci$Usb$Ehci$wLastSector ) )
				;	Flash's ID
				db c_cMsdId
				; end of signature
				times ( 512 - 4 ) db ( i_ )
			%endif
		%else
			db 0x00
			times ( 512 - 1 ) db ( i_ )
		%endif
	%endif
	%assign i_ ( i_ + 1 )
%endrep

db 0x00
times ( uCntBytesInFdd_ - 512 - ( 512 * ( uCntAddingSectors_ ) ) - 1 ) db '_'

%undef uCntAddingSectors_
%undef value_
%undef uCntBytesInFdd_
%undef uNumOccupiedSector_
; %undef uCntLeftBytesInSector_
%undef i_
