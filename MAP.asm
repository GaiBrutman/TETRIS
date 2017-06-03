proc PauseGame
	
	push ax bx cx dx
	
	call PauseSave
	
	mov cx, 100
	mov dx, 60
	mov [sizeX], 60
	mov [sizeY], 30
	mov al, 1
	call Draw

	mov dx, 090eh ; Row, Column
	mov bx, 0 ; Page number, 0 for graphics modes
	mov ah, 2h
	int 10h
	
	mov dx, offset PauseStr
	mov ah, 9h
	int 21h

	
   @@loopEnter:
	mov ah, 0
	int 16h
	cmp ah, 1Ch
	jne @@loopEnter
	
	call PauseDraw
	
	pop dx cx bx ax
	
	ret
endp PauseGame

proc PauseSave

	;		Saves The Color Value Before Printing On Top
	
	push ax bx cx dx
	
	mov bx, 0
	mov cx, 100
	mov dx, 60
	
	@@loopa:
		@@loopb:
			mov bh, 0
			mov ah,0Dh
			int 10h ; return al the pixel value read
		
			mov [offset save + bx], al
			
			inc bx
			add cx, 10
			cmp cx, 160
			jnz @@loopb
		
	add dx, 10
	mov cx, 100
	cmp dx, 90
	jnz @@loopa	
	
	
	pop dx cx bx ax
	
	ret
endp PauseSave

proc PauseDraw

	;		Prints The Color Value After Printing On Top
	
	push ax bx cx dx
	
	mov bx, 0
	mov cx, 100
	mov dx, 60
	
	@@loopa:
		@@loopb:
			push bx cx dx
			mov al, [offset save + bx]
			call DrawBlock
			pop dx cx bx
			
			inc bx
			add cx, 10
			cmp cx, 160
			jnz @@loopb
		
	add dx, 10
	mov cx, 100
	cmp dx, 90
	jnz @@loopa	
	
	
	pop dx cx bx ax
	
	ret
endp PauseDraw

proc DrawWall
	
	mov al, 2
	mov bh, 0h
	mov cx, 60
	mov dx, 0
	mov [sizeX], 140
	mov [sizeY], 200
	
	call Draw
	
	mov al, 0
	mov bh, 0h
	mov cx, 70
	mov dx, 10
	mov [sizeX], 120
	mov [sizeY], 180
	
	call Draw
	
	ret
endp DrawWall

proc CheckLose
	
	push ax
	push bx
	push cx
	push dx
	
	mov cx, 70
	mov dx, 20
	
	mov [loopcount1], 12
	@@loopa:
		mov bh, 0
		mov ah,0Dh
		int 10h ; return al the pixel value read
		
		cmp al, 0h
		jnz Lost	
			
		add cx, 10
		dec [loopcount1]
		cmp [loopcount1], 0
		jnz @@loopa
		
		pop dx
		pop cx
		pop bx
		pop ax
		
		ret
		
		Lost:	;	Continues To HighScore Screen
		
		call AddHighScore
		
		mov ax,3h
		int 10h
		
		call OpenFile
		call WriteToFile
		call CloseFile
		
		mov dx, offset loseStr
		mov ah, 9h
		int 21h
		
		mov dl, 0ah
		mov ah, 2h
		int 21h
		
		mov dx, offset T10Str
		mov ah, 9h
		int 21h
		
		mov dx, 0ah
		mov ah, 2h
		int 21h
		mov dx, 13
		mov ah, 2h
		int 21h
		
		
		call PrintHighScore
		
		mov ax, 4c00h
		int 21h
	
endp CheckLose

proc CheckRows
	push ax
	push bx
	push cx
	push dx
	
	@@again:
	
	mov cx, 70
	mov dx, 180
	
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
			
			sub dx, 10
			push [delayT]
			call Sleep
			call DeleteRow
			jmp @@again
		
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
endp CheckRows

proc DeleteRow
	
	push ax
	push bx
	push cx
	push dx
	
	add [score], 90
	inc [lines]
	
	call CheckLevel
	
	mov [note], 3416
	call Sound
	
	mov cx, 70
	
	@@loopa:
		mov [loopcount2], 12
		@@loopb:
		
			mov bh, 0
			mov ah,0Dh
			int 10h ; return al the pixel value read
			
			push cx dx
			add dx, 10
			call DrawBlock
			pop dx cx
			
			add cx, 10
			dec [loopcount2]
			cmp [loopcount2], 0
			jnz @@loopb
		
		sub dx, 10
		sub cx, 120
		cmp dx, 10
		jnz @@loopa
	
	pop dx
	pop cx
	pop bx
	pop ax
	
	ret

endp DeleteRow
