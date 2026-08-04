qemu-system-i386 -drive format=raw,file=disk.img -monitor stdio -d int,cpu_reset,guest_errors -D qemu.log -no-reboot
