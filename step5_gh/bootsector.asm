; Copyright 2023 Alex0vSky (https://github.com/Alex0vSky)
; step5_gh\bootsector.asm - main
BITS 16
ORG 0x7C00
SECTION .bootsector
	; Config
	%include "config.inc"
; Global label
..@g_start.bootsector:
	; Stub for loading from hardware
	%include "BootTime/bootRecordFormat/beforePayload/pair_Bpb_UsbLegacySupport.inl"

	; clear the direction flag to always read/write "forward" to instructions like lods/stos
	cld
	; Initial stub option when ax=0
	xor	ax, ax
	; Stub is required before starting work
	%include "BootTime/ax0/adjustDsCs.inl"
	%include "BootTime/adjustStack/ax0/belowThenBootsector.inl"
	; Constants and Macros
	%include "util/bswap.mac"
	%include "dvc/Pci/Usb/Ehci/common.inc" ; (one day)I think nasm is ***, a lot depends on the file extension
	%include "dvc/Pci/Usb/Ehci/macro.mac"
	; Don't do "ret" when including source. 0x000000F1-0x000000E5=0x0C(12)
	%define inline_me_

	; Trace. We will always call the "dword" dumper through this register, so we will save one byte on each call
	mov bp, io$Tty$printHexDword

; Comment out: for it to work in the "qemu" emulator, more space on the bootsector will be required (a trace like a "slip" will work)
;%define realHardware_

	; Make it possible to address memory via 32-bit registers
%ifndef def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPlace_bigUnrealModeTrashFirstEntry
	%include "dvc/Cpu/bigUnrealMode/zeroidFirstEntry.asm"
%else
	%include "dvc/Cpu/bigUnrealMode/trashFirstEntry.asm"
%endif

	; ; Trace. Let's display crc16 from the bootsector
	; xor eax, eax
	; %include "util/crc16ibm/inline.asm"
	; call bp ; qemu=0x000065B3, flashStick=???

	; Search for "EHCI" controller via "PCI"
	;	search for "DeviceAddress" on which the "MSD" controller is located and read sectors
	;	transfer of control to the sector if a signature is found
	%include "dvc/Pci/Usb/Ehci/find/pio/callAfterFound.asm"

	; ; how many bytes are left free for the code in the sector
	; mov eax, ( 512 - 2 - ( ..@g_code_data_end - ..@g_start.bootsector ) ) ; these two weigh five bytes (if "ax", with "eax" eight)
	; call bp ; these two weigh five bytes (if "ax", with "eax" eight)
finish_qemu: ; In qemu "-nographic" is buggy and cuts off the end of the output, so this is at the end
	; mov al, 0x02 ; smiley
	; mov ah, 0x0E ; these two weigh four bytes
	; int 0x10 ; these two weigh four bytes

finish:
;	jmp finish

	; Place for some boot sector functions, there is only a basic output function and a sector reading function
	%include "io/ConfiguredTty.asm"
	%include "dvc/Pci/Usb/Ehci/scanDeviceAddrAndReadX.asm"

; -------------------------------------------------------------------------------------------------
; Data
%ifndef def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPlace_read6
; 	CBW(Command Block Wrapper) + SCSI_read6
g_lpScsiCmd$readX$_beg:
	.dCBWSignature						dd 0x43425355
	.dCBWTag							dd 0x00000000
	.dCBWDataTransferLength				dd ( c_dvc$Pci$Usb$Ehci$uMaxBytesPer_qTd )
	.bmCBWFlags							db 0x80
	.bCBWLUN							db 0x00
	.bCBWCBLength						db 6
	;	above it is 15 bytes, then there is "CBWCB" of 16 bytes in size, of which 6 bytes contain the "block" "SCSI" command. Only 21 bytes out of 31 with payload.
	.SCSI_cOperationCode									db 0x08 ; OPERATION CODE (08h) = "READ (6)" command
		;		start reading from "logicalUnit" number 1, this means the second sector
		.SCSI_.read6.__cLogicalBlockAddress__msb_4_0bit		db 0
		.SCSI_.read6.__wLogicalBlockAddress__lsb			dw bswap_16( 1 )
		;		quantity of "logicalUnit" for transport
		.SCSI_.read6.__wTransferLength						db c_dvc$Pci$Usb$Ehci$uMaxCntSectorsPer_qTd
		; ; 			!!! tmp check
		; .SCSI_.read6.__wTransferLength						db ( c_dvc$Pci$Usb$Ehci$uMaxCntSectorsPer_qTd + 1 ) ; 0x29
%endif ; def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPlace_read6

..@g_code_data_end:

	; Final stub
	%include "BootTime/bootRecordFormat/afterPayload/pair_Bpb_UsbLegacySupport.inl"
	; Define - in order not to forget the second part of "BootRecord", I would like to generate the name of the second define for the check based on the string
%ifdef def_$BootTime$bootRecordFormat$beforePayload$strName
	%ifnidn def_$BootTime$bootRecordFormat$beforePayload$strName, def_$BootTime$bootRecordFormat$afterPayload$strName
		%error please define epilog-end pair for Boot Record named def_$BootTime$bootRecordFormat$beforePayload$strName
	%endif
%endif ; def_pairBootRecord



; -------------------------------------------------------------------------------------------------
; Second sector
;	@insp https://www.nasm.us/xdoc/2.14.02/html/nasmdoc7.html#section-7.1.3
;	the "vstart" option allows you to access addresses from the boot sector by name
;	the beginning of the code of the second sector and the remaining sectors will be located at this address
SECTION .othersectors vstart=c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$wDstAddr
;	mark for "stuffing" sectors
%define def_$BootTime$markedSectorsAndFddSize$bCorrection
;	line output macro
%macro macro_printString 1
	jmp %%declbyte$macro;
		%%szNullTerminatedString$macro: db %1, 0
	%%declbyte$macro:
	mov ax, %%szNullTerminatedString$macro
	call .othersectors$helper$printString;
%endmacro
; Global label
..@g_start.othersectors:

	; flashStick id
	macro_printString "MSD id: "
	mov eax, c_cMsdId
	call bp

	; DeviceAddress from Qh
	macro_printString "DeviceAddress: "
	movzx eax, byte [ di + c_dwOffset_QhSetupIn + c_dwOffset_Qh__EndpointCharacteristics ]
	;	leave significant bits
	and al, 01111111b
	call bp

	; Endpt from code
	macro_printString "BulkOutEndpoint: "
	movzx eax, byte [ ..@g_p$SelfModif$BulkOutEndpoint + 3 ]
	;	leave significant bits
	and al, 011b
	call bp
	macro_printString "BulkInEndpoint: "
	movzx eax, byte [ ..@g_p$SelfModif$BulkInEndpoint + 3 ]
	;	leave significant bits
	and al, 011b
	call bp

	; "PCI" "BDF" from stack in ecx
	push bp
	mov bp, sp
%define uBytesForPushBp 2
%define uBytesPerRegInPushaw 2
%define uCntRegsUntilAx 7
%define uCntRegsUntilDx 2
%define uCntRegsUntilBx 4
%define uFrame 1
	mov ax, word [ bp + uBytesForPushBp + ( uBytesPerRegInPushaw * uCntRegsUntilBx ) * uFrame ]
	pop bp
	push bx
	mov bx, ax
	mov ecx, ebx
	pop bx
	; ;	print the full "BDF"
	; macro_printString "Pci BusDevFunc: "
	; mov eax, ecx
	; call bp
	;	output "BDF" in parts
	macro_printString "Pci Bus: "
	mov eax, ecx
	shr eax, 24
	;	remove the ??? bit
	and al, 01111111b
	movzx eax, al
	call bp
	macro_printString "Pci Device: "
	mov eax, ecx
	shr eax, 8
	movzx eax, al
	call bp
	macro_printString "Pci Function: "
	mov eax, ecx
	movzx eax, al
	call bp

	; ; "USBBASE" by "BDF" from "PCI"
	; macro_printString "USBBASE: "
	; ;	address port, high byte
	; mov	dh, 0x0C
	; ;	full "BDF" is calculated
	; mov eax, ecx
	; add al, c_uIdxPciConfigurationData_dwBaseAddr1
	; ;	write device parameters to the address port
	; mov	dl, 0xF8
	; out dx, eax
	; ;	i know the port index in advance
	; mov	dl, 0xFC + macro_maskPciAccess( c_uIdxPciConfigurationData_dwBaseAddr1 )
	; in eax, dx ; eax = USBBASE
	; call bp

	; mov al, 0x01 ; some-smiley
	; mov ah, 0x0E
	; int 0x10

.hang:
	hlt
	jmp .hang
; -------------------------------------------------------------------------------------------------
; Helper for line output macro
; in: "ax" address of a null-terminated string
.othersectors$helper$printString:
	pusha
	mov si, ax
.loop:
		lodsb
		cmp al, 0
		je .done
		mov ah, 0x0E
		int 0x10
		jmp .loop
.done:
	popa
	ret

; Padding with sectors marked to match the size or geometry of the floppy image so that the boot sector works under the HDD
%include "BootTime/markedSectorsAndFddSize.inl"
