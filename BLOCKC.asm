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