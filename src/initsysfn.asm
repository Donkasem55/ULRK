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
txtcursor dw 0, 0
savedes dw 0

times 128 - ($ - $$) db 0

bootseq:
	mov ax, ds
	mov es, ax
	mov si, bootmsg
	call print
	jmp bootmain

clear:
	call reset
	mov [txtcursor], 0
	mov [txtcursor+2], 0
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

resetcursorpos:
	mov dx, 0x3D4
	mov al, 0x0F
	out dx, al

	mov ax, di
	shr ax, 1

	mov dx, 0x3D5
	out dx, al

	mov dx, 0x3D4
	mov al, 0x0E
	out dx, al

	mov dx, 0x3D5
	mov ax, di
	shr ax, 1
	mov al, ah
	out dx, al

	ret

printchar:
	mov ah, [consattr]
	mov cx, ax
	mov ax, 80
	mov bx, [txtcursor+2]
	mul bx
	add ax, [txtcursor]
	mov bx, 2
	mul bx
	mov di, ax
	mov ax, 0xB800
	mov es, ax
	mov [es:di], cx
	inc [txtcursor]
	cmp [txtcursor], 80
	jl .end

	mov [txtcursor], 0
	inc [txtcursor+2]

.end:
	call resetcursorpos
	ret

print:
	mov [savedes], es
	mov ax, 80
	mov bx, [txtcursor+2]
	mul bx
	add ax, [txtcursor]
	mov bx, 2
	mul bx
	mov di, ax
	call resetcursorpos

.loop:
	mov ax, [savedes]
	mov es, ax
	mov ah, [consattr]
	mov al, [es:si]
	cmp al, 0
	je .done
	cmp al, 10
	je .newline

	mov bx, 0xB800
	mov es, bx
	mov [es:di], ax
	inc si
	add di, 2
	call resetcursorpos
	inc [txtcursor]
	mov ax, [txtcursor]
	cmp ax, 80
	jl .loop
	mov [txtcursor], 0
	inc [txtcursor+2]
	jmp .loop

.newline:
	mov [txtcursor], 0
	add [txtcursor+2], 1

	mov ax, 80
	mov bx, [txtcursor+2]
	mul bx
	add ax, [txtcursor]
	mov bx, 2
	mul bx
	mov di, ax

	call resetcursorpos

	inc si
	jmp .loop

.done:
	mov ax, [savedes]
	mov es, ax
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

	call clear

	mov ax, ds
	mov es, ax
	mov si, welc2
	call print

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
	call printchar
	mov ax, 0x0000
	int 0x19

.halt:
	call printchar
	cli
	hlt
	jmp .bootloop

.endboot:
	call printchar

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
	cli
	
GDT:
	dq 0

	; ring zero code
	db 0b00000000
	db 0b00000000
	db 0b10011011
	db 0x00
	dw 0x8600
	dw 0x1400

	; ring zero data
	db 0b00000000
	db 0b00000000
	db 0b10010011
	db 0x00
	dw 0x8600
	dw 0x1400

	; continue later

	;jmp kernelstart

load db "[LP 0x01] RKSI: LOADED INITSYSFN", 10, 0
bootmsg db "[LP 0x02] RKSI: INITIALISED ULRK", 10, 0
mainloop db "[LP 0x03] RKSI: ENTERED MAINLOOP", 10, 10, 0
welc db "[LP 0x04] RKSI: Initialisation Complete", 10, 0
welc2 db 10, " Welcome to ", 0
booting db 10, 10, \
" ------------------------------------------------------------------ ", 10, \
" |   _     _   _         ___     _   __  |  -----    ____  -----  | ", 10, \
" |  | |   | | | |       |  _ \  | | / /  |  |   |___/   /__|   |  | ", 10, \
" |  | |   | | | |       | |_| | | |/ /   |  |      /   /   |   |  | ", 10, \
" |  | |   | | | |       |    /  |   /    |  |    _/   /____|   |  | ", 10, \
" |  | \___/ | | |_____  | |\ \  | |\ \   |  |   |/   /     |   |  | ", 10, \
" |   \_____/  |_______| |_| \_\ |_| \_\  |  |       /      |   |  | ", 10, \
" |                                       |  |   |\   \     |   |  | ", 10, \
" |----------- Welcome to ULRK -----------|  |   | \   \    |   |  | ", 10, \
" |  [B]: Boot in Normal Mode             |  |   |__\   \___|   |  | ", 10, \
" |  [R]: Reboot                          |  |       \   \  |   |  | ", 10, \
" |  [H]: Halt                            |  ---------\___\-|___|  | ", 10, \
" ------------------------------------------------------------------ ", 10, 10, 0
norm db "[LP 0x05] RKSI: Normal Mode Boot Successful", 10, 0
spacebar db " ", 0
exclammark db "!", 0
dnewline db 10, 10, 0
welcometoulrk db " Login", 0
logintxt db 10, 10, "[PIN]: ", 0

times 2048 - ($ - $$) db 0

; kernel at 0x0000:0x8600
; syscall with call 0x0000:0x8800
