# ULRK: The Ultra Lightweight Reduced Kernel

Note: While 'Reduced Kernel' is not a widely used term, it is what I have chosen to call this kernel. It has more functionalities than a usual microkernel, but less than a full kernel.

## Specifications
The kernel of the system is called the ULRK, meanwhile the operating system utilising the kernel is called ULRK-26. ULRK-26 is compatible with any 8086-compatible processors. ULRK-26's bootloader is programmed in a way that it can only boot from hard disk.

## Filesystem 
### LFAA-16
The ULRK has a basic filesystem capability. The filesystem is called Linear File Allocator Array Filesystem (LFAAFS) or 16-bit Linear File Allocator Array (LFAA-16). It is the only filesystem currently supported by ULRK. Rather than using file names, LFAA-16 uses simple numeric file IDs. Once a file is written, it cannot be resized.

LFAA-16 counts files in sectors rather than in bytes. The kernel loads the filesystem signature, which is a linear array for file allocation lasting one sector. Each entries in the filesystem include a byte of sector count followed by a byte of the starting sector, repeating for every files in the filesystem. The rest is padded with zero.

## Boot Process
### Bootloader
ULRK-26's boot process is handled by its own bootloader. The boot sector loads the system initialiser functions and the kernel sector, which is a total of 16 sectors, "initsysfn", which contains the basic functions to handle the boot process and for the kernel to utilise. The functions include input/output and clearing the screen.
### initsysfn and RKSI
Once the bootloader loads initsysfn, it jumps to a specific function within it. This is called the Reduced Kernel System Initialiser (RKSI) which handles log-in before actually jumping to the kernel. This means the authentication is outside of userland entirely.
### Authentication
The login screen is blue with small white text showing the OS and kernel version and a prompt asking for the PIN login number. Once entered, the system will jump to the kernel.

## Kernel
The ULRK is a lightweight kernel. Syscalls are called with 'call 0x0000:0x8800'. The ULRK has built-in drivers for basic graphics, accessing LFAA-16, and basic input/output.

### graphicsULRK
graphicsULRK is an extremely basic video driver. It can only handle switching between text and video mode, filling the screen with some solid colour, and changing individual pixels. It is invoked by calling the kernel with syscall number 3.

### MicroGL
MicroGL is a tiny abstraction layer which handles talking to graphicsULRK. It is loaded into memory by the kernel at 0x0000:0xB000 and invoked by calling that memory location. It has the capabilities to do everything graphicsULRK can with the added abstraction of drawing basic rectangles.

### LFAA-16 filesystem driver
The LFAA-16 filesystem driver is, well, a filesystem driver for LFAA-16. It can read entries with the syscall number 2. File writing has as of yet not been added to the driver.
