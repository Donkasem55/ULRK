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

load db "[LP 0x01] RKSI: LOADED INITSYSFN", 10, 0
kernelmsg db "[LP 0x02] RKSI: INITIALISED ULRK", 10, 0
mainloop db "[LP 0x03] RKSI: ENTERED MAINLOOP", 10, 0
welc db "Welcome to the Ultra Lightweight Reduced Kernel!", 10, 0
prompt db 10, "ULRK SHELL [MAX 512] > ", 0

cmd: resb 512
cmdindex dw 0

times 4096 - ($ - $$) db 0
