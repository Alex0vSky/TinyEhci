; BootTime/bootRecordFormat/beforePayload/pair_Bpb_UsbLegacySupport.inl - on the hardware the flash drive is displayed as "USB FDD label"
;	@insp \include\BootTime\bootRecordFormat\beforePayload\pair_Fat12BootRecord_kolibriOs.inl
;	@insp https://infogalactic.com/info/BIOS_Parameter_Block
;	@insp https://infogalactic.com/info/DOS_2.0_BPB#BPB20
;	@insp https://infogalactic.com/info/DOS_2.0_BPB#FATID
;	@insp https://infogalactic.com/info/DOS_2.0_BPB#BPB30
;	@insp https://infogalactic.com/info/DOS_2.0_BPB#BPB20_OFS_08h
;	@insp https://www.win.tue.nl/~aeb/linux/fs/fat/fat-1.html
;	@insp http://46.29.163.254/wiki/FAT16
;	@insp https://codereview.stackexchange.com/questions/94220/the-loaderless-bootloader#Furtherreading
;	@insp https://jdebp.uk/FGA/bios-parameter-block.html
;	@insp https://ru.bmstu.wiki/IPL_(Initial_Program_Load)
;	!perhaps the BIOS will overwrite some values ​​here
;		https://forum.osdev.org/viewtopic.php?f=1&t=32428&sid=402df4a48f4830322e33ea3a61fd6198&start=15
;	here this staff is classified as "VolumeBootRecord"
;		https://github.com/ANSSI-FR/bootcode_parser/blob/master/bootcode_parser.py

; TODO(alex): In general, you need to study the project "ANSSI-FR/bootcode_parser"

%ifndef def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$_once ; #pragma once
%define def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$_once

; A mechanism so that multiple formats cannot be set and allows you to remember to insert a prefix and suffix
%define def_$BootTime$bootRecordFormat$beforePayload$strName 'pair_Bpb_UsbLegacySupport.inl'

%include "util/bswap.mac"

; Start of data
g_$BootTime$bootRecordFormat$bef$UsbLegacySupport$_beg:
; Jump through data
jmp short g_$BootTime$bootRecordFormat$bef$UsbLegacySupport$_end;
;	well, it’s customary for there to be "nop"
nop ; +poke reboots
; db 0x00 ; +

; "BPB" data

; Data inserts for code
;	I found out that to start from the BIOS there must be byte 0x29 (Extended boot signature) at offset 0x26. The rest can vary
;	a test was carried out for the permeability of the boot with the variability of the trail fields:
;		g_lpStdDvcReq$GetAnyCfgDescr$_beg.wLength
;		[g_dvc$Cpu$bigUnrealMode$lpDescrGdt+2]
%ifdef def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPlace_stdUsbReq
	; 	"StandardUsbRequest" GET_DESCRIPTOR(CONFIGURATION)
	g_lpStdDvcReq$GetAnyCfgDescr$_beg:
		.bmRequestType		db 010000000b ; 0x80
		.bRequest			db 6
		; TODO(alex): write how this number is formed wValue=02=CONFIGURATION and 00=index
		.wValue				dw ( ( ( 0x02 ) << 8 ) | ( 0x00 ) ) ; dw 0x0200
		.wIndex				dw 0
		.wLength			dw c_dvc$Pci$Usb$Ehci$asyncList$stdDvcReq$GetAnyCfgDescr$xbTotalBytesToTransfer
	g_lpStdDvcReq$GetAnyCfgDescr$_end:
%else
	; OEM-name
	db 0x4B, 0x4F, 0x4C, 0x49, 0x42, 0x52, 0x49, 0x20
%endif

	; Format of standard DOS 2.0 BPB for FAT12 (13 bytes):
	;		"Number of bytes per sector"
	db 0x00, 0x02 ; -poke reboots
	;		"Number of sectors in a cluster"
	db 0x01 ; -poke reboots
	;		(part 1) "Number of reserved sectors. Boot record sectors are included in this value"
	db 0x01 ; -poke reboots
	;		(part 2) "Number of reserved sectors. Boot record sectors are included in this value"
	db 0x00 ; -poke reboots
	;		"The number of file allocation tables (FAT) on the media. This value is often 2"
	db 0x02 ; -poke reboots
	;		ImHex, root entries 224
	;		(part 1) "Number of directory entries (must be set so that the root directory occupies entire sectors)"
	db 0xE0 ; +poke reboots
	;		(part 2) "Number of directory entries (must be set so that the root directory occupies entire sectors)"
	db 0x00 ; +poke reboots
	;		ImHex, sectors 2880 (volume <=32 MB)
	;			If this value is 0, it means there are more than 65535 sectors in the volume and the actual number of sectors is stored in the Large Sector Count entry at 0x20
	;		(part 1) "Total number of sectors in a logical volume"
	db 0x40 ; -poke reboots
	;		(part 2) "Total number of sectors in a logical volume"
	db 0x0B ; -poke reboots
	;		"This byte indicates the media handle type"
	;			https://infogalactic.com/info/Design_of_the_FAT_file_system#media
	;			Designated for use with custom floppy and superfloppy formats where the geometry is defined in the BPB
	db 0xF0 ; +poke reboots
	;		ImHex, sectors/FAT 9
	;		(part 1) "Number of sectors on FAT. FAT12 / FAT16 only"
	db 0x09 ; +poke reboots
	;		(part 2) "Number of sectors on FAT. FAT12 / FAT16 only"
	db 0x00 ; +poke reboots

%ifdef def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPlace_read6
; 	CBW(Command Block Wrapper) + SCSI_read6
g_lpScsiCmd$readX$_beg:
	.dCBWSignature						dd 0x43425355
	.dCBWTag							dd 0x00000000
	.dCBWDataTransferLength				dd ( c_dvc$Pci$Usb$Ehci$uMaxBytesPer_qTd )
	.bmCBWFlags							db 0x80
	.bCBWLUN							db 0x00
	; We use insertion of the command into the bootrecord and at this offset we need to place the "ExtendedBootSignature" signature for the BIOS
	;	which we patch before executing the "SCSI" command
	;	The number "6" should have been there, but I found out that it is important for the controller that there be more than "6" and therefore I save money and don’t patch it
	%define def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPatch_ExtendedBootSignature
	.bCBWCBLength						db 0x29
	;	above it is 15 bytes, then there is "CBWCB" of 16 bytes in size, of which 6 bytes contain the "block" "SCSI" command. Only 21 bytes out of 31 with payload.
	.SCSI_cOperationCode									db 0x08 ; OPERATION CODE (08h) = "READ (6)" command
		;		start reading from "logicalUnit" number 1, this means the second sector
		.SCSI_.read6.__cLogicalBlockAddress__msb_4_0bit		db 0
		.SCSI_.read6.__wLogicalBlockAddress__lsb			dw bswap_16( 1 )
		;		quantity of "logicalUnit" for transport
		.SCSI_.read6.__wTransferLength						db c_dvc$Pci$Usb$Ehci$uMaxCntSectorsPer_qTd
%else
	; part from DOS 3.0 BPB
	;	Number of sectors per track
	;		ImHex, sectors/track 18
	db 0x12, 0x00 ; +poke reboots
	;	Number of heads or sides on the media
	db 0x02, 0x00 ; +poke reboots
	;	Number of hidden sectors. (i.e. LBA of the beginning of the partition.)
	db 0x00, 0x00
; ??? FAT16 or MS/PC-DOS version 4.0 BPBs (part1)
	db 0x00
; EBPB data
	;	Drive number. The value here must be identical to the value returned by BIOS interrupt 0x13 or passed in the DL register; those. 0x00 for floppy and 0x80 for hard drives. This number is useless because the media will most likely be moved to another machine and inserted into a drive with a different number
	db 0x00 ; +poke reboots
; ??? FAT16 or MS/PC-DOS version 4.0 BPBs (part2)
	db 0x00
	db 0x00, 0x00, 0x00, 0x00
	;	Flags in Windows NT. Otherwise reserved
	db 0x00 ; +poke reboots
	;	Signature (must be 0x28 or 0x29), Extended boot signature
	db 0x29 ; -poke reboots
	; db 0x28 ; -poke reboots -
; ; top occupies 0x27(39) bytes
	; ; -poke2 reboots
	; db 0x39
	; db 0x00
%endif


%ifdef def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPlace_lpDescrGdt

	%ifdef def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPlace_bigUnrealModeTrashFirstEntry
		g_dvc$Cpu$bigUnrealMode$trashFirstEntry$wAddrGdt:
			db 0xff, 0xff, 0, 0,	0, 10010010b, 11001111b, 0
	%endif

	g_dvc$Cpu$bigUnrealMode$lpDescrGdt:
		dw 15															; {2} last byte in table, 15 size. Two descriptors of 8 bytes each, minus 1
	%ifndef def_$BootTime$bootRecordFormat$bef$UsbLegacySupport$bPlace_bigUnrealModeTrashFirstEntry
		dd c_localVar$dvc$Cpu$bigUnrealMode$zeroidFirstEntry$wAddrGdt	; {4} start of table
	%else
		dd ( g_dvc$Cpu$bigUnrealMode$trashFirstEntry$wAddrGdt - 8 )		; {4} start of table
	%endif

%endif

; the rest is not needed, in the end you need to make these bytes useful by determining what is needed here exactly, then place your data here
	; ; VolumeID 'Serial' number. Used to track volumes between computers. You can ignore this if you want
	; 	db 0x00, 0x00, 0x00, 0x00
	; 	; Volume label string. This field is filled with spaces.
	; 	db 0x4B, 0x4F, 0x4C, 0x49, 0x42, 0x52, 0x49, 0x20, 0x20, 0x20, 0x20
	; 	; System ID string. This field is a string representation of the FAT file system type. It is filled with spaces. The specification says that the contents of this string cannot be trusted for any use.
	; 	db 0x46, 0x41, 0x54, 0x31, 0x32, 0x20, 0x20, 0x20

g_$BootTime$bootRecordFormat$bef$UsbLegacySupport$_end:

%endif ; def_$Xxx$_once
