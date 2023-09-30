; dvc/Pci/Usb/Ehci/asyncList/directAcsBlkCmd/common.inc - constants
%ifndef def_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$common$_once ; #pragma once
%define def_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$common$_once

; Full command size "read10"
c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$UsbBulkOnly$uCbwLen	equ ( 31 )
; TODO(alex): write why "logicalUnit" has a size of 512 bytes
c_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$Scsi$uLogicalUnitBytes	equ ( 512 )

%endif ; def_dvc$Pci$Usb$Ehci$asyncList$directAcsBlkCmd$common$_once
