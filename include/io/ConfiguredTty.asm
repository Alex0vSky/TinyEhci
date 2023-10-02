; Copyright 2023 Alex0vSky (https://github.com/Alex0vSky)
; io/ConfiguredTty.asm - main file including code for text video mode functionality
%ifndef def_$io$ConfiguredTty$_once ; #pragma once
%define def_$io$ConfiguredTty$_once

; How to display a symbol on the screen should be specified in the main config
%ifndef def_$io$Tty$bPrintChar_DirectHardware
%ifndef def_$io$Tty$bPrintChar_Bios
	%error "Please define one of 'def_$io$Tty$bPrintChar_*' values"
%endif
%endif

; If not specified, skip default setting
%ifndef def_$io$Tty$bOmitDefaut
	; Default setting of the symbol output config when using hardware
	%ifdef def_$io$Tty$bPrintChar_DirectHardware

		; What to use for scrolling
		;	hardware
		%define def_$io$OvrOutputDirectHardware$bScrollType_Hardware
		;	moving memory
		; %define def_$io$OvrOutputDirectHardware$bScrollType_Memmove
		;	call bios. Probably useless, but for testing the growth of the code structure
		; %define def_$io$OvrOutputDirectHardware$bScrollType_Bios

		; How to control the cursor
		;	through hardware
		%define def_$io$OvrOutputDirectHardware$bCursorType_Hardware
		;	via bios. Probably useless, but for testing the growth of the code structure
		; %define def_$io$OvrOutputDirectHardware$bCursorType_Bios

		; Features
		;	use WrapOnScroll when scrolling through hardware
		;	this is... <add description>
		%define def_$dev$Vga$Crt$scroll$DirectHardware$bUseWrapOnScroll

	%endif ; def_$io$Tty$bPrintChar_DirectHardware
%endif ; def_$io$Tty$bOmitDefaut

; Checking the symbol output config settings
;	warn that there is no point in "wrap" when memory movement is used for scrolling
%ifdef def_$io$OvrOutputDirectHardware$bScrollType_Memmove
	%ifdef def_$dev$Vga$Crt$scroll$DirectHardware$bUseWrapOnScroll
		%warning "Useless WrapOnScroll when ScrollType_Memmove"
	%endif
%endif

; Checking the "Dword" output config settings
%ifdef def_$io$Tty$UsingPrintChar$bAllow_hexDword
%ifdef def_$io$Tty$UsingPrintChar$bOnly_hexDword
	%error "Please define one of 'def_$io$Tty$UsingPrintChar$*_hexDword' values"
%endif
%endif

; Default helper config
%ifndef def_$io$Tty$UsingPrintChar$bOmitDefaut

	; 429-326=103 bytes to hexes
	%define def_$io$Tty$UsingPrintChar$bAllow_hexByte
	%define def_$io$Tty$UsingPrintChar$bAllow_hexWord
	%define def_$io$Tty$UsingPrintChar$bAllow_hexDword

	%define def_$io$Tty$UsingPrintChar$bAllow_Dec
	; 326-309=17 byte to string output
	%define def_$io$Tty$UsingPrintChar$bAllow_szString
	%define def_$io$Tty$UsingPrintChar$bAllow_CrLf
%endif ; def_$io$Tty$UsingPrintChar$bOmitDefaut

; Iclude file selector
%include "io/OvrTty.asm"

%endif ; def_$io$ConfiguredTty$_once
