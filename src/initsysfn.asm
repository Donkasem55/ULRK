; Initialisation System Functions

; call at 0x7E80

[org 0x7E00]

cli

init:
	mov bx, load
	call print
	jmp kernel

times 128 - ($ - $$) db 0

kernel:
	mov cx, kernelmsg
	call print
	jmp main

print:
	;mov ah, 0x03
	;mov bh, 0x00
	;int 0x10

	mov bh, 0
	mov ah, 0x02
	mov dh, 0
	mov dl, 0
	int 0x10

.loop:
	mov ah, 0x0E
	mov bx, cx
	mov al, [bx]
	cmp al, 0
	je .done

	int 0x10
	inc cx
	jmp .loop

.done:
	ret

main:
	mov cx, mainloop
	call print
	mov cx, welc
	call print

.kernelloop:
	jmp .kernelloop
	cli
	hlt

load db "[LP 0x01] MKSI: LOADED ULMK INITSYSFN", 10, 0
kernelmsg db "[LP 0x02] MKSI: INITIALISED KERNEL", 10, 0
mainloop db "[LP 0x03] MKSI: ENTERED MAINLOOP", 10, 0
welc db "Welcome to the Ultra Lightweight Micro-Kernel!", 10, 0
prompt db 10, "> ", 0

times 1024 - ($ - $$) db 0
