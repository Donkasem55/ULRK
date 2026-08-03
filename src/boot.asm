[org 0x7C00]

xor ax, ax
mov es, ax
xor di, di

mov ax, 0
mov es, ax
mov bx, 0x7E00

mov ch, 0
mov cl, 2
mov dh, 0
mov dl, 0x80
mov al, 16
mov ah, 2
int 0x13

jc disk_error
jmp loadfs
disk_error:
	hlt

loadfs:
	mov ax, 0
	mov es, ax
	mov bx, 0xB000

	mov ch, 0
	mov cl, 18
	mov dh, 0
	mov dl, 0x80
	mov al, 1
	mov ah, 2
	int 0x13

longjump:
	jmp 0x0000:0x7E00

times 510 - ($ - $$) db 0
dw 0xAA55
