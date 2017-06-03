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

proc sounds
	out     43h, al         ;  note.
	
	mov ax, [offset notes + bx] 
	
   ; mov     ax, [note]        ; Frequency number (in decimal)
                                ;  for middle C.
	out     42h, al         ; Output low byte.
	mov     al, ah          ; Output high byte.
	out     42h, al 
	in      al, 61h         ; Turn on note (get value from
                                ;  port 61h).
	or      al, 00000011b   ; Set bits 1 and 0.
	out     61h, al         ; Send new value.
	mov     bx, 30         ; Pause for duration of note.
pausee1:
	mov     cx, 65535
pausee2:
	dec     cx
	jne     pausee2
	dec     bx
	jne     pausee1
	in      al, 61h         ; Turn off note (get value from
                                ;  port 61h).
	and     al, 11111100b   ; Reset bits 1 and 0.
	out     61h, al         ; Send new value.
		
;	pop dx cx bx ax
	ret
endp sounds


proc sleep
	pop [adress]
	pop cx
	
	@@loopa:
		push cx
		
		mov cx, 20000
		cmp [counter], 100
		jz dontLoop
		@@loopb:
		;nop
		loop @@loopb
	dontLoop:
		inc [counter]
		cmp [counter], 150
		jnz @@coninue
		mov [counter], 0
		call music
		@@coninue:
		pop cx
	loop @@loopa

	push [adress]
	ret
endp sleep

proc music
	push ax bx cx dx
		mov bx, [np]
		
		call sounds
		add [np], 2
		mov bx, [np]
		cmp bx, [offset notes]
		jz startOver
	
	
	jmp dontStartOver
	startOver:
	mov [np], 2
	
	dontStartOver:
	pop dx cx bx ax
	ret
endp music

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