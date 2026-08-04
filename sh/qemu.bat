qemu-system-i386 -m 1G -drive format=raw,file=disk.img,if=ide -monitor stdio -d int,cpu_reset,guest_errors -D qemu.log -no-reboot
