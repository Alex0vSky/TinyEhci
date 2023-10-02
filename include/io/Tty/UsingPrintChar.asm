; Copyright 2023 Alex0vSky (https://github.com/Alex0vSky)
; io/Tty/UsingPrintChar.asm - a set of functions using the "PrintChar" implementation for displaying on the screen

%ifdef def_$io$Tty$UsingPrintChar$bAllow_hexByte
; -------------------------------------------------------------------------------------------------
; Printing a byte in hexadecimal format to the screen
	%include "io/Tty/printSpec/hexByte.asm"
	io$Tty$printHexByte equ io$Tty$printSpec$hexByte$
%endif

%ifdef def_$io$Tty$UsingPrintChar$bAllow_hexWord
; -------------------------------------------------------------------------------------------------
; Printing a word in hexadecimal format on the screen
	%include "io/Tty/printSpec/hexWord.asm"
	io$Tty$printHexWord equ io$Tty$printSpec$hexWord$
%endif

%ifdef def_$io$Tty$UsingPrintChar$bAllow_hexDword
; -------------------------------------------------------------------------------------------------
; Printing a double word in hexadecimal format to the screen
	%include "io/Tty/printSpec/hexDword.asm"	
	; The "nasm" compiler first runs all the includes and only then can output warnings or errors from the user
	%ifndef def_$io$Tty$UsingPrintChar$bDefined_hexDword
	%define def_$io$Tty$UsingPrintChar$bDefined_hexDword
		io$Tty$printHexDword equ io$Tty$printSpec$hexDword$
	%endif
%endif

; There is a logical OR
%ifdef def_$io$Tty$UsingPrintChar$bAllow_hexNybbles def_$io$Tty$UsingPrintChar$bAllow_hexByte def_$io$Tty$UsingPrintChar$bAllow_hexWord def_$io$Tty$UsingPrintChar$bAllow_hexDword
; -------------------------------------------------------------------------------------------------
; Printing nibbles in hexadecimal format on the screen
	%include "io/Tty/printSpec/hexNybbles.asm"
%endif



%ifdef def_$io$Tty$UsingPrintChar$bOnly_hexDword
; -------------------------------------------------------------------------------------------------
; A minimal and self-contained option for displaying a double word in hexadecimal format on the screen
	%include "dvc/Vga/standalonePrintHexDword.asm"
	; The "nasm" compiler first runs all the includes and only then can output warnings or errors from the user
	%ifndef def_$io$Tty$UsingPrintChar$bDefined_hexDword
	%define def_$io$Tty$UsingPrintChar$bDefined_hexDword
		io$Tty$printHexDword equ dvc$Vga$standalonePrintHexDword$
	%endif
%endif



%ifdef def_$io$Tty$UsingPrintChar$bAllow_Dec
; -------------------------------------------------------------------------------------------------
; Printing a word in decimal format on the screen.
	%include "io/Tty/printSpec/unsignedDecimalWord.asm"
	io$Tty$printDecWord equ io$Tty$printSpec$unsignedDecimalWord$
%endif



%ifdef def_$io$Tty$UsingPrintChar$bAllow_szString
; -------------------------------------------------------------------------------------------------
; Printing a string to the screen, the string is stored in memory with a "zero-terminated"
	%include "io/Tty/printSpec/nullTerminatedString.asm"
	; alias
	io$Tty$printNullTerminatedString equ io$Tty$printSpec$nullTerminatedString$
%endif ; def_$io$Tty$UsingPrintChar$bAllow_szString



; Only if the self-explanatory output "Dword" is not specified
%ifndef def_$io$Tty$UsingPrintChar$bOnly_hexDword
%ifdef def_$io$Tty$UsingPrintChar$bAllow_CrLf def_$io$Tty$UsingPrintChar$bAutoCrLf_onHex
; -------------------------------------------------------------------------------------------------
; Line break
	%include "io/Tty/printSpec/CrLf.asm"
	io$Tty$printCrLf equ io$Tty$printSpec$CrLf$
%endif
%endif
