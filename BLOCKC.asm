proc bitPlacer
		push cx
;	push [loopcount2]
	
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
endp bitPlacer

proc sleep
	push cx
	push dx
	push bx
	
	mov cx, [delayT]
	mov	dx, 3000h
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