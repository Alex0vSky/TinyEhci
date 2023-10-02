; Copyright 2023 Alex0vSky (https://github.com/Alex0vSky)
; dvc/Pci/Usb/Ehci/common.inc - working with USB type Ehci, constants
; description of field bits in comments from dvc\Pci\Usb\Ehci\directHardware\diag.asm

%ifndef def_dvc$Pci$Usb$Ehci$common$_once ; #pragma once
%define def_dvc$Pci$Usb$Ehci$common$_once

%include "dvc/Pci/Usb/Ehci/asyncList/stdDvcReq/common.inc"
%include "dvc/Pci/Usb/Ehci/asyncList/directAcsBlkCmd/common.inc"

; Host Controller Capability Registers (EHCI Spec 2.3)
;	offsets from the beginning of "USBBASE" to each "CapabilityRegisters" field
;		CAPLENGTH/CapabilityRegistersLength
c_cIdxCapReg_cCAPLENGTH						equ ( 0x00 )
;		HCIVERSION
c_cIdxCapReg_wHCIVERSION					equ ( 0x02 )
;		HCSPARAMS/StructuralParameters
c_cIdxCapReg_dwHCSPARAMS					equ ( 0x04 )
;		HCCPARAMS/CapabilityParameters
c_cIdxCapReg_dwHCCPARAMS					equ ( 0x08 )
;		HCSP-PORTROUTE
c_cIdxCapReg_dqHCSP_PORTROUTE				equ ( 0x0C )

; EHCI Extended Capabilities
;	offsets from the beginning of the "EECP/ExtendedCapabilitiesPointer" to each "EhciExtendedCapabilities" field
;	all registers are 32bit
;		USBLEGSUP
%define def_cIdxEhciExtCap_dwUSBLEGSUP 4*0
;		USBLEGCTLSTS
%define def_cIdxEhciExtCap_dwUSBLEGCTLSTS 4*1

; Host Controller Operational Registers (EHCI Spec 2.3)
;	offsets from the beginning of "USBBASE+CAPLENGTH" to each field "OperationalRegisters"
;	all registers are 32bit
c_cIdxOperReg_dwUSBCMD						equ ( 4*0 )
;		USBSTS/UsbStatusRegister
c_cIdxOperReg_dwUSBSTS 						equ ( 4*1 )
; ;		USBINTR
%define def_cIdxOperReg_ddUSBINTR 4*2
;		"FRINDEX/FrameIndexRegister", this is due to the way data is passed to the "FrameList"
%define def_cIdxOperReg_ddFRINDEX 4*3
;		CTRDSSEGMENT
%define def_cIdxOperReg_ddCTRDSSEGMENT 4*4
;		PERIODICLISTBASE/PeriodicFrameListBaseAddressRegister
%define def_cIdxOperReg_ddPERIODICLISTBASE 4*5
;		"ASYNCLISTADDR/AsynchronousListAddress", address "asynchronousList"
c_cIdxOperReg_dwASYNCLISTADDR				equ ( 4*6 ) ; 0x18
;			skip "reserved"
;		CONFIGFLAG
c_cIdxOperReg_dwCONFIGFLAG					equ ( 4*16 )
;		PORTSC
%define def_cIdxOperReg_dwPORTSC 4*17



; For stop command, under "RS"
c_bmStop									equ ( 1 << 0 )
; To wait for a stop command to be executed, under "HCHalted"
c_bmHcHalted								equ ( 1 << 12 )
; For the "reset" command, under "HCRESET"
c_bmReset									equ ( 1 << 1 )

; To change "ownership"
c_uIdxUSBLEGSUP_bOsOwnershipByte			equ ( 0x03 )
c_uIdxUSBLEGSUP_bBiosOwnershipByte			equ ( 0x02 )
c_uIdxUSBLEGSUP_wOwnershipsWord				equ ( 0x02 )

; Operation Register Size
c_uSizeOperationalRegisters					equ ( 0x44 )



; ; -(obsolete) 16-bit real mode segment in which "asynchronousList"
; %define def_dwSegmAsyncListInLoMem 0x3000
; ; ; Address "linear" where "asyncList" begins
; ; %ifndef c_ddAddrAsyncListInLoMem$_beg
	; ; %define c_ddAddrAsyncListInLoMem$_beg ( def_dwSegmAsyncListInLoMem << 4 )
; ; %endif

%ifndef def_dvc$Pci$Usb$Ehci$attachedSglQh$bAllow
	; Offset, relative to the segment, of the beginning of the first "QH". In [.pdf] on 64bit, the last byte number is 0x43. Alignment must be in memory at 0x20(32) bytes
	; c_dwOffset_Qh0$_beg equ ( 0x60*0 )
	; c_dwOffset_Qh0$_beg							equ ( 0x80*0 )
	; c_dwOffset_Qh0$_beg							equ ( 0x60*0 )
	c_dwOffset_Qh0$_beg							equ ( 0x1000*0 )
	; Address "linear" where "asynchronousList" begins, first "QH/QueueHead"
	c_ddAddrAsyncListInLoMem_Qh0				equ ( c_ddAddrAsyncListInLoMem$_beg + c_dwOffset_Qh0$_beg )

	; The offset, relative to the segment, of the beginning of the second "QH", in qemu it is 0x80. Alignment must be in memory at 0x20(32) bytes
	; c_dwOffset_Qh1$_beg equ ( 0x60*1 )
	; c_dwOffset_Qh1$_beg							equ ( 0x80*1 )
	; c_dwOffset_Qh1$_beg							equ ( 0x60*1 )
	c_dwOffset_Qh1$_beg							equ ( 0x1000*1 )
	; The address is "linear" where the second is "QH/QueueHead". Alignment must be in 32 byte memory [.pdf]
	c_ddAddrAsyncListInLoMem_Qh1				equ ( c_ddAddrAsyncListInLoMem$_beg + c_dwOffset_Qh1$_beg )

	; The offset, relative to the segment, of the beginning of the third "QH", in qemu it is 0x80. Alignment must be in memory at 0x20(32) bytes
	; c_dwOffset_Qh2$_beg equ ( 0x60*1 )
	; c_dwOffset_Qh2$_beg							equ ( 0x80*2 )
	; c_dwOffset_Qh2$_beg							equ ( 0x60*2 )
	c_dwOffset_Qh2$_beg							equ ( 0x1000*2 )
	; The address is linear where the second one is "QH/QueueHead". Alignment must be in 32 byte memory [.pdf]
	c_ddAddrAsyncListInLoMem_Qh2				equ ( c_ddAddrAsyncListInLoMem$_beg + c_dwOffset_Qh2$_beg )

	; The offset, relative to the segment, of the start of "qTD/QueueElementTransferDescriptor". In [.pdf] on 64bit, the last byte number is 0x33. Alignment must be in memory at 0x20(32) bytes
	; c_dwOffset_qTd$_beg equ ( 0x60*2 )
	;	-(then I won’t be able to reset the terminate bit) we place "qTD" in memory, the beginning of which is aligned to 0x100, so that only one byte can be used to write it
	;	0x60*2=0xC0 it means it won’t be overwritten if there are 64-bit hardware
	; c_dwOffset_qTd$_beg equ ( 0x100 )
	; c_dwOffset_qTd$_beg							equ ( 0x300 )
	c_dwOffset_qTd$_beg							equ ( ( 0x1000*3 ) + 0x1000*0 )
	; Address "linear" where "qTD/QueueElementTransferDescriptor" begins
	c_ddAddr_qTd$_beg							equ ( c_ddAddrAsyncListInLoMem$_beg + c_dwOffset_qTd$_beg )
	; ; Offset, relative to the segment, of the beginning of the second "qTD"
	; ; c_dwOffset_qTd1$_beg						equ ( 0x400 )
	; c_dwOffset_qTd1$_beg							equ ( ( 0x1000*3 ) + 0x1000*1 )
	; ; Address linear where "qTD/QueueElementTransferDescriptor" begins
	; c_ddAddr_qTd1$_beg							equ ( c_ddAddrAsyncListInLoMem$_beg + c_dwOffset_qTd1$_beg )
%else
	; The offset, relative to the segment, of the beginning of the only "QH" connected to "Qh" from the BIOS. In [.pdf] on 64bit, the last byte number is 0x43. Alignment must be in memory at 0x20(32) bytes
	c_dwOffset_QhSgl$_beg							equ ( 0x60*0 )
	; Address "linear" where the asynchronousList begins, the first "QH/QueueHead"
	c_ddAddrAsyncListInLoMem_Qh1					equ ( c_ddAddrAsyncListInLoMem$_beg + c_dwOffset_QhSgl$_beg )

	; The offset, relative to the segment, of the start of "qTD/QueueElementTransferDescriptor". In [.pdf] on 64bit, the last byte number is 0x33. Alignment must be in memory at 0x20(32) bytes
	c_dwOffset_qTd$_beg								equ ( 0x60*1 )
	; Address "linear" where "qTD/QueueElementTransferDescriptor" begins
	c_ddAddr_qTd$_beg								equ ( c_ddAddrAsyncListInLoMem$_beg + c_dwOffset_qTd$_beg )

%endif

; -(obsolete)TODO(alex): rename this "BufferPagePonterList" because it is just an offset to the address where the "IN" transfer usually goes
; -(obsolete) Offset, relative to the segment, of the start of "BufferPagePonterList". Alignment to one byte [.pdf#"The buffer may start on any byte boundary"]
; %define def_dwOffset_qTd_BufferPagePonterList$_beg ( 0x60*2 + 0x40 )
%define def_dwOffset_qTd_BufferPagePonterList$_beg ( 0x1000 )
; ; Address "linear" where "BufferPagePonterList" begins
; c_dwAddr_qTd_BufferPagePonterList			equ ( c_ddAddrAsyncListInLoMem$_beg + def_dwOffset_qTd_BufferPagePonterList$_beg )

; Offset from the beginning of "QH" at which the "HorizPtr" field is located
c_dwOffset_Qh__HorizPtr						equ ( 4*0 )
; Offset from the beginning of the QH at which the "EndpointCharacteristics" field is located
c_dwOffset_Qh__EndpointCharacteristics		equ ( 4*1 )
; Offset from the beginning of the QH at which the "Current_qTD_Pointer" field is located
c_dwOffset_Qh__qTd_CurrentPointer			equ ( 4*3 )
; Offset from the beginning of the QH at which the "Next_qTD_Pointer" field is located
c_dwOffset_Qh__qTd_NextPointer				equ ( 4*4 )
; Offset from the beginning of the QH at which the "qTD Token" field is located in the overlay
c_dwOffset_Qh__transferOverlay_qTdToken		equ ( 4*6 )
; Offset from the beginning of the QH at which the "transferOverlay_BufferPagePonterList" field is located
c_dwOffset_Qh__transferOverlay_Buf			equ ( 4*7 )
; Offset from the beginning of the qTD at which the "Token" field is located
c_dwOffset_qTd__Token						equ ( 4*2 )
; Offset from the beginning of the qTD at which the "BufferPagePonterList[Page0]/pointerToBuffer" field is located
c_dwOffset_qTd__Buf							equ ( 4*3 )


; TODO(alex): preferably taken from the descriptor

; Minimum possible "MaximumPacketLength"
; c_Qh_endpointCh_cMaximumPacketLength		equ ( 0x08 )
; Such a fromHardware in "Qh" from "ASYNCLISTADDR"
; c_Qh_endpointCh_cMaximumPacketLength		equ ( 0x400 )
; Such a fromHardware in the flash descriptor
c_Qh_endpointCh_cMaximumPacketLength		equ ( 0x200 )

; Tried this "DeviceAddr" in qemu and it works
c_Qh_endpointCh_bmDeviceAddr 				equ ( 0x01 )
; Hardware hub
; c_Qh_endpointCh_bmDeviceAddr 				equ ( 0x01 )
; Controller from under the hardware hub
; c_Qh_endpointCh_bmDeviceAddr 				equ ( 0x02 )

; The maximum possible number of sectors to read through one "qTd"
c_dvc$Pci$Usb$Ehci$uMaxCntSectorsPer_qTd	equ ( 5 * 8 )
; The maximum possible number of bytes for reading via "Scsi" through one "qTd"
c_dvc$Pci$Usb$Ehci$uMaxBytesPer_qTd			equ ( c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$Scsi$uLogicalUnitBytes * c_dvc$Pci$Usb$Ehci$uMaxCntSectorsPer_qTd )
; Offset to the outermost sector of the maximum possible for one "qTd"
c_dvc$Pci$Usb$Ehci$wLastSector				equ ( c_dvc$Pci$Usb$Ehci$uMaxBytesPer_qTd - c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$Scsi$uLogicalUnitBytes )

%endif ; def_dvc$Pci$Usb$Ehci$common$_once
