nasm -f bin src/boot.asm -o obj/boot.o
nasm -f bin src/initsysfn.asm -o obj/initsysfn.o
nasm -f bin src/deskbg.asm -o obj/deskbg.o
cat obj/boot.o obj/initsysfn.o obj/fssignature.o obj/deskbg.o > disk.img
