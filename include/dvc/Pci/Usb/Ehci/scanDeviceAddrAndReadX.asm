; dvc/Pci/Usb/Ehci/scanDeviceAddrAndReadX.asm - scan "DeviceAddr" of the "EHCI" controller and read sectors from there
%ifndef def_dvc$Pci$Usb$Ehci$scanDeviceAddrAndReadX$_once ; #pragma once
%define def_dvc$Pci$Usb$Ehci$scanDeviceAddrAndReadX$_once

; Config
;	you need to do "IN" on the same "Qh" as "SETUP"
%ifndef def_dvc$Pci$Usb$Ehci$attachedSglQh$bAllow
	c_dwOffset_QhSetupIn equ c_dwOffset_Qh1$_beg
%else
	c_dwOffset_QhSetupIn equ c_dwOffset_QhSgl$_beg
%endif

; -------------------------------------------------------------------------------------------------
; -//- 
; in: eax USBBASE
; in: dI = asynchronousList
; out: does not return from here if reading the required data is successful
dvc$Pci$Usb$Ehci$scanDeviceAddrAndReadX$just:
	pusha

	; Let's prepare frequently used data. ds:bX addresses the beginning of a segment with structures
	;	instructions like "mov word [ bX + imm ], imm8" are shorter by one byte than instructions like ""mov word [ moffs ], imm8". imm8: A 8-bit immediate data field
	;	instructions like "mov word [ bX ], imm8" are shorter by another byte
	mov si, ( c_ddAddrAsyncListInLoMem$_beg + c_dwOffset_qTd$_beg + c_dwOffset_qTd__Buf )
	mov bx, ( c_ddAddrAsyncListInLoMem$_beg + c_dwOffset_qTd$_beg + c_dwOffset_qTd__Token )
	; Create data structures for work in memory and attach them to the existing "Qh(HeadOfReclamationList)" from the BIOS
	;	now "eax" will contain the address "OperationalRegisters". The calculation is that in USBBASE only bit[31:8] are significant, so there is quite a bit of space per byte
	add al, byte [ eax + c_cIdxCapReg_cCAPLENGTH ]
	mov eax, dword [ eax + c_cIdxOperReg_dwASYNCLISTADDR ]
	%include "dvc/Pci/Usb/Ehci/asyncList/dataStruc/realModeAddr_segDs0/attachedSglQh/setHorizLinkPtr.asm"

	; Prepare for iterations
	; QhSgl_endpointCharacteristics
	;	bit[6:0] DeviceAddress, zero will be in "bit[7] InactiveOnNextTransaction" for non-HiSpeed
	mov byte [ di + c_dwOffset_QhSetupIn + c_dwOffset_Qh__EndpointCharacteristics ], 0
%ifndef def_dvc$Pci$Usb$Ehci$attachedSglQh$bAllow
	mov byte [ di + c_dwOffset_Qh2$_beg + c_dwOffset_Qh__EndpointCharacteristics ], 0
%endif

	; We are looking for "DeviceAddress" so that the response is "controller" and not "hub"
	.loop$EnumDeviceAddr: ; {
		; ----------------
		; Setup transfer
		; Let's place the "pointerToBuffer" in "BufferPagePonterList[Page0]" from where to read the command bytes

		mov word [ si ], ( g_lpStdDvcReq$GetAnyCfgDescr$_beg )

		; ; I'll try to copy the command to a new memory location
; newaddr2 equ 0x6000
		; pusha
		; mov cx, ( g_lpStdDvcReq$GetAnyCfgDescr$_end - g_lpStdDvcReq$GetAnyCfgDescr$_beg )
		; mov si, ( g_lpStdDvcReq$GetAnyCfgDescr$_beg )
		; mov di, 0x6000
		; rep movsb
		; popa
		; mov word [ si ], ( newaddr2 )

		; ; patch before launch
		; mov word [ g_lpStdDvcReq$GetAnyCfgDescr$_beg ], 0x0680

		; qTD0, PID = SETUP
		;	qTD_Token
		%xdefine def_dwCalculatedVal 0
		;		bit[30:16] TotalBytesToTransfer
		%xdefine def_dwCalculatedVal def_dwCalculatedVal|( ( ( g_lpStdDvcReq$GetAnyCfgDescr$_end - g_lpStdDvcReq$GetAnyCfgDescr$_beg ) ) << 16 )
		;		bit[11:10] CERR Error counter, allows you to respond to erroneous "DeviceAddress"
		%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 11b << 10 )
		;		bit[9:8] PID Code (SETUP generates token 2DH [ehci-specification-for-usb.pdf] I think this signature is about debugging)
		%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 010b << 8 )
		;		bit[7:0] Status = active [ehci-specification-for-usb.pdf#4.10.3]
		%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 0x80 )
		;			set
		mov dword [ bx ], ( def_dwCalculatedVal )
		;	QH1_endpointCharacteristics - filled during initialization
		; ; Trace. Output the buffer before starting
		; mov eax, [ si ]
		; call bp
		; ;
		; "Launch" EHCI
		mov word [ di + c_dwOffset_QhSetupIn + c_dwOffset_Qh__qTd_NextPointer ], c_ddAddr_qTd$_beg
		; We are waiting for the end of "work3_1" EHCI, this is resetting "Status active" to "qTD_Token"
%ifndef realHardware_
		; Getting the current timer value in "ax + 2", expecting less than two is dangerous, it may immediately increase by one and there will be no slip
		mov ax, word [ 0x046C ]
		inc ax
		inc ax
%endif
		.loopWait$SetupTransfer$ordinary:
%ifndef realHardware_
			cmp word [ 0x046C ], ax
			jnb .next$DeviceAddr;
%endif
			; On hardware (not qemu) it will be 0x48 if the "Device Address" is non-existent, the full value is qTD_Token=0x80080248
			test byte [ bx ], 0x80
		jnz .loopWait$SetupTransfer$ordinary;
		; ; Trace. Release3. Print qTD_Token
		; mov eax, [ bx  ]
		; call bp ; 0x80000E00
		; ;
		; The condition for successful completion of the transport is a successful "Status"
		test byte [ bx ], 0xFF
		jnz .next$DeviceAddr;

%ifndef realHardware_
		; tmp. sleep
		call bp
%endif
		; ; Trace. Print buffer from the overlay
		; mov eax, [ di + c_dwOffset_QhSetupIn + c_dwOffset_Qh__transferOverlay_Buf ]
		; call bp
		; ;

		; ----------------
		; Data transport setup
		; Let’s indicate where to write the data, EHCI can detect "overlap" and "C_Page" will grow
		mov word [ si ], ( ( c_dvc$Pci$Usb$Ehci$asyncList$stdDvcReq$wDstAddr ) + 0x1000*0 )
		; qTD0, PID = IN
		;	qTD_Token
		%xdefine def_dwCalculatedVal 0
		;		bit[30:16] TotalBytesToTransfer
		%xdefine def_dwCalculatedVal def_dwCalculatedVal|( c_dvc$Pci$Usb$Ehci$asyncList$stdDvcReq$GetAnyCfgDescr$xbTotalBytesToTransfer << 16 )
		;		bit[11:10] CERR Error counter, allows you to respond to erroneous "DeviceAddress"
		%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 11b << 10 )
		;		bit[9:8] PID Code (IN generates token 69H [ehci-specification-for-usb.pdf] I think this signature is about debugging)
		%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 01b << 8 )
		;		bit[7:0] Status = active [ehci-specification-for-usb.pdf#4.10.3]
		%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 0x80 )
		;			set
		mov dword [ bx ], ( def_dwCalculatedVal )
		; "Launch" EHCI
		mov word [ di + c_dwOffset_QhSetupIn + c_dwOffset_Qh__qTd_NextPointer ], c_ddAddr_qTd$_beg
		; We are waiting for the end of work3_2 EHCI, this is resetting "Status active" to "qTD_Token"
		.loopWait$SetupDataTransfer$ordinary:
			test byte [ bx ], 0x80
		jnz .loopWait$SetupDataTransfer$ordinary;
		; ; Trace. Release3. Print qTD_Token
		; mov eax, [ bx  ]
		; call bp ; qemu=0x80200D00, hardware=0x00400D40
		; ;
		; ; ; Trace. Print the beginning of the buffer - the descriptor is there
		; ; mov eax , [ ( c_dvc$Pci$Usb$Ehci$asyncList$stdDvcReq$wDstAddr ) ]
		; ; call bp ; qemu=0x00200209, hardware=0x00190209
		; The condition for successful completion of the transport is a successful "Status"
		test byte [ bx ], 0xFF
		jnz .next$DeviceAddr;

%ifndef realHardware_
		; tmp. sleep
		call bp
%endif

		; Descriptor parsing
		pusha
		mov sI, c_dvc$Pci$Usb$Ehci$asyncList$stdDvcReq$wDstAddr
		xor bX, bX
		xor cx, cx
		.loop$untilLastElemBuf$parse: ; {

			; Field "bLength" [*.pdf#Table 9-21. Standard Configuration Descriptor]
			lodsb
			;	exit if end. I hope the memory was filled with zeros before the operation began
			test al, al
			jz .break_$loop$untilLastElemBuf$parse
			;	let's immediately calculate the offset of the occurrence trace
			mov bl, al
			dec bX
			dec bX
			; Field "bDescriptorType"
			lodsb
			;	to the next entry
			add sI, bX

			;	we are looking for when "bDescriptorType" is 4, this is INTERFACE [*.pdf#Table 9-6. Descriptor Types]
			cmp al, 4
			jne .Cond$notInterface;
				; Field "bInterfaceClass". I think it’s enough to check it for "MASS STORAGE" class
				cmp byte [ sI - 9 + 5 ], 0x08
				jne .Cond$notMsd;
					inc cx
					jmp .continue_$loop$untilLastElemBuf$parse;
				.Cond$notMsd:
			.Cond$notInterface:

			; Save 0x1E(30) bytes
%ifdef def_dvc$Pci$Usb$Ehci$scanDeviceAddrAndReadX$bPasteEndpt
			;	we are looking for when "bDescriptorType" is 5, this is ENDPOINT [*.pdf#Table 9-6. Descriptor Types]
			cmp al, 5
			jne .Cond$notEndpoint; ; {
				; Field "bmAttributes" = "ah". bit[1:0] TransferType, 010b=Bulk, this means that in "bEndpointAddress" the "bit[7] Direction" bit will be valid
				; Field "bEndpointAddress" = "al". 0x00000081 is "IN" and "Endpt" = 001b = 0x01, 0x00000002 is "OUT" and "Endpt" = 010b = 0x02
				mov ax, word [ sI - 7 + 2 ]
				test ah, 010b
				jz .Cond$TransferType$notBulk; ; {

					; We'll set the bits right now
					;	bit[13:12] EndpointSpeed = 010b = HiSpeed (0x00002000)
					or al, ( 010b << ( 12 - 8 ) )
					;	bit[7] Direction. 0 = OUT endpoint, 1 = IN endpoint
					;	reset bit 7 (in the high byte), and if it was true, then write it to the "CF" flag. Only the significant bits "Endpt" will remain
					btr ax, 7
					; Write this "Endpt" byte at the global label into the code, which will now be considered a self-modifying
					jc .Cond$Direction$IN;
						mov [ ..@g_p$SelfModif$BulkOutEndpoint + 3 ], al
						jmp .Cond$Direction$_end;
					.Cond$Direction$IN:
						mov [ ..@g_p$SelfModif$BulkInEndpoint + 3 ], al
					.Cond$Direction$_end:

				.Cond$TransferType$notBulk: ; }
%endif ; def_dvc$Pci$Usb$Ehci$scanDeviceAddrAndReadX$bPasteEndpt

			.Cond$notEndpoint:  ; }

			.continue_$loop$untilLastElemBuf$parse:

		cmp sI, c_dvc$Pci$Usb$Ehci$asyncList$stdDvcReq$wDstAddr + c_dvc$Pci$Usb$Ehci$asyncList$stdDvcReq$GetAnyCfgDescr$xbTotalBytesToTransfer
		jb .loop$untilLastElemBuf$parse ; }
		.break_$loop$untilLastElemBuf$parse:

		; Checking that the current "DeviceAddr" received the "MSD" descriptor and not the "hub" descriptor, for example
		test cx, cx
		;	does not affect flags
		popa
		jz .Cond$notFoundMsd;
			;	reading sectors and if a signature is found in the sector, transferring control to the sector
			%include "readViaOneQhAndJmp.inl"
		.Cond$notFoundMsd:
		; Remove changes that were made while reading sectors
		; QhSgl_endpointCharacteristics
		;	bit[13:12] EndpointSpeed = 010b = HiSpeed (0x00002000)
		;	bit[11:8] Endpt = control
		mov byte [ di + c_dwOffset_QhSetupIn + c_dwOffset_Qh__EndpointCharacteristics + 1 ], ( ( 010b << ( 12 - 8 ) ) | 0x00 )

	.next$DeviceAddr:
	; So that after an error everything works again normally. Before shortening there was a reset via the double word register
	mov byte [ di + c_dwOffset_QhSetupIn + c_dwOffset_Qh__transferOverlay_qTdToken + 0 ], 0
	; We will only touch bit[6:0] "DeviceAddress", zero will be in bit[7] "InactiveOnNextTransaction" for non-HiSpeed
	inc byte [ di + c_dwOffset_QhSetupIn + c_dwOffset_Qh__EndpointCharacteristics ]
%ifndef def_dvc$Pci$Usb$Ehci$attachedSglQh$bAllow
	inc byte [ di + c_dwOffset_Qh2$_beg + c_dwOffset_Qh__EndpointCharacteristics ]
%endif
	; ; Trace. Release3. Print next DeviceAddr
	; movzx eax, byte [  di + c_dwOffset_QhSetupIn + c_dwOffset_Qh__EndpointCharacteristics  ]
	; call bp
	; ;
	;	the maximum "DeviceAddr" that will pass will be 0x7F(127), in total there are 7 bits for the address
	cmp byte [ di + c_dwOffset_QhSetupIn + c_dwOffset_Qh__EndpointCharacteristics ], ( 0x7F )
	jb .loop$EnumDeviceAddr; ; }
	.break_$loop$EnumDeviceAddr:

	popa
	ret

dvc$Pci$Usb$Ehci$scanDeviceAddrAndReadX$_end:
%endif ; def_dvc$Pci$Usb$Ehci$scanDeviceAddrAndReadX$_once
