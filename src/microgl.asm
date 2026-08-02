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

	cmp bx, 6
	je .mglWrite

	ret

.mglEnable:
	mov ax, 4
	mov bx, 0
	call 0x0000:0x8800
	ret
; insert a random comment here for no reason
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
	pop di

	pop [y]
	pop [x]

	mov [x2], cx
	mov [y2], dx

	mov cx, [x]
	mov dx, [y]

	.mglDrawRectLoop2:
		mov cx, [x]

		.mglDrawRectLoop:
			mov ax, 4
			mov bx, 3
			call 0x0000:0x8800

			inc cx
			cmp cx, [x2]
			jbe .mglDrawRectLoop

	.mglDrawRectLoop3:
		inc dx

		cmp dx, [y2]
		jbe .mglDrawRectLoop2

		push di
		push si
		retf

; i cant fucking get the writing to work. i have no idea why the fuck this is happening but it doesnt work. if anyone knows why please help me.

.mglWrite:
	mov ax, 0x1130
	mov bh, 0x03
	int 0x10

	mov [glyphloc], bp
	mov [esglyphloc], es

	mov [textloc], si

.mglWriteLoop:
	mov al, 'A'
	mov cx, 50
	mov dx, 50
	call .mglDrawChar
	ret

.mglDrawChar:
	mov [x], cx
	mov [y], dx

	xor ah, ah
	shl ax, 3
	mov [singlyphloc], ax

	mov bx, [glyphloc]
	add [singlyphloc], bx
	mov bx, [singlyphloc]
	mov [sgl2], bx
	add [sgl2], 8

	mov ax, [esglyphloc]
	mov es, ax

.mglDrawChar2:
	mov al, 0b00111100 ; [es:bx]
	mov [accu], 0
	.mglDrawChar3:
		shl al, 1
		jc .mglDrawCharPx
		.mglDrawChar4:
		add [accu], 1
		inc cx
		cmp [accu], 8
		jl .mglDrawChar3

	call .mglDrawCharReset
	inc bx
	cmp bx, [sgl2]
	jl .mglDrawChar2
	ret

.mglDrawCharReset:
	inc dx
	mov cx, [x]
	ret

.mglDrawCharPx:
	mov [axtmp], ax
	mov [bxtmp], bx
	mov [cxtmp], cx
	mov [dxtmp], dx
	mov [estmp], es

	call .mglSetPX

	mov ax, [estmp]
	mov es, ax
	mov dx, [dxtmp]
	mov cx, [cxtmp]
	mov bx, [bxtmp]
	mov ax, [axtmp]

	jmp .mglDrawChar4

accu db 0
axtmp dw 0
bxtmp dw 0
cxtmp dw 0
dxtmp dw 0
estmp dw 0
singlyphloc dw 0x0000
sgl2 dw 0x0000
textloc dw 0x0000
glyphloc dw 0x0000
esglyphloc dw 0x0000
x dw 0
y dw 0
x2 dw 0
y2 dw 0
times 1024 - ($ - $$) db 0

