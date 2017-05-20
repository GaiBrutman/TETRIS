proc Randomize
RANDGEN:         ; generate a rand no using the system time
RANDSTART:
	mov ah, 00h  ; interrupts to get system time
	int 1ah      ; CX:DX now hold number of clock ticks since midnight      

	mov  ax, dx
	xor  dx, dx
	mov  cx, 7
	div  cx       ; here dx contains the remainder of the division - from 0 to 6
	
	ret
endp Randomize

proc drawNext
	push [word ptr color]
	push di
	push [x]
	push [y]
	
;	0123456789	
;
;0	@@@@@@@@@@
;1	@		 @
;2	@		 @
;3	@  @@@@  @
;4	@  @@@@  @
;5	@  @@@@  @
;6	@  @@@@  @
;7	@		 @
;8	@		 @
;9	@@@@@@@@@@
	
	
	mov al, 2
	mov bh, 0h
	mov cx, 245
	mov dx, 30
	mov [sizeX], 60
	mov [sizeY], 60
	
	call draw
	
	mov al, 0
	mov bh, 0h
	mov cx, 250
	mov dx, 35
	mov [sizeX], 50
	mov [sizeY], 50
	
	call draw
	
	; AH=2h: Set cursor position
	mov dl, 29 ; Column
	mov dh, 2 ; Row
	mov bx, 0 ; Page number, 0 for graphics modes
	mov ah, 2h
	int 10h

	; AH=9h: Print string
	mov dx, offset nextStr
	mov ah, 9h
	int 21h
	
	mov [x], 255
	mov [y], 40
		
	mov bl, [nextColor]
	
	mov di, [nextForm]
	mov [color], bl
	
	call undraw
	call DrawBlock
	
	pop [y]
	pop [x]
	pop di
	pop [word ptr color]
	ret
endp drawNext