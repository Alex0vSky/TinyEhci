# _TinyEhci_
[![asm](https://img.shields.io/badge/asm-x86-blue?logo=intel)](
https://en.wikipedia.org/wiki/Assembly_language
)

Tiny, less than 512 bytes, bare metal EHCI read

## Features
A *full* search is performed to find only the specific memory card in the USB2 slot.
Tricks, how to reduce them, and details in [explanations](https://alex0vsky.github.io/posts/TinyEhci/#explanation)

## Requirements
[__Nasm__](https://github.com/netwide-assembler/nasm) to building.

To run
- [__Qemu__](https://github.com/qemu) to run "local"/RightNow in Emulator/VM.
- To run on real hardware in the real world: hardware with "Usb Legacy" boot support and something like [HxD](https://en.wikipedia.org/wiki/HxD) to write the boot sector to a usbstick.

Hardware requirements details in [blog](https://alex0vsky.github.io/posts/TinyEhci/#requirements)

## Install
If you want to write boot sector to UsbDrive/usbstick/FlashCard [screenshots](https://alex0vsky.github.io/posts/TinyEhci/#write-bootsector-in-usbstick). It is not safe!

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
- Universal Serial Bus Specification, Revision 2.0
- usbmassbulk_10.pdf
- ehci-specification-for-usb.pdf

SCSI Standard group
- SCSI Commands Reference Manual - Seagate
- SCSI Block Commands - 3 (SBC-3)
- SCSI Block Commands - 2 (SBC-2)

## License
See the [LICENSE](https://github.com/Alex0vSky/TinyEhci/blob/main/LICENSE) file for license rights and limitations (MIT).
