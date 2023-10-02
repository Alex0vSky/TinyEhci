; Copyright 2023 Alex0vSky (https://github.com/Alex0vSky)
; dvc/Cpu/bigUnrealMode/zeroidFirstEntry.asm - working with Big Unreal Mode, the first entry from the table (not used by the processor) is filled with zeros
%ifndef def_dvc$Cpu$bigUnrealMode$zeroidFirstEntry$_once ; #pragma once
%define def_dvc$Cpu$bigUnrealMode$zeroidFirstEntry$_once

; -------------------------------------------------------------------------------------------------
; Enter to Big Unreal Mode
;	if "ds" is configured, then this is a register, by default for almost ("stos" uses "es") all read/write, can address 32bit
;	code size without the "call" instruction: 0x015F-0x0128-3=0x34(52)
; registers are not saved
dvc$Cpu$bigUnrealMode$zeroidFirstEntry$enterIn$_unsafe_:

	; We place "GDT" from one working descriptor number 8, in memory filled with zeros, saving four bytes
	; 	this should be placed after the zeros
	;		db 0xff, 0xff, 0, 0,	0, 10010010b, 11001111b, 0	; {8} .flatdesc, 8 byte, -1 word, 0xCF92
	; dec word [ c_localVar$dvc$Cpu$bigUnrealMode$zeroidFirstEntry$wAddrGdt + 8 + 0 ] ; 4 byte, old
	; mov word [ c_localVar$dvc$Cpu$bigUnrealMode$zeroidFirstEntry$wAddrGdt + 8 + 4 + 1 ], ( ( 10010010b ) | ( 11001111b ) << 8 ) ; 6 byte, 0xCF92, old
	mov bx, ( c_localVar$dvc$Cpu$bigUnrealMode$zeroidFirstEntry$wAddrGdt + 8 + 0 ) ; 3, if to
	dec word [ bx ] ; 2 byte
	mov word [ bx + 4 + 1 ], ( ( 10010010b ) | ( 11001111b ) << 8 ) ; 5 byte, 0xCF92

	; save real mode
	push ds
	; load gdt register	
	;	"nasm" does not know how to correctly optimize the offset, it lies inside "byte", and nasm thinks that it is "word"
	;	usually they do this when "byte" is greater than 0x7F this is "byte" with a minus sign
	;		mnemonic code "lgdt [ bx + ", first part
	db 0x0F, 0x01, 0x57
	;		mnemonic code, second part
	db ( g_dvc$Cpu$bigUnrealMode$lpDescrGdt - c_localVar$dvc$Cpu$bigUnrealMode$zeroidFirstEntry$wAddrGdt - 8 ) ; 0x27
	; lgdt [ g_dvc$Cpu$bigUnrealMode$lpDescrGdt ] ; 5 byte, old

	; switch to pmode by
	mov eax, cr0
	; set pmode bit
	or al, 1
	mov cr0, eax
	; ; tell 386/486 to not crash
	; jmp $+2
	; select descriptor 1
	mov bx, 0x08
	; 8h = 1000b
	mov ds, bx
	; back to realmode
	and al, 0xFE
	; by toggling bit again
	mov cr0, eax
	; get back old segment
	pop ds

	; ;	check, a white smiley should appear on the screen, in text mode
	; mov bx, 0x0f01         ; attrib/char of smiley
	; mov eax, 0x0b8000      ; note 32 bit offset
	; mov word [ds:eax], bx
%ifndef inline_me_
	ret
%endif

dvc$Cpu$bigUnrealMode$zeroidFirstEntry$_end:
%endif ; def_dvc$Cpu$bigUnrealMode$zeroidFirstEntry$_once
