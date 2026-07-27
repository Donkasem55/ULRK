; Initialisation System Functions

; call at 0x7E80

[org 0x7E00]

cli

init:
	call clear
	mov si, load
	call print
	jmp bootseq

times 128 - ($ - $$) db 0

bootseq:
	mov si, bootmsg
	call print
	jmp bootmain

clear:
	mov ax, 0x0003
	int 0x10
	ret

print:
.loop:
	mov ah, 0x0E
	mov bx, si
	mov al, [bx]
	cmp al, 0
	je .done
	cmp al, 10
	je .newline

	int 0x10
	inc si
	jmp .loop

.newline:
	mov ah, 0x03
	mov bh, 0x00
	int 0x10

	mov bh, 0
	mov ah, 0x02
	add dh, 1
	mov dl, 0
	int 0x10
	inc si
	jmp .loop

.done:
	ret

bootmain:
	mov si, mainloop
	call print
	mov si, welc
	call print

.bootloop:
	mov si, booting
	call print

	mov ah, 0x00
	int 0x16

	cmp al, 'B'
	je .endboot
	cmp al, 'b'
	je .endboot
	jmp .bootloop

.endboot:
	mov ah, 0x0E
	int 0x10
	
	mov si, dnewline
	call print

	mov si, norm
	call print

	cli
	hlt

load db "[LP 0x01] RKSI: LOADED INITSYSFN", 10, 0
bootmsg db "[LP 0x02] RKSI: INITIALISED ULRK", 10, 0
mainloop db "[LP 0x03] RKSI: ENTERED MAINLOOP", 10, 10, 0
welc db "RKSI: Kernel Loading Complete", 10, "Welcome to the Ultra Lightweight Reduced Kernel!", 10, 10, 0
booting db "Please press 'B' to boot in Normal Mode.", 10, 0
norm db "RKSI: Normal Mode Boot Successful", 10, 0
dnewline db 10, 10, 0

times 4096 - ($ - $$) db 0
