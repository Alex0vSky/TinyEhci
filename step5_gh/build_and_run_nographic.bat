@echo off & REM ./step5_gh/build_and_run_nographic.bat - builder

REM Config
REM		load paths config 
REM			to switch to the directory your batch file is located in, use this:
cd %~dp0
call ../include/paths.cmd
REM		source and result paths
REM			Double quotes are prohibited because they complicate calling invis via 'mshta vbscript:Execute("CreateObject(""Wscript.Shell"").Run ...'
set ffnBootsectorAsmCode=C:\Prj\sysbare\HomoT\step5_gh\bootsector.asm
set ffnBootsectorBin=C:\Prj\sysbare\HomoT\step5_gh\bootsector.img

REM Assembly
"%ffnAssemblerExe%" -i "C:\Prj\sysbare\HomoT\include" -i "C:\Prj\sysbare\HomoT\step5_gh" -f bin -o "%ffnBootsectorBin%" "%ffnBootsectorAsmCode%"
if %errorlevel% NEQ 0 ( pause & exit /b 1 )

REM Run1 ehci hdd
"%ffnQemuExe%" ^
-nic none ^
-nographic ^
-qmp tcp:127.0.0.1:1234,server,nowait ^
-drive "if=none,id=usbstick,format=raw,file=%ffnBootsectorBin%" ^
-usb ^
-device usb-ehci,id=ehci ^
-device usb-storage,bus=ehci.0,drive=usbstick ^
-boot c

pause
