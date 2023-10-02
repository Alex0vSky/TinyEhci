# _TinyEhci_
[![asm](https://img.shields.io/badge/asm-x86-blue?logo=intel)](
https://en.wikipedia.org/wiki/Assembly_language
)

Tiny, less then 512 bytes, ehci(usb2) reading on bare-metal

## Features
Completely search process to find only certain stick in USB2 slot.
Tricks to reduce all of them and
detail in [explanation](https://alex0vsky.github.io/posts/TinyEhci#Explanation) text

## Requirements
Nasm, Qemu or Hadrware with supporting boot of Usb Legacy, something like HxD to write bootsector in usbstick

## Install
If wonna write bootsector in usbstick [install](https://alex0vsky.github.io/posts/TinyEhci#write_bootsector) some text...

## Usage
Modify path to _qemu_ and _nasm_ in `include/paths.cmd`
Build `step5_gh/bootsector.img` and after, run in *qemu* emulator
`step5_gh/build_and_run_nographic.bat`
or write built `bootsector.img` to *flash usb stick*, starting from first sector
Then, need to switch on your BIOS to loading from USB, and enable "Legacy Usb" mode

## Tests
comming soon partially

## Build
Just pass include path to nasm for compiling single `bootsector.asm`
File extension convention:
*.asm - callable code
*.inc - defines, true/false, contants
*.inl - inline code
*.mac - macro with arguments

## Contributing
Can ask questions. PRs are accepted. No requirements for contributing.

## Thanks
USB2 Standard group, tatOs, kolibriOs

## License
See the [LICENSE](https://github.com/Alex0vSky/TinyEhci/blob/main/LICENSE) file for license rights and limitations (MIT).
