; Initialisation System Functions

; call at 0x7E80

[org 0x7E00]

cli

init:
	mov al, 0b00001111
	call clear
	mov si, load
	call print
	jmp bootseq

times 96 - ($ - $$) db 0

; starting attributes segment
consattr db 0x0F
pass db "raisin"
passinp db "      "
ver db "ULRK-26 0.0.1", 0

times 128 - ($ - $$) db 0

bootseq:
	mov si, bootmsg
	call print
	jmp bootmain

clear:
	mov ax, 0x0003
	int 0x10
	ret

reset:
	mov bx, 0xB800
	mov es, bx
	xor di, di

	mov ah, [consattr]
	mov al, ' '
	mov cx, 2000

	rep stosw
	ret

print:
.loop:
	mov ah, 0x0E
	mov al, [si]
	mov bh, 0x00
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

	call clear

	mov [consattr], 0x1F
	call reset

	mov si, logo
	call print

	mov si, welcline
	call print

	mov si, ver
	call print

	mov si, exclam
	call print

.login:
	mov si, logintxt
	call print

	mov di, passinp

	mov ah, 0x00
	int 0x16

	mov [di], al
	inc di

	mov ah, 0x00
	int 0x16

	mov [di], al
	inc di

	mov ah, 0x00
	int 0x16

	mov [di], al
	inc di

	mov ah, 0x00
	int 0x16

	mov [di], al
	inc di

	mov ah, 0x00
	int 0x16

	mov [di], al
	inc di

	mov ah, 0x00
	int 0x16

	mov [di], al
	inc di

	mov al, [pass]
	cmp al, [passinp]
	jne .login

	mov al, [pass+1]
	cmp al, [passinp+1]
	jne .login

	mov al, [pass+2]
	cmp al, [passinp+2]
	jne .login

	mov al, [pass+3]
	cmp al, [passinp+3]
	jne .login

	mov al, [pass+4]
	cmp al, [passinp+4]
	jne .login

	mov al, [pass+5]
	cmp al, [passinp+5]
	jne .login

.endlogin:
	mov si, returntxt
	call print

	cli
	hlt

load db "[LP 0x01] RKSI: LOADED INITSYSFN", 10, 0
bootmsg db "[LP 0x02] RKSI: INITIALISED ULRK", 10, 0
mainloop db "[LP 0x03] RKSI: ENTERED MAINLOOP", 10, 10, 0
welc db "RKSI: Initialisation Complete", 10, "Welcome to the Ultra Lightweight Reduced Kernel!", 10, 10, 0
booting db "Please press 'B' to boot in Normal Mode.", 10, 0
norm db "RKSI: Normal Mode Boot Successful", 10, 0
dnewline db 10, 10, 0
logo db \
" _    _   _         ___     _   __", 10, \
"| |  | | | |       |  _ \  | | / /", 10, \
"| |  | | | |       | |_| | | |/ /", 10, \
"| |  | | | |       |    /  |   /", 10, \
"| \__/ | | |_____  | |\ \  | |\ \", 10, \
" \____/  |_______| |_| \_\ |_| \_\", 10, 10, 0
welcline db "Welcome to ", 0
exclam db "!", 10, 0
logintxt db 10, "[LOGIN : 6 CHAR : NO BACKSPACE]: ", 0

returntxt db 10, "Welcome back, user!", 10, 0

times 1024 - ($ - $$) db 0

; kernel at 0x0000:0x8200

%include "src/kernel.asm"

times 2048 - ($ - $$) db 0
