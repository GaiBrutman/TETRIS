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

;	__________