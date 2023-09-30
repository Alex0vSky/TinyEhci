; BootTime/ax0/adjustDsCs.inl - configure segment registers "ds" and "cs" 16bit (ax=0), @insp smbmbr03.zip\SMBMBR.ASM

	; zeros everywhere
	mov	ds, ax
	; configure the "cs" register via control transfer
	jmp 0:.unsure_set_reg_cs
.unsure_set_reg_cs:	
