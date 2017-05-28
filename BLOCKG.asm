
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
		
		call FlipFix
		
		POP DX
		POP CX
		POP BX
		POP AX
		
		
		
		POP BP
		RET
	;}
;}
	
endp Flip

proc FlipFix
	
@@loopa:
	test NUMBER, 0fh
	jnz stop
	shr NUMBER, 4
	jmp @@loopa
	
	stop:
	ret
	
endp FlipFix

proc draw
	; ip | parameter1
	; ^
	
	push cx dx
	
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
		
	pop dx cx
	
	ret
		
endp draw

proc DrawB
	push ax
	
	cmp al, 0
	jz	noColor
	
	mov [sizeX], 10
	mov [sizeY], 10
	add al, 7
	call draw
	
	mov [sizeX], 9
	mov [sizeY], 9
	sub al, 7
	call draw
	
	
	mov al, 15
	
	inc cx
	inc dx
	
	mov ah, 0ch
	int 10h
	
	inc cx
	mov ah, 0ch
	int 10h
	
	dec cx
	inc dx
	mov ah, 0ch
	int 10h

	pop ax
	ret
	
	noColor:
	
	mov [sizeX], 10
	mov [sizeY], 10
	call draw
	
	pop ax
	ret
endp DrawB

proc DrawBlock
	; ip | parameter1
	; ^
	push ax
	push bx
	push cx
	push dx
	
	push bx
	
	cmp [flipedForm], 2h
	jz continue
	
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
	mov cx, [x]
	mov dx, [y]

	mov [loopcount1], 4
	loopDraw1:
		mov [loopcount2], 4
		loopDraw2:
			shl [form], 1
			jc toDrawS
			notToDrawS:
			jmp againS
			toDrawS:
			;mov [sizeX], 10
			;mov [sizeY], 10
			
			push cx dx
			call drawB
			pop dx cx
			
			againS:
			add cx, 10
			dec [loopcount2]
			cmp [loopcount2], 0
			jnz loopDraw2
		
		add dx, 10
		sub cx, 40
		dec [loopcount1]
		cmp [loopcount1], 0
		jnz loopDraw1
		
	pop [form]
	
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret
endp DrawBlock

proc undraw
	push [word ptr color]
	mov [color], 0h
	call DrawBlock
	pop [word ptr color]
	ret
endp undraw