nasm -f bin src/boot.asm -o obj/boot.o
nasm -f bin src/initsysfn.asm -o obj/initsysfn.o
nasm -f bin src/welcome.asm -o obj/welcome.o
copy /b "obj\boot.o" + "obj\initsysfn.o" + "obj\fssignature.o" + "obj\welcome.o" disk.img
