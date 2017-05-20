; name: Gai Brutman
; *ASSEMBLY TETRIS*

IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; <name>	<size>		<value>
;			db/dw/dd	?/*

	GB		dw		00ffh, 0ff00h, 0ffffh, 0000h, 00ffh, 8000h, 0000h
	
	R			db		00h, 00h, 00h, 0ffh, 7fh, 0ffh, 0ffh

	loopcount1	db	?
	loopcount2	db	?

	nextStr	db		'NEXT FORM$'

	Clock equ es:6Ch
	x 		dw 		0
	y 		dw 		0
	color 	db		4
	nextColor	db	1
	sizeX	dw		?
	temp	dw		?
	tempForm	dw		?

	
	sizeY	dw		?
	count	dw		0h
	adress  dw		?
	check	dw		0h
	loopTimes1	db	4
	loopTimes2	db	4						;0000
											;0000
											;1000
											;1110
	timeToCheck	db		0
	
	form	dw		?	
	nextForm	dw		0
	
;											J									S									I									Z									T									L									O
	formwz	dw		0000000010001110b, 0000000001101100b, 0000000000001111b, 0000000011000110b, 0000000001001110b, 0000000000101110b, 0000000011001100b
	
	flipedForm	dw	?
	
; --------------------------
CODESEG

proc bitPlacer
		push cx
;	push [loopcount2]
	
	mov ax, 8000h

	mov cl, [loopcount1]
	cmp cl, 0h
	jz z1
	inc cl
	
	@@loopa:
		shr ax, 4
	dec cl
	cmp cl, 0h
	jnz @@loopa
	
	z1:
		
	mov cl, [loopcount2]
	cmp cl, 0h
	jz z2
	
	@@loopb:
		shr ax, 1
	dec cl
	cmp cl, 0h
	jnz @@loopb
	
	z2:
	
;	pop [loopcount2]
	pop cx	
	ret
endp bitPlacer

proc Randomize
RANDGEN:         ; generate a rand no using the system time
RANDSTART:
	mov ah, 00h  ; interrupts to get system time
	int 1ah      ; CX:DX now hold number of clock ticks since midnight      

	mov  ax, dx
	xor  dx, dx
	mov  cx, 7
	div  cx       ; here dx contains the remainder of the division - from 0 to 6
	
	ret
endp Randomize

proc sleep
	push cx
	push dx
	push bx
	
	mov cx, 2h
	mov	dx, 49f0h
	mov ah, 86h
	int 15h
	
	pop bx
	pop dx
	pop cx
	
	ret
endp sleep

proc checkColor
	pop [adress]
	
	pop [check]
	push [form]
	
	mov bh,0h
	mov cx,[x]
	mov dx,[y]
	add dx, 10
;	add dx, [sizeY]
	
;	mov bl, [byte ptr sizeX]
	
	mov [loopcount1], 0
	@@loopa:
		 mov [loopcount2], 0
		@@Loopb:
			shl [form], 1
			jc Try
			jmp NotTry
			Try:
			call bitPlacer
			pop [tempForm]
			test [tempForm], ax
			push [tempForm]
			jnz NotTry
			
			CheckPLZ:
				mov ah,0Dh
				int 10h
				cmp al, 0h
				jnz collides
			
		NotTry:
		inc [loopcount2]
		add cx, 10
		cmp	[loopcount2], 4h
		jnz @@Loopb
	
	inc [loopcount1]
	add dx, 10
	sub cx, 40
	cmp [loopcount1], 4h
	jnz @@loopa
	jmp notCollides

	collides:
		mov [word ptr check], 1h
	notCollides:
	
	pop [form]
	push [adress]
	ret
endp checkColor

proc Flip
	
	;{
	;START PROC {
		PUSH BP
		MOV  BP, SP
		NUMBER EQU [WORD PTR BP + 4]
		
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	;}
	
	;CODE {
		XOR DX, DX
		MOV AX, NUMBER
		MOV NUMBER, 0
		
		@@ROW_LOOP: ;{
			XOR CX, CX
			
			@@COL_LOOP: ;{
				MOV BX, AX
				SHR BX, CL
				AND BX, 1
				
				PUSH AX
				PUSH CX
				
				MOV  AX, 4
				MUL  CL
				ADD  AX, 3
				SUB  AX, DX
				MOV  CL, AL
				
				SHL BX, CL
				ADD NUMBER, BX
				
				POP CX
				POP AX
				
				INC CL
				CMP CL, 4
				JNZ @@COL_LOOP
			;}
			
			SHR AX, 4
			INC DX
			CMP DX, 4
			JNZ @@ROW_LOOP
		;}
	;}
	
	@@END_PROC: ;{
		POP DX
		POP CX
		POP BX
		POP AX
		
		
		
		POP BP
		RET
	;}
;}
	
endp Flip

proc draw
	; ip | parameter1
	; ^
	
	mov bx, [sizeX]
	mov [temp], bx
	
	add [sizeX], cx
	add [sizeY], dx

	mov ah, 0ch
	
	loopa:
		loopb:
			int 10h
			inc	cx
			cmp [sizeX], cx
			jnz	loopb
		inc dx
		sub cx, [temp]
		cmp [sizeY], dx
		jnz	loopa
	
	ret
		
endp draw

proc DrawBlock
	; ip | parameter1
	; ^
	push ax
	push bx
	push cx
	push dx
	
	push bx
	
	cmp [flipedForm], 0h
	
	jnz Flipped
	
	notFlipped:
	
	mov bx, [offset formwz + di]
	
	mov [form], bx
	
	jmp continue
	
	Flipped:
	
	mov bx, [flipedForm]
	
	mov [form], bx
	
	continue:
	
	pop bx
	
	push [form]
	
	mov al, [color]
	mov bh, 0h

	push [x]
	push [y]
	
	mov [loopTimes1], 4
	loopDraw1:
		mov [loopTimes2], 4
		loopDraw2:
			shl [form], 1
			jc toDrawS
			notToDrawS:
			jmp againS
			toDrawS:
			mov [sizeX], 10
			mov [sizeY], 10
			mov cx, [x]
			mov dx, [y]
			call draw
			againS:
			add [x], 10
			dec [loopTimes2]
			cmp [loopTimes2], 0
			jnz loopDraw2
		
		add [y], 10
		sub [x], 40
		dec [loopTimes1]
		cmp [loopTimes1], 0
		jnz loopDraw1
		
	pop [y]
	pop [x]
	pop [form]
	
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret
endp DrawBlock

proc DrawWall
	
	mov al, 2
	mov bh, 0h
	mov cx, 50
	mov dx, 0
	mov [sizeX], 180
	mov [sizeY], 200
	
	call draw
	
	mov al, 0
	mov bh, 0h
	mov cx, 60
	mov dx, 10
	mov [sizeX], 160
	mov [sizeY], 180
	
	call draw
	
	ret
endp DrawWall

proc undraw
	push [word ptr color]
	mov [color], 0h
	call DrawBlock
	pop [word ptr color]
	ret
endp undraw

proc drawNext
	push [word ptr color]
	push di
	push [x]
	push [y]
	
;	0123456789	
;
;0	@@@@@@@@@@
;1	@		 @
;2	@		 @
;3	@  @@@@  @
;4	@  @@@@  @
;5	@  @@@@  @
;6	@  @@@@  @
;7	@		 @
;8	@		 @
;9	@@@@@@@@@@
	
	
	mov al, 2
	mov bh, 0h
	mov cx, 245
	mov dx, 30
	mov [sizeX], 60
	mov [sizeY], 60
	
	call draw
	
	mov al, 0
	mov bh, 0h
	mov cx, 250
	mov dx, 35
	mov [sizeX], 50
	mov [sizeY], 50
	
	call draw
	
	; AH=2h: Set cursor position
	mov dl, 30 ; Column
	mov dh, 2 ; Row
	mov bx, 0 ; Page number, 0 for graphics modes
	mov ah, 2h
	int 10h

	; AH=9h: Print string
	mov dx, offset nextStr
	mov ah, 9h
	int 21h
	
	mov [x], 255
	mov [y], 40
		
	mov bl, [nextColor]
	
	mov di, [nextForm]
	mov [color], bl
	
	call undraw
	call DrawBlock
	
	pop [y]
	pop [x]
	pop di
	pop [word ptr color]
	ret
endp drawNext

;------------------------------------------
;Modify the palette of one color.
;BX = color number
;ch = green 
;cl = blue 
;dh = red 
;------------------------------------------
proc aditColor
	push ax
	
	mov bh,0
	mov ax,1007h
	int 10h
	mov bl,bh
	mov bh,0
	mov ax,1010h
	int 10h
	
	pop ax
	ret
endp aditColor

proc aditPallette
	xor bx, bx
	
	mov bh, 0
	@@loopa:
		mov cx, [offset GB+ bx]
		mov dh, [offset R+ bx]
		push bx
		call aditColor
		pop bx
		inc bh
		cmp bh, 7h
		jnz	@@loopa
		
;	mov bl, 1
;	mov cx, [GB]
;	mov dh, [R]
;	call aditColor
	
	ret
endp aditPallette

start:
;{	
	mov ax, @data
	mov ds, ax

	mov ax, 13h
	int 10h
	
	;call aditPallette
	
	call DrawWall
	
	newDraw:
	mov [flipedForm], 0h
	mov [timeToCheck], 0h
	
	mov [x], 120
	mov [y], 10
	
	; random form and color
		mov bl, [nextColor]
		
		mov di, [nextForm]
		mov [color], bl
		
		call Randomize
;		PaperAirplane@@2

		mov al, dl
		inc al
		mov [nextColor], al
	
		xor ax, ax
		mov al, 2
		mul dl		; now ax contains the duplicating
		mov [nextForm], ax
	
	
	call drawNext
	
	drawFirst:
	
	call DrawBlock
	
	WaitForData :
	
	push ax
	push bx
	push cx
	push dx
	push [sizeX]
	push [sizeY]
	
	mov [sizeX], 40
	mov [sizeY], 40
	mov [check], 0h
	push offset check
	call checkColor
	cmp [check], 1h
	jz collided
	jmp didntCollide
collided:
	mov [count], 0h
	inc [timeToCheck]
	jmp WHATEVER
	
didntCollide:
	mov [timeToCheck], 0h

WHATEVER:
	
	pop [sizeY]
	pop [sizeX]
	pop dx
	pop cx
	pop bx
	pop ax
	
	cmp [count], 5
	jz movdown
	inc [count]
	jmp notmovdown
	
	movdown:
	mov [count], 0h
	call undraw
	add [y], 10

	call DrawBlock
	
	notmovdown:
	
	in al, 64h ; Read keyboard status port
	cmp al, 10b ; Data in buffer ?
	je WaitForData ; Wait until data available
	in al, 60h ; Get keyboard data
	cmp al, 1h ; Is it the ESC key ?
	jne notExit
	mov ax,3h
	int 10h	
	mov ax, 4c00h
	int 21h
	notExit:
	cmp al, 04bh ; Is it the LEFT key ?
	je left
	cmp al, 04dh ; Is it the RIGHT key ?
	je right
	cmp al, 48h ; Is it the UP key ?
	je up
	cmp al, 50h ; Is it the DOWN key ?
	je down

	call sleep

	cmp [timeToCheck], 4h
	jz toNewDraw
	
	jmp WaitForData
	
	toNewDraw:
	jmp newDraw
	
	left:
	
		call undraw
		sub [x], 10
	
		call DrawBlock

		call sleep
	
		cmp [timeToCheck], 4h
		jz toNewDraw
		
		jmp WaitForData
	
	right:
		
		call undraw
		add [x], 10
	
		call DrawBlock
		
		call sleep
		
		cmp [timeToCheck], 4h
		jz toNewDraw
		
		jmp WaitForData
	
	up:
	
		call undraw
		
		push [form]
		call Flip
		pop [flipedForm]
	
		call DrawBlock
	
		call sleep
		
		;cmp [timeToCheck], 4h
		;jz toNewDraw

		jmp WaitForData
	
	down:
		cmp [timeToCheck], 0h
		ja toNewDraw
		
		call undraw
		add [y], 10

		call DrawBlock
	
		call sleep

		jmp WaitForData

exit:
	mov ax,3h
	int 10h
	
	mov ax, 4c00h
	int 21h
END start
;}
