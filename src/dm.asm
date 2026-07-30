[org 0xC000]

jmp main

welcome db "Welcome to ", 0
exclam db "!", 10, 0

main:
	mov ax, cs
	mov es, ax
	mov ax, 0
	mov si, welcome
	call 0x0000:0x8800 ; i think it's obvious what this is for

	mov ax, 3 ; os version syscall number
	call 0x0000:0x8800

	mov ax, 0
	mov si, bx
	call 0x0000:0x8800

	mov ax, cs
	mov es, ax
	mov ax, 0
	mov si, exclam
	call 0x0000:0x8800

	mov ax, 4
	mov bx, 0
	call 0x0000:0x8800

	mov ax, 4
	mov bx, 2
	mov cl, 0x36
	call 0x0000:0x8800

	; I'm not even gonna try to explain microgl (I can't without losing my mind)

	mov ax, 4
	mov bx, 4
	mov cx, 0
	mov dx, 32000
	call 0x0000:0x8800

	mov ax, 4
	mov bx, 2
	mov cl, 0x77
	call 0x0000:0x8800

	mov ax, 4
	mov bx, 4
	mov cx, 32000
	mov dx, 32000
	call 0x0000:0x8800

	ret

times 512 - ($ - $$) db 0
