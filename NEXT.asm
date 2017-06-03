proc Randomize
RANDGEN:         ; generate a rand no using the system time
RANDSTART:
	mov ah, 00h  ; interrupts to get system time
	int 1ah      ; CX:DX now hold number of clock ticks since midnight      

	mov  ax, dx
	xor  dx, dx
	mov  cx, 7
	div  cx       ; here dx contains the remainder of the division - from 0 to 6
	mov ax, dx
	ret
endp Randomize

proc Sound

	ret
endp Sound

proc DrawNext
	push [word ptr color]
	push di
	push [x]
	push [y]	
	
	mov al, 2
	mov bh, 0h
	mov cx, 235
	mov dx, 30
	mov [sizeX], 60
	mov [sizeY], 60
	
	call Draw
	
	mov al, 0
	mov bh, 0h
	mov cx, 240
	mov dx, 35
	mov [sizeX], 50
	mov [sizeY], 50
	
	call Draw
	
	; AH=2h: Set cursor position
	mov dl, 28 ; Column
	mov dh, 2 ; Row
	mov bx, 0 ; Page number, 0 for graphics modes
	mov ah, 2h
	int 10h

	; AH=9h: Print string
	mov dx, offset nextStr
	mov ah, 9h
	int 21h
	
	mov [x], 245
	mov [y], 40
		
	mov bl, [nextColor]
	
	mov di, [nextForm]
	mov [color], bl
	
	call UnDraw
	call DrawPiece
	
	pop [y]
	pop [x]
	pop di
	pop [word ptr color]
	ret
endp DrawNext

proc ShowScore

	mov dx, 0d1fh ; Row, Column
	mov bx, 0 ; Page number, 0 for graphics modes
	mov ah, 2h
	int 10h
	
	mov dx, offset ScoreStr
	mov ah, 9h
	int 21h
	
	mov dx, 0f1fh ; Row, Column
	mov ah, 2h
	int 10h
	
	push [score]
	call PrintNum
	
	mov dx, 111fh ; Row, Column
	mov ah, 2h
	int 10h
	
	mov dx, offset LinesStr
	mov ah, 9h
	int 21h
	
	mov dx, 131fh ; Row, Column
	mov ah, 2h
	int 10h
	
	push [lines]
	call PrintNum
	
	mov dx, 151fh ; Row, Column
	mov ah, 2h
	int 10h
	
	mov dx, offset LevelStr
	mov ah, 9h
	int 21h
	
	mov dx, 171fh ; Row, Column
	mov ah, 2h
	int 10h
	
	mov al, [level]
	xor ah, ah
	push ax
	call PrintNum
		
	ret
endp ShowScore