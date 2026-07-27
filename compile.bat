nasm -f bin src/boot.asm -o boot.o
nasm -f bin src/initsysfn.asm -o initsysfn.o
copy /b boot.o + initsysfn.o disk.img
