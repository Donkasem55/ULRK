; Initialisation System Functions

[org 0x7E00]

pass db "123456"
cli

init:
	mov al, 0b00001111
	call clear
	mov ax, cs
	mov es, ax
	mov si, load
	call print
	jmp bootseq

; starting attributes segment
consattr db 0x0F
passinp db "      "
osver db "ULRK-26.0", 0
kernelver db "0.0.1-ULRK-x86_16", 0

times 128 - ($ - $$) db 0

bootseq:
	mov ax, ds
	mov es, ax
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
	mov al, [es:si]
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

input:
	mov ah, 0x00
	int 0x16
	ret

bootmain:
	mov ax, ds
	mov es, ax
	mov si, mainloop
	call print

	mov ax, ds
	mov es, ax
	mov si, welc
	call print

	mov ax, ds
	mov es, ax
	mov si, booting
	call print

.bootloop:
	call input

	cmp al, 'B'
	je .endboot
	cmp al, 'b'
	je .endboot

	cmp al, 'R'
	je .reboot
	cmp al, 'r'
	je .reboot

	cmp al, 'H'
	je .halt
	cmp al, 'h'
	je .halt

	jmp .bootloop

.reboot:
	mov ah, 0x0E
	int 0x10
	mov ax, 0x0000
	int 0x19

.halt:
	mov ah, 0x0E
	int 0x10
	cli
	hlt
	jmp .bootloop

.endboot:
	mov ah, 0x0E
	int 0x10

	mov ax, ds
	mov es, ax
	mov si, dnewline
	call print

	mov ax, ds
	mov es, ax
	mov si, norm
	call print

	call clear

	mov [consattr], 0x1F
	call reset

	mov ax, ds
	mov es, ax
	mov si, osver
	call print

	mov ax, ds
	mov es, ax
	mov si, spacebar
	call print

	mov ax, ds
	mov es, ax
	mov si, kernelver
	call print

	mov ax, ds
	mov es, ax
	mov si, welcometoulrk
	call print

.login:
	mov ax, ds
	mov es, ax
	mov si, logintxt
	call print

	mov di, passinp

	call input

	mov [di], al
	inc di

	call input

	mov [di], al
	inc di

	call input

	mov [di], al
	inc di

	call input

	mov [di], al
	inc di

	call input

	mov [di], al
	inc di

	call input

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

	jmp kernelstart

load db "[LP 0x01] RKSI: LOADED INITSYSFN", 10, 0
bootmsg db "[LP 0x02] RKSI: INITIALISED ULRK", 10, 0
mainloop db "[LP 0x03] RKSI: ENTERED MAINLOOP", 10, 10, 0
welc db "RKSI: Initialisation Complete", 10, "Welcome to ", 0
booting db \
" _     _   _         ___     _   __ ", 10, \
"| |   | | | |       |  _ \  | | / / ", 10, \
"| |   | | | |       | |_| | | |/ /  ", 10, \
"| |   | | | |       |    /  |   /   ", 10, \
"| \___/ | | |_____  | |\ \  | |\ \  ", 10, \
" \_____/  |_______| |_| \_\ |_| \_\ ", 10, 10, \
"--------- Welcome to ULRK --------- ", 10, \
"| [B]: Boot in Normal Mode        | ", 10, \
"| [R]: Reboot                     | ", 10, \
"| [H]: Halt                       | ", 10, \
"----------------------------------- ", 10, 10, 0
norm db "RKSI: Normal Mode Boot Successful", 10, 0
spacebar db " ", 0
exclammark db "!", 0
dnewline db 10, 10, 0
welcometoulrk db " Login", 0
logintxt db 10, 10, "[PIN]: ", 0

times 2048 - ($ - $$) db 0

; kernel at 0x0000:0x8600
; syscall with call 0x0000:0x8800

%include "src/kernel.asm"

times 8192 - ($ - $$) db 0
