[org 0xC000]

jmp main

welcome db "Welcome to ", 0
exclam db "!", 10, 0

main:
	mov ax, cs
	mov es, ax
	mov ax, 0
	mov si, welcome
	call 0x0000:0x8400 ; i think it's obvious what this is for

	mov ax, 3 ; os version syscall number
	call 0x0000:0x8400

	mov ax, 0
	mov si, bx
	call 0x0000:0x8400

	mov ax, cs
	mov es, ax
	mov ax, 0
	mov si, exclam
	call 0x0000:0x8400

	ret

times 512 - ($ - $$) db 0
