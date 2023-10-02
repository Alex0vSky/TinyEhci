; Copyright 2023 Alex0vSky (https://github.com/Alex0vSky)
; io/OvrTty.asm - base for output to video terminal in text mode, {T}ele{TY}pe

; Only if the self-explanatory output "Dword" is not specified
%ifndef def_$io$Tty$UsingPrintChar$bOnly_hexDword
	; Branching depending on the config
	%ifdef _def_unused ; just for convenience of adding the following lines
	%elifdef def_$io$Tty$bPrintChar_DirectHardware
		%include "io/Tty/PrintChar/OvrDirectHardware.asm"
	%elifdef def_$io$Tty$bPrintChar_Bios
		; TODO(alex): you need to understand that the Bios is outdated and now everywhere there is UEFI instead (https://github.com/TomatOrg/TomatBoot)
		%include "io/Tty/PrintChar/Bios.asm"
	%else ; completion of conditions
		%error "Unexpected def_$io$Tty$bPrintChar_Xxx"
	%endif
%endif

; TODO(alex): I don’t quite like the branching now,
; for example, you need an include file that will select the "char" output method based on the config
; and another file that selects the set of available output functions
; and the hex dumper will connect the "char" output based on the config, the output functions will be chosen by itself

; Functions using the "PrintChar" implementation
%include "io/Tty/UsingPrintChar.asm"
