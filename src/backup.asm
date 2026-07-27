[org 0x7C00]

xor ax, ax
mov es, ax
xor di, di

mov ah, 0x08
mov dl, 0x80
int 0x13

and cl, 0x3f

mov ax, 1
div cl

add ah, 1
mov bl, ah

add dh, 1
xor ah, ah
div dh

mov ch, ah
and ch, 0xff

mov cl, bl
mov dh, ah

mov ax, 0x0000
mov es, ax
mov bx, 0x7e00

mov dl, 0x80
mov al, 1
mov ah, 2
int 0x13
jmp 0x7e00

times 510 - ($ - $$) db 0
dw 0xAA55
