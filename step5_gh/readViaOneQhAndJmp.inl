; Copyright 2023 Alex0vSky (https://github.com/Alex0vSky)
; step5_gh\readViaOneQhAndJmp.inl - reading sectors using one "Qh" and "jmp" there when a signature is found, inserted

; -------------------------------------------------------------------------------------------------
; -//- 
;	if you perform "SETUP+IN" you will not receive "CSW" from BIOS operations, its good
; in: dI = asynchronousList
; in: ds = 0
; in: sI = asynchronousList + c_dwOffset_qTd$_beg + c_dwOffset_qTd__Buf
; in: bX = asynchronousList + c_dwOffset_qTd$_beg + c_dwOffset_qTd__Token
; out: does not return from here if the reading is successful and there is a signature in the data
;	the label is global so that there are no conflicts when inline
..@readViaOneQhAndJmp$_inline_:

	; ----------------
	; Command transfer
	; Let's place the "pointerToBuffer" in "BufferPagePonterList[Page0]" from where to read the command bytes

	mov word [ si ], ( g_lpScsiCmd$readX$_beg )

	; ; I'll try to copy the command to a new memory location
; newaddr equ 0x6000
	; pusha
	; mov cx, ( c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$UsbBulkOnly$uCbwLen )
	; mov si, ( g_lpScsiCmd$readX$_beg )
	; mov di, 0x6000
	; rep movsb
	; popa
	; mov word [ si ], ( newaddr )

	; qTD0, PID = OUT
	;	qTD_Token
	%xdefine def_dwCalculatedVal 0
	;		bit[30:16] TotalBytesToTransfer
	%xdefine def_dwCalculatedVal def_dwCalculatedVal|( ( c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$UsbBulkOnly$uCbwLen ) << 16 )
	;		bit[11:10] CERR Error counter, allows you to respond to erroneous "DeviceAddress"
	%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 11b << 10 )
	;		bit[9:8] PID Code (OUT generates token E1H [ehci-specification-for-usb.pdf] I think this signature is about debugging)
	%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 0b << 8 )
	;		bit[7:0] Status = active [ehci-specification-for-usb.pdf#4.10.3]
	%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 0x80 )
	;			set
	mov dword [ bx ], ( def_dwCalculatedVal )
	; QhSgl_endpointCharacteristics
	;	bit[13:12] EndpointSpeed = 010b = HiSpeed (0x00002000)
	;	bit[11:8] Endpt = BulkOutEndpoint
..@g_p$SelfModif$BulkOutEndpoint:
	mov byte [ di + c_dwOffset_QhSgl$_beg + c_dwOffset_Qh__EndpointCharacteristics + 1 ], ( ( 010b << ( 12 - 8 ) ) | 0x02 )
	; ; Trace. Output the buffer before starting
	; mov eax, [ si ]
	; call bp
	; ;
	; "Launch" EHCI
	; It won't work as "byte" because we are higher than 0x100 and we need to reset the "terminate" bit
	mov word [ di + c_dwOffset_QhSgl$_beg + c_dwOffset_Qh__qTd_NextPointer ], c_ddAddr_qTd$_beg
	; We are waiting for the completion of “work1” of EHCI, this is resetting “Status active” to “qTD_Token”. I found out that you can’t launch it on hardware until we wait, because there’s only one “qTd”
	.loopWait$CommandTransfer$ordinary:
		test byte [ bx ], 0x80
	jnz .loopWait$CommandTransfer$ordinary;
	; ; Trace. Print qTD_Token
	; mov eax, [ bx  ]
	; call bp ; 0x80000C00
	; ;
	; ; Trace. Print buffer from the overlay
	; mov eax, [ di + c_dwOffset_QhSgl$_beg + c_dwOffset_Qh__transferOverlay_Buf ]
	; call bp
	; ;

%ifndef realHardware_
	; tmp. sleep
	call bp
%endif

	; ----------------
	; Data transport
	; Let’s indicate where to write the data, EHCI can detect “overlap” and “C_Page” will grow
	;	BufferPagePonterList[Page0], the offset is valid. It is necessary to erase the previous meaning and therefore "word"
	mov word [ si ], ( ( c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$wDstAddr ) + 0x1000*0 )
	;	BufferPagePonterList[Page1]
	mov byte [ si + 1 + 4*1 ], ( ( c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$wDstAddr >> 8 ) + 0x10*1 )
	;	BufferPagePonterList[Page2]
	mov byte [ si + 1 + 4*2 ], ( ( c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$wDstAddr >> 8 ) + 0x10*2 )
	;	BufferPagePonterList[Page3]
	mov byte [ si + 1 + 4*3 ], ( ( c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$wDstAddr >> 8 ) + 0x10*3 )
	;	BufferPagePonterList[Page4]
	mov byte [ si + 1 + 4*4 ], ( ( c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$wDstAddr >> 8 ) + 0x10*4 )
	; qTD0, PID = IN
	;	qTD_Token. If something unfamiliar appears after a transfer like 0x00001100, it was "C_Page" that worked
	%xdefine def_dwCalculatedVal 0
	;		bit[30:16] TotalBytesToTransfer
	%xdefine def_dwCalculatedVal def_dwCalculatedVal|( c_dvc$Pci$Usb$Ehci$uMaxBytesPer_qTd << 16 )
	;		bit[11:10] CERR Error counter, allows you to respond to erroneous "DeviceAddress"
	%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 11b << 10 )
	;		bit[9:8] PID Code (IN generates token 69H [ehci-specification-for-usb.pdf] I think this signature is about debugging)
	%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 01b << 8 )
	;		bit[7:0] Status = active [ehci-specification-for-usb.pdf#4.10.3]
	%xdefine def_dwCalculatedVal def_dwCalculatedVal|( 0x80 )
	;			set
	mov dword [ bx ], ( def_dwCalculatedVal )
	; QH2_endpointCharacteristics
	;	bit[13:12] EndpointSpeed = 010b = HiSpeed (0x00002000)
	;	bit[11:8] Endpt = BulkInEndpoint
..@g_p$SelfModif$BulkInEndpoint:
	mov byte [ di + c_dwOffset_QhSgl$_beg + c_dwOffset_Qh__EndpointCharacteristics + 1 ], ( ( 010b << ( 12 - 8 ) ) | 0x01 )
	; "Launch" EHCI
	mov word [ di + c_dwOffset_QhSgl$_beg + c_dwOffset_Qh__qTd_NextPointer ], c_ddAddr_qTd$_beg
	; We are waiting for the end of work2 EHCI, this is resetting "Status active" to "qTD_Token"
	.loopWait$DataTransfer$ordinary:
		test byte [ bx ], 0x80
	jnz .loopWait$DataTransfer$ordinary;
	; ; Trace. Print qTD_Token
	; mov eax, [ bx  ]
	; call bp ; 0x80005D00


	; ; Trace. Release3. Print signature from sector
	; mov eax, [ ( ( c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$wDstAddr + ( ( 512*8 )*5 - 512 ) ) ) ]
	; call bp
	; ;

	cmp dword [ ( ( c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$wDstAddr + ( ( 512*8 )*5 - 512 ) ) ) ], ( ( c_cMsdId << 24 ) | ( ( ( ( -c_dvc$Pci$Usb$Ehci$wLastSector ) & 0xFFFF ) - 3 ) << 8 ) | ( 0xE9 ) )
	je ( ( c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$wDstAddr + ( ( 512*8 )*5 - 512 ) ) );
