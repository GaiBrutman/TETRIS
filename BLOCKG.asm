
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

proc undraw
	push [word ptr color]
	mov [color], 0h
	call DrawBlock
	pop [word ptr color]
	ret
endp undraw