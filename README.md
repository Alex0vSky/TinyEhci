# _TinyEhci_
Tiny, less then 512 bytes, ehci(usb2) reading on bare-metal

## Features
Tricks to reduce all of them

## Requirements
Fasm, Qemu

## Install

## Usage
modify `include\paths.cmd`
build `bootsector.img` and run in *qemu* emulator
`step5_gh\build_and_run_nographic.bat`
or write 
`bootsector.img` to *flash usb stick*, starting from first sector

## Tests

## Build
*.asm - callable code
*.inc - defines, true/false, contants
*.inl - inline code
*.mac - macro with arguments

## Contributing
Can ask questions. PRs are accepted. No requirements for contributing.

## Thanks
tatOs, kolibriOs

## License
See the [LICENSE](https://github.com/Alex0vSky/TinyEhci/blob/main/LICENSE) file for license rights and limitations (MIT).
