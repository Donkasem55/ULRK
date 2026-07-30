; memory sections

bootstart dw 0x7E00, 0x0000
bootend dw 0x81FF, 0x0000

kernstart dw 0x8200, 0x0000
syscallstart dw 0x8400, 0x0000
kernend dw 0x8600, 0x0000

driverstart dw 0x8700, 0x0000
driverend dw 0xA700, 0x0000

fsstart dw 0xB000, 0x0000
fsend dw 0xB200, 0x0000

userstart dw 0xC000, 0x0000

kernloadingtxt db 10, 10, "RKSI: ATTEMPTING KERNEL LOAD", 10, 0

syscalltest db "RKSI: KERNEL LOADED SUCCESSFULL", 10, 0

kernelstart:
	mov ax, ds
	mov es, ax
	mov si, kernloadingtxt
	call print

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

	mov ax, 0
	mov si, syscalltest
	call 0x0000:0x8400

	mov si, [userstart]
	mov bx, 0
	mov ax, 2
	call 0x0000:0x8400

	call far [userstart]

	hlt

times 1536 - ($ - $$) db 0

kernel:
syscalls:
	cmp ax, 0
	je .printsyscall

	cmp ax, 1
	je .clearsyscall

	cmp ax, 2
	je .readfilecall

	cmp ax, 3
	je .vercall

	jmp .returncall

.printsyscall:
	call print
	jmp .returncall

.clearsyscall:
	mov [consattr], bx
	call reset
	jmp .returncall

.readfilecall:
	mov ax, bx
	shl ax, 1

	mov si, [fsstart]
	add si, ax

	mov al, [si]
	mov cl, [si+1]

	mov dx, 0x0000 ; fix this later
	mov es, dx
	mov bx, [userstart]

	mov ch, 0
	mov dh, 0
	mov dl, 0x80
	mov ah, 2
	int 0x13

	jmp .returncall

.vercall:
	mov bx, ver
	ret

.returncall:
	ret
