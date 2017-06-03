proc BitPlacer
		push cx
	
	mov ax, 8000h

	mov cl, [loopcount1]
	cmp cl, 0h
	jz z1
	
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
	
	cmp [checkType], 1	;	0	- left,	1 - down,		2 - right
	ja	@@rightShift
	jb	@@leftShift
	
	@@downShift:
	shr ax, 4
	
	jmp @@done
	@@rightShift:
	shr ax, 1
	
	jmp @@done
	@@leftShift:
	shl ax, 1
	
	@@done:
	
;	pop [loopcount2]
	pop cx	
	ret
endp BitPlacer

proc Sleep
	pop [adress]
	pop cx
	
	@@loopa:
		push cx
		
		mov cx, 20000
		@@loopb:
		nop
		loop @@loopb
		pop cx
	loop @@loopa

	push [adress]
	ret
endp Sleep

proc CheckColor
	;		Checks If The Piece Collides With Something
	pop [adress]
	
	pop [check]
	push [form]
	
	mov bh,0h
	mov cx,[x]
	mov dx,[y]
	
	cmp [checkType], 1	;	0	- left,	1 - down,		2 - right
	ja	@@rightShift
	jb	@@leftShift
	
	@@downShift:
	add dx, 10
	
	jmp @@done
	@@rightShift:
	add cx, 10
	
	jmp @@done
	@@leftShift:
	dec cx
	
	@@done:
	
	mov [loopcount1], 0
	@@loopa:
		 mov [loopcount2], 0
		@@Loopb:
			shl [form], 1
			jc Try
			jmp NotTry
			Try:
			call BitPlacer
			pop [tempForm]
			test [tempForm], ax
			push [tempForm]
			jnz NotTry
			
			CheckPLZ:
				mov ah,0Dh
				int 10h
				cmp al, 0h
				jnz @@collides
			
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
	jmp @@notCollides

	@@collides:
		mov [word ptr check], 1h
	@@notCollides:
	
	pop [form]
	push [adress]
	ret
endp CheckColor

proc CheckFlip
	;		Checks If The Piece Can Flip Without Deleting Something
	pop [adress]
	
	pop [canFlip]
	
	push ax bx cx dx
	push [flipedForm]
	
	mov bh, 0h
	mov cx, [x]
	mov dx, [y]

	mov [loopcount1], 4
	@@loopa:
		mov [loopcount2], 4
		@@loopb:
			shl [flipedForm], 1
			jc @@check
			jmp @@again
			@@check:
				mov ah,0Dh
				int 10h
				cmp al, 0h
				jnz @@collides
			@@again:
			add cx, 10
			dec [loopcount2]
			cmp [loopcount2], 0
			jnz @@loopb
		
		add dx, 10
		sub cx, 40
		dec [loopcount1]
		cmp [loopcount1], 0
		jnz @@loopa
		
	jmp @@notCollides
	
	@@collides:
		mov [canFlip], 0h
		pop [flipedForm]
		pop dx cx bx ax
		push [adress]
		ret
	@@notCollides:
	mov [canFlip], 1h
	pop [flipedForm]
	pop dx cx bx ax
	push [adress]
	ret
	
	ret
endp CheckFlip