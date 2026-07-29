; memory sections

kernstart dw 0x7E00, 0x0000
kernend dw 0x8600, 0x0000

driverstart dw 0x8700, 0x0000
driverend dw 0xA700, 0x0000

fsstart dw 0xB000, 0x0000
fsend dw 0xB200, 0x0000

datastart dw 0xC000, 0x0000

kernelstart:
	cli

	xor ax, ax
	mov es, ax
	mov [es:0x0200], syscalls
	mov [es:0x0202], seg syscalls

	sti

	xor ax, ax
	mov es, ax
	xor di, di

	mov ax, 0
	mov es, ax
	mov bx, [fsstart]

	mov ch, 0
	mov cl, 6
	mov dh, 0
	mov dl, 0x80
	mov al, 1
	mov ah, 2
	int 0x13

kernel:
syscalls:
	cmp ax, 0
	je .printsyscall

	cmp ax, 1
	je .clearsyscall

	cmp ax, 2
	je .readfilecall

	jmp .returncall

.printsyscall:
	call print
	jmp .returncall

.clearsyscall:
	mov [consattr], bx
	call reset
	jmp .returncall

.readfilecall:
	mov ax, 2
	mul bx
	mov bx, ax
	add bx, [fsstart]

	xor ax, ax
	mov es, ax
	xor di, di

	mov al, [bx]
	mov cl, [bx+1]
	
	mov ax, 0
	mov es, ax
	mov bx, si

	mov ch, 0
	mov dh, 0
	mov dl, 0x80
	mov ah, 2
	int 0x13

	jmp .returncall

.returncall:
	iret
