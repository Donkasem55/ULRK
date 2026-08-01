mkdir obj
nasm -f bin src/boot.asm -o obj/boot.o
nasm -f bin src/initsysfn.asm -o obj/initsysfn.o
nasm -f bin src/microgl.asm -o obj/microgl.o
nasm -f bin src/deskbg.asm -o obj/deskbg.o
cat obj/boot.o obj/initsysfn.o src/fssignature.bin obj/microgl.o obj/deskbg.o > disk.img
