# _TinyEhci_
[![asm](https://img.shields.io/badge/asm-x86-blue?logo=intel)](
https://en.wikipedia.org/wiki/Assembly_language
)

Tiny, less then 512 bytes, EHCI reading on bare-metal

## Features
A *full* search is performed to find only the specific memory card in the USB2 slot.
Tricks, how to reduce them, and details in [explanations](https://alex0vsky.github.io/posts/TinyEhci#explanation)

## Requirements
[__Nasm__](https://github.com/netwide-assembler/nasm) to building.

[__Qemu__](https://github.com/qemu) to run "local"/RightNow in Emulator/VM.
Hadrware with supporting boot of Usb Legacy and something like HxD to write bootsector in usbstick.
Hadrware requirements details in [blog](https://alex0vsky.github.io/posts/TinyEhci#requirements)

## Install
If you want to write boot sector to UsbDrive/usbstick/FlashCard [screenshots](https://alex0vsky.github.io/posts/TinyEhci#write_bootsector). It is not safe!

## Usage
Change the path to __qemu__ and __nasm__ in `include/paths.cmd`
Build `step5_gh/bootsector.img` and then run the *qemu* emulator.
`step5_gh/build_and_run_nographic.bat`
or write the assembled `step5_gh/bootsector.img` to *flash usb stick*, starting from the first sector.
Then you need to switch the BIOS to boot from USB and enable the "Legacy Usb" mode.

## Tests
...comming soon partially...

## Build
Just provide the path to __nasm__ to compile one `bootsector.asm`

File extension convention:
- *.asm - callable code
- *.inc - defines, true/false, contants
- *.inl - inline code
- *.mac - macro with arguments

## Contributing
Can ask questions. PRs are accepted. No requirements for contributing.

## Thanks
[tatOs](https://github.com/tatimmer/tatOS), [kolibriOs](https://github.com/KolibriOS)

USB2 Standard group https://www.usb.org/
- SCSI Commands Reference Manual - Seagate
- SCSI Block Commands - 3 (SBC-3)
- SCSI Block Commands - 2 (SBC-2)
- Universal Serial Bus Specification, Revision 2.0
- usbmassbulk_10.pdf
- ehci-specification-for-usb.pdf

## License
See the [LICENSE](https://github.com/Alex0vSky/TinyEhci/blob/main/LICENSE) file for license rights and limitations (MIT).
