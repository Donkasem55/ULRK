; the microgl graphics pseudo-driver.

[org 0x9E00]

jmp mglMain

mglMain:
	cmp bx, 0
	je .mglEnable

	cmp bx, 1
	je .mglDisable

	cmp bx, 2
	je .mglSetColor

	cmp bx, 3
	je .mglSetPX

	cmp bx, 4
	je .mglFill

	cmp bx, 5
	je .mglDrawRect

	ret

.mglEnable:
	mov ax, 4
	mov bx, 0
	call 0x0000:0x8800
	ret

.mglDisable:
	mov ax, 4
	mov bx, 1
	call 0x0000:0x8800
	ret

.mglSetColor:
	mov ax, 4
	mov bx, 2
	call 0x0000:0x8800
	ret

.mglSetPX:
	mov ax, 4
	mov bx, 3
	call 0x0000:0x8800
	ret

.mglFill:
	mov ax, 4
	mov bx, 4
	call 0x0000:0x8800
	ret

.mglDrawRect:
	pop si
	pop es

	pop [y]
	pop [x]

	push es
	push si

	mov [x2], cx
	mov [y2], dx

	mov ax, 4
	mov bx, 3
	mov cx, 1
	mov dx, 20
	call 0x0000:0x8800
	
	mov cx, [x]
	mov dx, [y]

	.mglDrawRectLoop2:
		mov cx, [x]

		.mglDrawRectLoop:
			cmp cx, [x2]
			jge .mglDrawRectLoop3

			mov ax, 4
			mov bx, 3
			call 0x0000:0x8800

			inc cx
			cmp cx, [x2]
			jbe .mglDrawRectLoop

	.mglDrawRectLoop3:
		inc dx
		jmp .endrectloop

	.endrectloop:
		cmp dx, [y2]
		jbe .mglDrawRectLoop2
		ret

x dw 0
y dw 0
x2 dw 0
y2 dw 0
times 1024 - ($ - $$) db 0

