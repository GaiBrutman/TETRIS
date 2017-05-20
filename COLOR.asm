;------------------------------------------
;Modify the palette of one color.
;BX = color number
;dh = red 
;ch = green 
;cl = blue 
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
	push si
	
	xor bx, bx
	xor si, si
	
	mov bl, 1
	mov si, 0
	@@loopa:
		mov dh, [offset RGB+ si]
		inc si
		mov ch, [offset RGB+ si]
		inc si
		mov cl, [offset RGB+ si]
		
		
		call aditColor
		
		inc bl
		inc si
		cmp bl, 8h
		jnz	@@loopa
		
	mov bl, 0
	xor cx, cx
	xor dh, dh
	call aditColor

	pop si
	
	ret
endp aditPallette