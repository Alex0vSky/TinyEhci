; Copyright 2023 Alex0vSky (https://github.com/Alex0vSky)
; io/Tty/PrintChar/Bios.asm - output to a video terminal in text mode using BIOS methods
%ifndef def_io$Tty$PrintChar$Bios$_once ; #pragma once
%define def_io$Tty$PrintChar$Bios$_once

; -------------------------------------------------------------------------------------------------
; Displays a byte in hexadecimal format on the screen. @insp https://github.com/thlorenz/learnasm/blob/master/hexdump/hexdump.asm
; in: al = ASCII character code
io$Tty$PrintChar$Bios$:
PrintChar_override:
	push ax
	; TODO(alex): this is in the install sector of Windows 7, then google "push bx + pop bx"
	; mov bx, 0x07 
	mov ah, 0x0E
	int 0x10
	pop ax
	ret

; ; -------------------------------------------------------------------------------------------------
; ; Cleaning the screen
; ClearScreen_override:
	; push ax
	; mov ax, 0x03
	; int 0x10
	; pop ax
	; ret

; TODO(alex): print colors
; https://stackoverflow.com/questions/55778271/print-a-colored-string

io$Tty$PrintChar$Bios$_end:
%endif ; def_io$Tty$PrintChar$Bios$_once
