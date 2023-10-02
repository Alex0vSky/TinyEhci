; Copyright 2023 Alex0vSky (https://github.com/Alex0vSky)
; BootTime/bootRecordFormat/afterPayload/pair_Bpb_UsbLegacySupport.inl - completion for BootTime/bootRecordFormat/beforePayload/pair_Bpb_UsbLegacySupport.inl

%ifndef def_$BootTime$bootRecordFormat$aft$UsbLegacySupport$_once
%define def_$BootTime$bootRecordFormat$aft$UsbLegacySupport$_once

; Announce that the closing pair has been included
%define def_$BootTime$bootRecordFormat$afterPayload$strName 'pair_Bpb_UsbLegacySupport.inl'

; Padding with zeros so that the binary is 512 bytes in size. If a compilation error "error: TIMES value N is negative" occurs, it means that the permissible size of the bootsector has been exceeded
times (510) - ($ - $$)  db 0

; Signature
db 0x55, 0xAA


%endif ; def_$Xxx$_once
