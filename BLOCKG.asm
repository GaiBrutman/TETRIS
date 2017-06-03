
proc Flip
	
;{
	;start proc {
		push bp
		mov  bp, sp
		number equ [word ptr bp + 4]
		
		push ax
		push bx
		push cx
		push dx
	;}
	
	;code {
		xor dx, dx
		mov ax, number
		mov number, 0
		
		@@row_loop: ;{
			xor cx, cx
			
			@@col_loop: ;{
				mov bx, ax
				shr bx, cl
				and bx, 1
				
				push ax
				push cx
				
				mov  ax, 4
				mul  cl
				add  ax, 3
				sub  ax, dx
				mov  cl, al
				
				shl bx, cl
				add number, bx
				
				pop cx
				pop ax
				
				inc cl
				cmp cl, 4
				jnz @@col_loop
			;}
			
			shr ax, 4
			inc dx
			cmp dx, 4
			jnz @@row_loop
		;}
	;}
	
	@@end_proc: ;{
		
		call flipfix
		
		pop dx
		pop cx
		pop bx
		pop ax
		
		
		
		pop bp
		ret
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

proc Draw
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
		
endp Draw

proc DrawBlock
	push ax
	
	cmp al, 0
	jz	noColor
	
	mov [sizeX], 10
	mov [sizeY], 10
	add al, 7
	call Draw
	
	mov [sizeX], 9
	mov [sizeY], 9
	sub al, 7
	call Draw
	
	
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
	call Draw
	
	pop ax
	ret
endp DrawBlock

proc DrawPiece
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
			jc @@toDraw
			@@notToDraw:
			jmp @@again
			@@toDraw:
			
			push cx dx
			call DrawBlock
			pop dx cx
			
			@@again:
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
endp DrawPiece

proc UnDraw
	push [word ptr color]
	mov [color], 0h
	call DrawPiece
	pop [word ptr color]
	ret
endp UnDraw