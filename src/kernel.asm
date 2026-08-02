; memory sections

bootstart dw 0x7E00, 0x0000
bootend dw 0x81FF, 0x0000

kernstart dw 0x8600, 0x0000
syscallstart dw 0x8800, 0x0000
kernend dw 0x9D00, 0x0000

microglstart dw 0x9E00, 0x0000
microglend dw 0xAFFF, 0x0000

fsstart dw 0xB000, 0x0000
fsend dw 0xB400, 0x0000

userstart dw 0xC000, 0x0000

datastart dw 0xC000, 0x1000

crntprocid db 0

colourindex db 0
secondcolour db 0

kernloadingtxt db 10, 10, "RKSI: ATTEMPTING KERNEL LOAD", 10, 0

syscalltest db "RKSI: KERNEL LOADED SUCCESSFULL", 10, 0

rega dw 0, 0, 0, 0
regc dw 0, 0, 0, 0
regd dw 0, 0, 0, 0

regsp dw 0, 0, 0, 0
regbp dw 0, 0, 0, 0
regdi dw 0, 0, 0, 0

regcs dw 0, 0, 0, 0
regds dw 0, 0, 0, 0
regss dw 0, 0, 0, 0

processes dw \
	0xC000, 0x0000, \
	0x0000, 0x0000, \
	0x0000, 0x0000, \
	0x0000, 0x0000, \

proccount db 0

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
	mov cl, 18
	mov dh, 0
	mov dl, 0x80
	mov al, 1
	mov ah, 2
	int 0x13

	mov ax, 0
	mov si, syscalltest
	call 0x0000:0x8800

	mov ax, [microglstart + 2]
	mov es, ax
	mov si, [microglstart]
	mov bx, 0
	mov ax, 2
	call 0x0000:0x8800

	mov ax, [userstart + 2]
	mov es, ax
	mov si, [userstart]
	mov bx, 1
	mov ax, 2
	call 0x0000:0x8800

	mov ax, [datastart + 2]
	mov es, ax
	mov si, [userstart]
	mov bx, 2
	mov ax, 2
	call 0x0000:0x8800

	call far [userstart]

	hlt

times 2560 - ($ - $$) db 0

kernel:

syscalls:
	mov [rega], ax
	mov [regc], cx
	mov [regd], dx

	mov [regsp], sp
	mov [regbp], bp
	mov [regdi], di

	mov [regcs], cs
	mov [regds], ds
	mov [regss], ss

	cmp ax, 0
	je .printsyscall

	cmp ax, 1
	je .clearsyscall

	cmp ax, 2
	je .readfilecall

	cmp ax, 3
	je .vercall

	cmp ax, 4
	je .graphicsULRK

	cmp ax, 5
	je .inputcall

	jmp .returncall

.printsyscall:
	call print
	jmp .returncall

.clearsyscall:
	mov [consattr], bx
	call reset
	jmp .returncall

.readfilecall:
	mov cx, si
	mov ax, bx
	shl ax, 1

	mov si, [fsstart]
	add si, ax

	mov bx, cx
	mov al, [si]
	mov cl, [si+1]

	mov ch, 0
	mov dh, 0
	mov dl, 0x80
	mov ah, 2
	int 0x13

	jmp .returncall

.vercall:
	cmp bx, 0
	je .osvercall

	cmp bx, 1
	je .kernelvercall
	
	jmp .endvercall

.osvercall:
	mov bx, osver
	jmp .endvercall
.kernelvercall:
	mov bx, kernelver
.endvercall:
	jmp .returncall

; This is the start of the graphics ULRK basic graphics driver section. It's very confusing.
; When I wrote the driver, only I and God understood how it works.
; Now, only I understand how it works because I do not know how to properly explain it to even God themselves.
; You can try asking AI, but it won't understand this masterpiece.

.graphicsULRK:
	cmp bx, 0
	je .enablegraphics

	cmp bx, 1
	je .disablegraphics

	cmp bx, 2
	je .setcol

	cmp bx, 3
	je .setpx

	cmp bx, 4
	je .fillbg

	cmp bx, 5
	je .setsecondcol

	cmp bx, 6
	je .setpxsecondcol

	jmp .returncall

.enablegraphics:
	mov ax, 0x0013
	int 0x10
	jmp .returncall

.disablegraphics:
	mov ax, 0x0003
	int 0x10
	jmp .returncall

.setcol:
	mov [colourindex], cl
	jmp .returncall

.setpx:
	mov ax, 320 ; params are x in cx and y in dx
	mul dx
	add ax, cx
	mov di, ax

	mov ax, 0xA000
	mov es, ax

	mov al, [colourindex]
	mov [es:di], al

	jmp .returncall

.fillbg:
	mov ax, 0xA000
	mov es, ax
	mov di, cx

	mov cx, dx
	cld
	mov al, [colourindex]

	rep stosb
	jmp .returncall

.setsecondcol:
	mov [secondcolour], cl
	jmp .returncall

.setpxsecondcol:
	mov ax, 320 ; params are x in cx and y in dx
	mul dx
	add ax, cx
	mov di, ax

	mov ax, 0xA000
	mov es, ax

	mov al, [secondcolour]
	mov [es:di], al

	jmp .returncall

; This is where graphicULRK code ends. Sane stuff starts again.

.inputcall:
	call input
	jmp .returncall

.yieldcall:
	pop si
	pop es

	mov ax, 4
	mul [crntprocid]
	mov bx, ax
	add bx, processes

	mov [bx], si
	mov [bx+2], es

	mov si, [bx+4]
	mov ax, [bx+6]
	mov es, ax

	inc [crntprocid]
	mov ax, [proccount]
	cmp ax, [crntprocid]
	jle .returncall

	mov [crntprocid], 0
	mov si, [processes]
	mov ax, [processes+2]
	mov es, ax
	push es
	push si

	jmp .returncall

.returncall:

	mov ax, [rega]
	mov cx, [regc]
	mov dx, [regd]

	mov sp, [regsp]
	mov bp, [regbp]
	mov di, [regdi]

	mov cs, [regcs]
	mov ds, [regds]
	mov ss, [regss]

	ret
