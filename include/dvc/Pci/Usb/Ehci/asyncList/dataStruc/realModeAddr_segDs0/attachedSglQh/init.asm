; dvc/Pci/Usb/Ehci/asyncList/dataStruc/realModeAddr_segDs0/attachedSglQh/init.asm - creation of data structures by code in memory segment 0 pointed to by the "ds" register, one "Qh" connected to the existing one from the BIOS "Qh"
%ifndef def_dvc$Pci$Usb$Ehci$asyncList$dataStruc$realModeAddr_segDs0$attachedSglQh$init$_once ; #pragma once
%define def_dvc$Pci$Usb$Ehci$asyncList$dataStruc$realModeAddr_segDs0$attachedSglQh$init$_once

; -------------------------------------------------------------------------------------------------
; -//-
; Initialization must be called once
;	@insp dvc\Pci\Usb\Ehci\asyncList\dataStruc\realModeAddr_segDs0\attachedTwoQh.asm
;	by default "Endpt" is set to "control"
; in: dI = "asynchronousList"
; in: ds = 0
dvc$Pci$Usb$Ehci$asyncList$dataStruc$realModeAddr_segDs0$attachedSglQh$init$_inline_:

	; QH1
	;	EndpointCharacteristics
	%xdefine def_dwCalculatedVal 0
	;		bit[31:28] Nak Count Reload(RL). Like in tatOs
	%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 5 << 28 )
	; TODO(alex): it is advisable to set from the descriptor
	;		bit[26:16] MaximumPacketLength. The working value was 0x200, the maximum possible was 0x400
	%xdefine def_dwCalculatedVal def_dwCalculatedVal|( c_Qh_endpointCh_cMaximumPacketLength << 16 )
	;		bit[13:12] EndpointSpeed(EPS) = 010b = HiSpeed(HS) (0x00002000) (fromHadrware)
	%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 010b << 12 )
	;		bit[11:8] Endpt = control
	%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 0x00 << 8 )
	;		bit[6:0] DeviceAddress
	%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 0 )
	;			set
	mov dword [ di + c_dwOffset_QhSgl$_beg + c_dwOffset_Qh__EndpointCharacteristics ], ( def_dwCalculatedVal )
	; 	EndpointCapabilities
	;		bit[31:30] Mult(HiBandwidthPipeMultiplier) = 01b = 1 transaction per microframe. Zero will unfortunately give undefined behavior
	mov byte [ di + c_dwOffset_QhSgl$_beg + 4*2 + 3 ], ( 0x40 ) ; whole byte
	;	TransferOverlay
	;		transferOverlay__qTD_CurrentPointer = 0
	;		transferOverlay__qTD_NextPointer = terminate
	inc byte [ di + c_dwOffset_QhSgl$_beg + c_dwOffset_Qh__qTd_NextPointer ]
	;		transferOverlay__qTD_AlternativeNextPointer = terminate, written here with the controller "Nak"
	inc byte [ di + c_dwOffset_QhSgl$_beg + 4*5 ]

	; First qTD, qTD0
	;	qTD_NextPointer = terminate, "inc" takes up four bytes and is shorter than "mov" 1 by one byte
	inc byte [ di + c_dwOffset_qTd$_beg + 4*0 ]
	;	qTD_AlternativeNextPointer = terminate (checked when "short packet", if not valid, then "qemu" error "processing error - resetting ehci HC")
	inc byte [ di + c_dwOffset_qTd$_beg + 4*1 ]

dvc$Pci$Usb$Ehci$asyncList$dataStruc$realModeAddr_segDs0$attachedSglQh$init$_end:
%endif ; def_dvc$Pci$Usb$Ehci$asyncList$dataStruc$realModeAddr_segDs0$attachedSglQh$init$_once
