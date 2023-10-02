; Copyright 2023 Alex0vSky (https://github.com/Alex0vSky)
; dvc/Pci/Usb/Ehci/asyncList/dataStruc/realModeAddr_segDs0/attachedSglQh/setHorizLinkPtr.asm - creation of data structures by code in memory segment 0 pointed to by the "ds" register, one "Qh" connected to the existing one from the BIOS "Qh"
%ifndef def_dvc$Pci$Usb$Ehci$asyncList$dataStruc$realModeAddr_segDs0$attachedSglQh$setHorizLinkPtr$_once ; #pragma once
%define def_dvc$Pci$Usb$Ehci$asyncList$dataStruc$realModeAddr_segDs0$attachedSglQh$setHorizLinkPtr$_once

; -------------------------------------------------------------------------------------------------
; -//-
; Inserting a new address
;	@insp dvc\Pci\Usb\Ehci\asyncList\dataStruc\realModeAddr_segDs0\attachedTwoQh.asm
; in: eax = ASYNCLISTADDR
; in: dI = asynchronousList
; in: ds = 0
dvc$Pci$Usb$Ehci$asyncList$dataStruc$realModeAddr_segDs0$attachedSglQh$setHorizLinkPtr$_inline_:

	; QhSgl_HorizontalLinkPointer, points to "ASYNCLISTADDR", there is "Qh" with "HeadOfReclamationList" from the BIOS
	or al, 2
	mov dword [ di + c_dwOffset_QhSgl$_beg + 4*0 ], eax
	; Point to "Qh1" via "Qh" with "HeadOfReclamationList" from BIOS
	and al, ( ~2 )
	mov dword [ eax ], ( c_ddAddrAsyncListInLoMem_Qh1 + 2 )

dvc$Pci$Usb$Ehci$asyncList$dataStruc$realModeAddr_segDs0$attachedSglQh$setHorizLinkPtr$_end:
%endif ; def_dvc$Pci$Usb$Ehci$asyncList$dataStruc$realModeAddr_segDs0$attachedSglQh$setHorizLinkPtr$_once

; Here is a list of commands to view the staff
%if 0
; REM	qemu
	powershell -ep Bypass QemuExecHmp xp/12xw 1*0x07FDEF00
	powershell -ep Bypass QemuExecHmp xp/12xw 1*0x000EAB00
	powershell -ep Bypass QemuExecHmp xp/12xw 1*0x000EAB80
; REM	QH1
	powershell -ep Bypass QemuExecHmp xp/12xw 1*0x500+0x60
; REM	QH2
	powershell -ep Bypass QemuExecHmp xp/12xw 1*0x500+0x60+0x60
; REM	qTD0
	powershell -ep Bypass QemuExecHmp xp/13xw 1*0x500+0x300
; REM	qTD1
	powershell -ep Bypass QemuExecHmp xp/13xw 1*0x500+0x400
; REM 	BufferPagePonterList[Page0] with the command
	powershell -ep Bypass QemuExecHmp xp/31xb 1*0x8000+512*0
; REM 	BufferPagePonterList[Page0] with read sectors
	powershell -ep Bypass QemuExecHmp xp/514xb 1*0x8000+512*0
	powershell -ep Bypass QemuExecHmp xp/514xb 1*0x8000+512*1
	powershell -ep Bypass QemuExecHmp xp/514xb 1*0x8000+512*2
	powershell -ep Bypass QemuExecHmp xp/514xb 1*0x8000+512*3
	powershell -ep Bypass QemuExecHmp xp/514xb 1*0x8000+512*8*5-512
; REM	QH sgl
	powershell -ep Bypass QemuExecHmp xp/12xw 1*0x500
; REM	qTD sgl
	powershell -ep Bypass QemuExecHmp xp/13xw 1*0x500+0x60
; REM	config descr
	powershell -ep Bypass QemuExecHmp xp/32xb 1*0x00007E00
; REM	USBC
	powershell -ep Bypass QemuExecHmp xp/20xb 1*0x7C00+3
	powershell -ep Bypass QemuExecHmp xp/20xb 1*0x7C00+0x1EA
%endif
