; Copyright 2023 Alex0vSky (https://github.com/Alex0vSky)
; dvc/Cpu/bigUnrealMode/trashFirstEntry.asm - working with Big Unreal Mode, the first record from the table (not used by the processor) is filled with garbage or random data
%ifndef def_dvc$Cpu$bigUnrealMode$trashFirstEntry$_once ; #pragma once
%define def_dvc$Cpu$bigUnrealMode$trashFirstEntry$_once

; -------------------------------------------------------------------------------------------------
; -//- 
;	@insp dvc\Cpu\bigUnrealMode\zeroidFirstEntry.asm
; registers are not saved
dvc$Cpu$bigUnrealMode$trashFirstEntry$enterIn$_unsafe_:

	; save real mode
	push ds
	; load gdt register	
	lgdt [ g_dvc$Cpu$bigUnrealMode$lpDescrGdt ]
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

dvc$Cpu$bigUnrealMode$trashFirstEntry$_end:
%endif ; def_dvc$Cpu$bigUnrealMode$trashFirstEntry$_once
