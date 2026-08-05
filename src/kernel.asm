[BITS 32]
[org 0x8600]

mov ax, 0x10
mov ds, ax
mov es, ax
mov fs, ax
mov gs, ax
mov ss, ax
mov esp, stacktop

jmp kernelstart

; memory sections

bootstart dd 0x7E00
bootend dd 0x81FF

kernstart dd 0x8600
syscallstart dd 0x8800
kernend dd 0xADFF

microglstart dd 0xAE00
microglend dd 0xBBFF

fsstart dd 0xBD00
fsend dd 0xBFFF

userstart dd 0xC000

kernloadingtxt db "[LP 0x07] RKSI: ATTEMPTING KERNEL LOAD", 10, 0
syscalltest db "[LP 0x08] RKSI: KERNEL LOADED SUCCESSFULLY", 10, 0
lpid dw 0x09

kernelstart:
	mov [txtcursor], bx
	mov [txtcursor+2], cx

	mov esi, kernloadingtxt
	call print

	mov eax, 0
	mov esi, syscalltest
	call 0x8800

	hlt

	mov esi, [microglstart]
	mov ebx, 0
	mov eax, 2
	call 0x8800

	mov esi, [userstart]
	mov ebx, 1
	mov eax, 2
	call 0x8800

	call far [userstart]

	hlt

times 512 - ($ - $$) db 0

kernel:

syscalls:
	mov [rega], eax
	mov [regc], ecx
	mov [regd], edx

	mov [regsp], esp
	mov [regbp], ebp
	mov [regdi], edi

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
	mov ecx, esi
	mov eax, ebx
	shl eax, 1

	mov esi, [fsstart]
	add esi, eax

	mov ebx, ecx
	mov eax, [esi] ; sec count
	mov ecx, [esi+4] ; start sec

	mov esi, ebx

	call idedriver

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
; Now, neither of us knows how it works.
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
	;mov ax, 0x0013
	;int 0x10
	jmp .returncall

.disablegraphics:
	;mov ax, 0x0003
	;int 0x10
	jmp .returncall

.setcol:
	mov [colourindex], cl
	jmp .returncall

.setpx:
	mov eax, 320 ; params are x in cx and y in dx
	mul edx
	add eax, ecx
	mov edi, 0xA0000
	add edi, eax

	mov al, [colourindex]
	mov [edi], al

	jmp .returncall

.fillbg:
	mov edi, 0xA0000
	add edi, ecx

	mov ecx, edx
	cld
	mov al, [colourindex]

	rep stosb
	jmp .returncall

.setsecondcol:
	mov [secondcolour], cl
	jmp .returncall

.setpxsecondcol:
	mov eax, 320 ; params are x in cx and y in dx
	mul edx
	add eax, ecx
	mov edi, 0xA0000
	add edi, eax

	mov al, [secondcolour]
	mov [edi], al

	jmp .returncall

; This is where graphicULRK code ends. Sane stuff starts again.

.inputcall:
	;call input
	jmp .returncall

.yieldcall:
	pop esi

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

	push esi

	jmp .returncall

.returncall:

	mov eax, [rega]
	mov ecx, [regc]
	mov edx, [regd]

	mov esp, [regsp]
	mov ebp, [regbp]
	mov edi, [regdi]

	ret


clear:
	call reset
	mov [txtcursor], 0
	mov [txtcursor+2], 0
	ret

reset:
	mov edi, 0xB8000

	mov ah, [consattr]
	mov al, ' '
	mov ecx, 2000

	rep stosw
	ret

resetcursorpos:
	mov dx, 0x3D4
	mov al, 0x0F
	out dx, al

	mov eax, edi
	shr eax, 1

	mov dx, 0x3D5
	out dx, al

	mov dx, 0x3D4
	mov al, 0x0E
	out dx, al

	mov dx, 0x3D5
	mov eax, edi
	shr eax, 1
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
	mov edi, 0
	mov di, ax
	add edi, 0xB8000
	mov [edi], cx
	inc [txtcursor]
	cmp [txtcursor], 80
	jl .end

	mov [txtcursor], 0
	inc [txtcursor+2]

.end:
	call resetcursorpos
	ret

print:
	mov eax, 80
	mov ebx, 0
	mov bx, [txtcursor+2]
	mul ebx
	add ax, [txtcursor]
	mov ebx, 2
	mul ebx
	mov edi, eax
	call resetcursorpos
	add edi, 0xB8000

.loop:
	mov ah, [consattr]
	mov al, [esi]
	cmp al, 0
	je .done
	cmp al, 10
	je .newline

	mov [edi], ax
	inc esi
	add edi, 2
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

	mov eax, 80
	mov ebx, 0
	mov bx, [txtcursor+2]
	mul ebx
	add ax, [txtcursor]
	mov ebx, 2
	mul ebx
	mov edi, eax

	call resetcursorpos
	add edi, 0xB8000

	inc esi
	jmp .loop

.done:
	ret

;input:
;	mov ah, 0x00
;	int 0x16
;	ret

idedriver:
	sub ecx, 1
	mov [tmp], eax
	mov [tmp2], 0
	mov [tmp4], ecx

.ideloop:
	mov eax, [tmp]
	sub eax, [tmp2]
	cmp eax, 256
	mov [tmp5], eax
	jl .aftersetting
	
.setide256:
	mov eax, 0
	mov dword [tmp5], 256

.aftersetting:
	mov [tmp3], eax

	mov edx, 0x01F2
	out dx, al

	mov eax, [tmp4]
	mov edx, 0x01F3
	out dx, al

	shr eax, 8
	mov edx, 0x01F4
	out dx, al

	shr eax, 8
	mov edx, 0x01F5
	out dx, al

	mov al, 0b10110000
	shr eax, 4
	mov edx, 0x01F6
	out dx, al

	mov edx, 0x01F7
	mov al, 0x20
	out dx, al

.readloop:
	in al, dx
	test al, 0x80
	jnz .readloop
	test al, 0x08
	jz .readloop

	mov edi, esi
	mov eax, 256
	mul [tmp5]
	mov ecx, eax
	cld
	mov edx, 0x01F0
	rep insw

	shl eax, 2
	add esi, eax

	mov eax, [tmp5]
	add [tmp2], eax
	cmp [tmp3], 0
	je .ideloop

	ret

txtcursor dw 0, 0

crntprocid db 0

colourindex db 0
secondcolour db 0

consattr db 0x1F
osver db "LiberationOS-26.0", 0
kernelver db "0.0.1-ULRK-x86", 0

tmp dd 0
tmp2 dd 0
tmp3 dd 0
tmp4 dd 0
tmp5 dd 0

rega dd 0, 0, 0, 0
regc dd 0, 0, 0, 0
regd dd 0, 0, 0, 0

regsp dd 0, 0, 0, 0
regbp dd 0, 0, 0, 0
regdi dd 0, 0, 0, 0

processes dd \
	0xC0000, \
	0x00000, \
	0x00000, \
	0x00000, \

proccount db 0

stack: resb 4096
stacktop:

times 10240 - ($ - $$) db 0

