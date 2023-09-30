; dvc/Pci/Usb/Ehci/find/pio/callAfterFound.asm - calling a certain function after finding the "EHCI" controller
%ifndef def_dvc$Pci$Usb$Ehci$find$pio$callAfterFound$_once ; #pragma once
%define def_dvc$Pci$Usb$Ehci$find$pio$callAfterFound$_once

%include "dvc/Pci/Usb/Ehci/find/pio/common.inc"

; Config
;	some function
;		debug call to dump the contents of the eax register
; %define def_dvc$Pci$Usb$Ehci$find$pio$callAfterFound$pFunc bp
;		scan device address and read sectors
%define def_dvc$Pci$Usb$Ehci$find$pio$callAfterFound$pFunc dvc$Pci$Usb$Ehci$scanDeviceAddrAndReadX$just

; -------------------------------------------------------------------------------------------------
; -//- 
;	@insp dvc\Pci\Usb\Ehci\find\pio\firstOnBus0.asm
;	@insp https://bugzilla.redhat.com/show_bug.cgi?id=1390329
;	@insp https://patchew.org/QEMU/20200225015026.940-1-miaoyubo@huawei.com/
;	@insp https://github.com/qemu/qemu/blob/master/docs/pcie.txt
;		to add a new bus to "qemu": "-device pcie-root-port,addr=1f.0,id=pcie_bus -device virtio-scsi-pci,bus=pcie_bus"
;		or explicitly set the bus number to 0x33: "-M q35 -device pxb-pcie,id=my_pci_7,bus_nr=0x33,bus=pcie.0,addr=0x9 -device ioh3420,id=my_root_port1"
; out: cx != 0 means search success
; registers are not saved
dvc$Pci$Usb$Ehci$find$pio$callAfterFound$_unsafe_:

	; Let's prepare "Qh" and "qTd", you can call it only once
	mov di, c_ddAddrAsyncListInLoMem$_beg ; 3 bytes
	%include "dvc/Pci/Usb/Ehci/asyncList/dataStruc/realModeAddr_segDs0/attachedSglQh/init.asm"
%ifdef def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPatch_ExtendedBootSignature
	; Patch the former "ExtendedBootSignature" before launching, it should be ".bCBWCBLength"
	;	i can’t reach through "di", the offset is greater than 0x1F even if I place the "Qh+qTd" stuff back to back ( 0x7C00 - ( 0x60 + 0x40 ) )
;	mov byte [ g_lpScsiCmd$readX$_beg.bCBWCBLength ], 6 ; 5 bytes
%endif

	; Let's calculate the "BDF" base in advance, then increase the "loopFunction" at each step, which now cannot be interrupted
	;	in the terminology "SeaBios" is called "BDF", probably because = bus+dev+fn
	;	there can be a total of 256 tires, from zero to 255
	; push byte 0x80 ; 2
	; dec sp ; 1
	; dec sp ; 1
	; dec sp; 1
	; ; ; sub sp, 3
	; pop ebx ; 2 ; 7 bytes in total
	mov ebx, ( 0x80000000 + ( 0 << 16 ) ) ; 6 bytes
	; Address port, high byte
	mov	dh, 0x0C
	; ?TODO(alex): when the bus search is ready, "cmp" will be on "ebx" and then "cx" can be removed
	; There are 32 devices in total and they have 8 functions, and another 255 buses. Doesn't fit into the word 0x00010000, but zero is fine
	xor cx, cx
	; Read cycle of "Pci" ports on buses
	.loop$BusDevFunc: ; {
		; We calculate the full BDF
		mov eax, ebx
		add al, c_uIdxPciConfigurationData_bUnused_bProgIface_wPnpDeviceTypeCodes
		; write device parameters to the address port
		mov	dl, 0xF8
		out dx, eax
		; I know the port index in advance
		mov	dl, 0xFC + macro_maskPciAccess( c_uIdxPciConfigurationData_bUnused_bProgIface_wPnpDeviceTypeCodes )
		; Read from the port. For example, 0x0C0320** - the least significant byte will be redundant (revision ID). You can read "dword" to -- Example: 0xFF0C0320. There will be a small read error and 0xFF will be read
		in eax, dx

		; ; Trace. Output of all valid ones, and at the beginning of the BDF
		; cmp eax, -1
		; je .Cond$Invalid;
			; push eax
			; mov eax, ebx
			; call bp
			; pop eax
			; call bp
		; .Cond$Invalid:

		; We look only at "EHCI", ah = "bProgIface"
		cmp ah, 0x20
		; ; We look only at "xHCI", ah = "bProgIface"
		; cmp ah, 0x30
		jne .continue_$BusDevFunc;
		shr eax, 16
		; We look only at "USB", ah = Subtype, al = Type
		cmp ax, 0x0C03
		jne .continue_$BusDevFunc;
			; We calculate the full BDF
			mov eax, ebx
			; ; Trace. I want to peek BDF
			; call bp

			add al, c_uIdxPciConfigurationData_dwBaseAddr1
			; write device parameters to the address port
			mov	dl, 0xF8
			out dx, eax
			; I know the port index in advance
			mov	dl, 0xFC + macro_maskPciAccess( c_uIdxPciConfigurationData_dwBaseAddr1 )
			in eax, dx ; eax = USBBASE

			; ; Let's try hardwareSecondX, the first is 0xEC61A000
			; cmp eax, 0xEC619000
			; jne .continue_$BusDevFunc

			; ; Trace. Release3. Print USBBASE
			; call bp

%ifdef def_dvc$Pci$Usb$Ehci$diag$bAllow_storeImportantAddr
			; Save USBBASE for diagnostic output
			mov [ c_localVar$diag$wAddr_dwUSBBASE ], eax
			mov [ c_localVar$diag$wAddr_dwBDF ], ebx
%endif
			; Call (you can overwrite all registers except: ebx(bX,bl,bh), cx(ecx,cl,ch), dh(dx,edx)
			call def_dvc$Pci$Usb$Ehci$find$pio$callAfterFound$pFunc

		.continue_$BusDevFunc:

		; Let's shift the BDF base (will not go beyond the word, 0x20*0x08*0x0100=0x00010000)
		inc bh
		; If reset as a result of increment to 0
		jnz .Cond$notOverflow;
			;	next bus
			add ebx, ( 1 << 16 )
		.Cond$notOverflow:

	loop .loop$BusDevFunc ; }

%ifndef inline_me_
	ret
%endif

dvc$Pci$Usb$Ehci$find$pio$callAfterFound$_end:
%endif ; def_dvc$Pci$Usb$Ehci$find$pio$callAfterFound$_once

; Here is a list of commands to view the staff
%if 0
; REM 	help
	powershell -ep Bypass QemuExecHmp help info
; REM 	see if the device is inserted
	powershell -ep Bypass QemuExecHmp info usb
; REM 	view information on devices
	cls & powershell -ep Bypass QemuExecHmp info qtree
	cls & powershell -ep Bypass QemuExecHmp info qdm
%endif
