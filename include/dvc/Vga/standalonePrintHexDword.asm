; dvc/Vga/standalonePrintHexDword.asm - outputting a double word in hexadecimal format to the screen, a self-contained option. The goal is minimum code
%ifndef def_dvc$Vga$standalonePrintHexDword$_once ; #pragma once
%define def_dvc$Vga$standalonePrintHexDword$_once

%include "dvc/Vga/TextMode.inc"

; ; ; Let's place a local variable in front of the bootsector
; ; %define def_dvc$Vga$standalonePrintHexDword$dwAddr_ddForLods ( 0x7C00 - 4 )
; ; 12 bytes of buffer where the future line will be placed (you need 11 but I’ll do the alignment at 2 for, perhaps... the stack)
; %define def_dvc$Vga$standalonePrintHexDword$dwAddr_ddString ( 0x7C00 - 12 )

; -------------------------------------------------------------------------------------------------
; -//-
;	functional size
;		0x29(41) bytes with direct memory output
;		0x23(35) bytes with BIOS interrupts
;	this is shorter than a bunch of functions "io/*Tty*" along with many call instructions for 0x0136-0x00FA=0x3C(60) bytes
;	it is assumed that the text mode video memory is filled with valid (visible) character color values
;	the disadvantage is the lack of screen output in qemu in nographic mode, which means the tests will be slower
;	During initialization, I set the address of this function to bp and call it through this register. To save one byte
;	Direct writing to memory does not work on hardware. Maybe you need to switch the page or scroll
;	@insp https://codegolf.stackexchange.com/questions/193793/little-endian-number-to-string-conversion/193837#193842
; in: eax = double word
dvc$Vga$standalonePrintHexDword$:
	; The high part of the 32-bit word eax will return to the initial value, so we do not save it
	pusha

;	mov di, def_dvc$Vga$standalonePrintHexDword$dwAddr_ddString
	mov cx, 8
	.loop:
		; Move the senior nible to the junior place
		rol eax, 4
		; save/restore
		push ax
		; Leave only the nibble in "al"
		and al, 0x0F
		; Convert "al(nibl)" to hex in place of "al(byte)"
		cmp	al, 10
		sbb	al, 0x69
		das
		; Print "al" as a character
		mov ah, 0x0E
		int 0x10
;		stosb
		; save/restore
		pop ax
	loop .loop;

%ifndef def_dvc$Vga$standalonePrintHexDword$bOmitNewlineAsDelim
	; Line break (10 bytes!)
	mov ah, 0x0E
	;	Carriage Return (CR) character (\r)
	mov al, 0x0D
	int 0x10
	;	Line Feed (LF) character (\n)
	mov al, 0x0A
	int 0x10
%endif

	; ; Space (6 bytes)
	; mov ah, 0x0E
	; mov al, 0x0A
	; int 0x10

;	; Print string
;	mov al, 01h ; Assign all characters the attribute in BL; update cursor
;	mov bh, 0x00            ;page number
;	mov bl, 0x1F            ;atributes
;	mov cx, 8
;	xor dx, dx ; DH = row (on screen), DL = column,
;	mov xx, def_dvc$Vga$standalonePrintHexDword$dwAddr_ddString
;	mov ah, 0x13
;	int 0x10

	popa
	ret

dvc$Vga$standalonePrintHexDword$_end:
%endif ; def_dvc$Vga$standalonePrintHexDword$_once
