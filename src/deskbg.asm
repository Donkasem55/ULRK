[org 0xC000]

jmp main

welcome db "Welcome to ", 0
exclam db "!", 10, 0
vsptr dw 0x0000

main:
	mov ax, cs
	mov es, ax
	mov ax, 0
	mov si, welcome
	call 0x0000:0x8800 ; i think it's obvious what this is for

	mov ax, 3
	mov bx, 0
	call 0x0000:0x8800

	mov [vsptr], bx

	mov ax, 0
	mov si, bx
	call 0x0000:0x8800

	mov ax, 3
	mov bx, 1
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

mainloop:
	mov ax, 4
	mov bx, 2
	mov cl, 0x36
	call 0x0000:0x8800

	; I'm not even gonna try to explain my graphics system (I can't without losing my mind)

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

	mov ax, 4
	mov bx, 2
	mov cl, 0x13
	call 0x0000:0x8800

	mov bx, 5
	mov cx, 320
	mov dx, 20
	push 0
	push 0
	call 0x0000:0x9E00

	mov ax, 4
	mov bx, 2
	mov cl, 0x0F
	call 0x0000:0x8800

	mov bx, 6
	mov cx, 0
	mov dx, 0
	mov si, [vsptr]
	call 0x0000:0x9E00

	; this is the yield syscall except it's unused since I'm returning immediately
	; mov ax, 6
	; call 0x0000:0x8800

end:
	ret

times 512 - ($ - $$) db 0
