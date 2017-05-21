proc DrawWall
	
	mov al, 2
	mov bh, 0h
	mov cx, 60
	mov dx, 0
	mov [sizeX], 140
	mov [sizeY], 200
	
	call draw
	
	mov al, 0
	mov bh, 0h
	mov cx, 70
	mov dx, 10
	mov [sizeX], 120
	mov [sizeY], 180
	
	call draw
	
	ret
endp DrawWall

proc checkRow
	push ax
	push bx
	push cx
	push dx
	
	mov cx, 70
	mov dx, 180
	
	;mov [loopcount1], 17
	@@loopa:
		mov [loopcount2], 12
		@@loopb:
			mov bh, 0
			mov ah,0Dh
			int 10h ; return al the pixel value read
		
			cmp al, 0h
			jz dontDelete	
			
			add cx, 10
			dec [loopcount2]
			cmp [loopcount2], 0
			jnz @@loopb
		
			mov [delayT] , 2h
			sub dx, 10
			call sleep
			call DeleteRow
			add dx, 10
		
		dontDelete:
		
		sub dx, 10
		mov cx, 70
	cmp dx, 10
	jnz @@loopa		
	
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret
endp checkRow

proc DeleteRow
	
	push ax
	push bx
	push cx
	push dx
	
	mov cx, 70
	;mov dx, 170
	;xor bx, bx
	
	;mov [loopcount1], 17
	@@loopa:
		mov [loopcount2], 12
		@@loopb:
		
			mov bh, 0
			mov ah,0Dh
			int 10h ; return al the pixel value read
			
			mov [sizeX], 10
			mov [sizeY], 10
			
			push cx dx
			add dx, 10
			call draw
			pop dx cx
			
			add cx, 10
			dec [loopcount2]
			cmp [loopcount2], 0
			jnz @@loopb
		
		sub dx, 10
		sub cx, 120
		dec [loopcount1]
		cmp dx, 10
		jnz @@loopa
	
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret

endp DeleteRow

;	[]	-	12 * 18	,		(X, Y) = (70, 10)