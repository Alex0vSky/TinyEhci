; C:\Prj\HomoT\step3_usb\config.inc - configuration

; Screen display method.
;	use BIOS interrupts.
%define def_$io$Tty$bPrintChar_Bios

; Change the default output config to "tty".
%define def_$io$Tty$UsingPrintChar$bOmitDefaut
;	leave only the output of double words in hex format.
%define def_$io$Tty$UsingPrintChar$bOnly_hexDword
;	automatically add a new line after each hexadecimal output.
%define def_$io$Tty$UsingPrintChar$bAutoCrLf_onHex

; Place the "read6" command code in the system table that accompanies the bootsector.
%define def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPlace_read6
; Place the command code "StandardUsbRequest GET_DESCRIPTOR+CONFIGURATION" in the system table that accompanies the bootsector.
%define def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPlace_stdUsbReq
; Locate the "GDT" structure for protected mode in the system table that accompanies the bootsector.
%define def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPlace_lpDescrGdt
; Use "GDT" for "bigUnrealMode" where the first record from the table (not used by the process) is filled with random data.
%define def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPlace_bigUnrealModeTrashFirstEntry

; ; Provide the ability to save variables for diagnostics.
; %define def_dvc$Pci$Usb$Ehci$diag$bAllow_storeImportantAddr

; Use a single "Qh" that connects to the "Qh" created in the BIOS.
%define def_dvc$Pci$Usb$Ehci$attachedSglQh$bAllow
; Insert the signature into the output image.
%define def_$BootTime$markedSectorsAndFddSize$bSignature
; Take the endpoint numbers (Endpt) from the configuration descriptor and insert them into the code in place of the default ones - 0x1E(30) bytes.
%define def_dvc$Pci$Usb$Ehci$scanDeviceAddrAndReadX$bPasteEndpt

; Testing the bootrecord.
; %define def_testBootrecord

; Numerical ID of the flash drive being created with a boot sector, no more than a byte (max 255). It is needed to accurately distinguish one flash drive with a boot sector from another.
c_cMsdId	equ ( 1 )

; TODO(alex): to a separate file.
; The address "linear" where the asynchronousList "echi" begins.
c_ddAddrAsyncListInLoMem$_beg							equ ( 0x500 )
;	size of 64bit "Qh" + size of 64bit "qTd" and both aligned at 0x20.
; c_ddAddrAsyncListInLoMem$_beg							equ ( 0x7C00 - ( 0x60 + 0x40 ) )

; The address where the results of the "Standard Usb Request" "Standard Device Request" are written.
c_dvc$Pci$Usb$Ehci$asyncList$stdDvcReq$wDstAddr			equ ( 0x7E00 )
; Address where sectors with flashes are written (or other data after)
c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$wDstAddr	equ ( 0x8000 )


; Offset constant for shorthand notation.
c_qTdToken equ ( c_dwOffset_qTd$_beg + c_dwOffset_qTd__Token )
c_qTdBuf0 equ ( c_dwOffset_qTd$_beg + c_dwOffset_qTd__Buf )



; Global variables on the stack.
;	the base address of the memory space "bottom" filled with zeros where I throw my variables.
c_$ZeroFilled$wBaseAddr equ ( 0x7C00 )
;		helper index "allocation".
%assign def_$config$wNextLocalValue ( 0 )
;	a memory cell of 16 bytes filled with zeros, where there will be a protected mode table "Gdt" for "Big Unreal Mode".
%assign def_$config$wNextLocalValue ( ( 16 ) + def_$config$wNextLocalValue )
c_localVar$dvc$Cpu$bigUnrealMode$zeroidFirstEntry$wAddrGdt equ ( c_$ZeroFilled$wBaseAddr - def_$config$wNextLocalValue )

; ;	A memory cell of size "dword" filled with zeros, where "USBBASE" comes from.
; %assign def_$config$wNextLocalValue ( ( 8 ) + def_$config$wNextLocalValue )
; c_localVar$diag$wAddr_dwUSBBASE equ ( c_$ZeroFilled$wBaseAddr - def_$config$wNextLocalValue )
; ;	A memory cell of size "dword" filled with zeros, where "BDF" comes from.
; %assign def_$config$wNextLocalValue ( ( 8 ) + def_$config$wNextLocalValue )
; c_localVar$diag$wAddr_dwBDF equ ( c_$ZeroFilled$wBaseAddr - def_$config$wNextLocalValue )

; ; ;	A filled memory location of size "dword", where "OperationalRegisters" comes from.
; ; %assign def_$config$wNextLocalValue ( ( 8 ) + def_$config$wNextLocalValue )
; ; %define def_$diag$several$wAddr_dwOperationalRegisters ( c_$ZeroFilled$wBaseAddr - def_$config$wNextLocalValue )
; ;	A memory cell of 1 byte filled with zeros, where "ebpb_drive_number" will be.
; %assign def_$config$wNextLocalValue ( ( 1 ) + def_$config$wNextLocalValue )
; c_localVar$cEbpbDriverNumber equ ( c_$ZeroFilled$wBaseAddr - def_$config$wNextLocalValue )
; ;	A 13-byte memory cell filled with zeros, where the "CSW" of the "USB Bulk Only" protocol comes.
; %assign def_$config$wNextLocalValue ( ( 13 ) + def_$config$wNextLocalValue )
; c_localVar$dvc$Pci$Usb$Ehci$asyncList$transport$status$lpCSW equ ( c_$ZeroFilled$wBaseAddr - def_$config$wNextLocalValue )

; ;	A memory cell of 1 byte in size filled with zeros, where there will be a test attempt counter.
; %assign def_$config$wNextLocalValue ( ( 1 ) + def_$config$wNextLocalValue )
; c_localVar$cCntTry equ ( c_$ZeroFilled$wBaseAddr - def_$config$wNextLocalValue )

; ;	A memory cell of 1 byte in size filled with zeros, where there will be a certain test flag.
; %assign def_$config$wNextLocalValue ( ( 1 ) + def_$config$wNextLocalValue )
; c_localVar$bSome equ ( c_$ZeroFilled$wBaseAddr - def_$config$wNextLocalValue )

; ;
