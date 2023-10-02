; Copyright 2023 Alex0vSky (https://github.com/Alex0vSky)
; dvc/Vga/TextMode.inc - constants for the terminal in text mode (mode 03, CGA-compatible text mode)

; Note: VGA frame buffer address range 0xA0000 to 0xBFFFF
; 	https://web.stanford.edu/class/cs140/projects/pintos/specs/freevga/vga/vgamem.htm#manip
;	here is the map:
;		00 -- A0000h-BFFFFh -- 128K
;		01 -- A0000h-AFFFFh -- 64K
;		10 -- B0000h-B7FFFh -- 32K
;		11 -- B8000h-BFFFFh -- 32K
; Note: 4000 bytes available in text mode per window

; Default text video mode character width
%define def_dwVgaModeDefaultWidth            80
; Default text video mode character height
%define def_dwVgaModeDefaultHight            25

; -------------------------------------------------------------------------------------------------
; Colors...
%define VGA_COLOR_BLACK                      0
%define VGA_COLOR_RED                        1
%define VGA_COLOR_GREEN                      2
%define VGA_COLOR_GR                         3
%define VGA_COLOR_BULE                       4
%define VGA_COLOR_DARK_MEGAENTA              5
%define VGA_COLOR_TURQUOISE                  6
%define VGA_COLOR_GRAY                       7
%define VGA_COLOR_BRIGHT_GRAY                8
%define VGA_COLOR_BRIGHT_RED                 9
%define VGA_COLOR_BRIGHT_GREEN               10
%define VGA_COLOR_BRIGHT_YELLOW              11
%define VGA_COLOR_BRIGHT_BULE                12
%define VGA_COLOR_BRIGHT_PURPLE              13
%define VGA_COLOR_BRIGHT_TURQUOISE           14
%define VGA_COLOR_WHITE                      15
