; BootTime/adjustStack/ax0/belowThenBootsector.inl - stack setup, below the loaded bootsector (ax=0)

	; The stack grows downwards, i.e. the next address used will be [sp - 2] (for 16 bits).
	mov	ss, ax
	; TODO(alex): you need a file like memoryMap.inc in which errors of memory "overlapping" will be checked
	; Let's leave some space for local variables
	;	def_dvc$Vga$standalonePrintHexDword$dwAddr_ddString
	;	c_localVar$diag$wAddr_dwUSBBASE 8 bytes
	;	def_$diag$several$wAddr_dwOperationalRegisters 8 bytes
%ifdef def_$config$wNextLocalValue
	mov	sp, 0x7C00 - def_$config$wNextLocalValue
%else
	mov	sp, 0x7C00
%endif
