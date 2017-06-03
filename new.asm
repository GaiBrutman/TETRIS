start:
;{	
	mov ax, @data
	mov ds, ax

	mov ax, 13h
	int 10h
	
	push offset StartScreenName
	call PrintBmp
	
@@loopEnter:
	mov ah, 0
	int 16h
	cmp ah, 1Ch
	jne @@loopEnter
	
	mov ax, 13h
	int 10h

	push offset InstructionsName1
	call PrintBmp
	mov ah, 0 
	int 16h
	
	mov ax, 13h
	int 10h

	push offset InstructionsName2
	call PrintBmp
	mov ah, 0 
	int 16h
	
	call EnterLevel
	
	cmp [level], 1
	jz dontAdjust
	
	mov cl, [level]
	xor ch, ch
	loopLevel:
		call AdjustSpeed
	loop loopLevel
	
dontAdjust:

	
;	call OpenFile
;	call WriteToFile
;	call CloseFile
	
	call EditPallette
	
	call DrawWall
	
	newDraw:
	
	call CheckLose
	
	call CheckRows
	
	call ShowScore
	
	mov [flipedForm], 0h
	mov [timeToCheck], 0h
	
	mov [x], 120
	mov [y], 0
	
	; random form and color
		mov bl, [nextColor]
		
		mov di, [nextForm]
		mov [color], bl
		
		call Randomize
;		PaperAirplane@@2

		mov al, dl
		inc al
		mov [nextColor], al
		
		xor ax, ax
		mov al, 2
		mul dl		; now ax contains the duplicating
		mov [nextForm], ax
	
	
	call DrawNext
	
	drawFirst:
	
	call DrawPiece
	
	WaitForData :
	
	
	push ax
	push bx
	push cx
	push dx
	push [sizeX]
	push [sizeY]
	
	mov [check], 0h
	push offset check
	call CheckColor
	cmp [check], 1h
	jz collided
	jmp didntCollide
collided:
	cmp [timeToCheck], 0
	jnz @@continue
	@@continue:
	mov [count], 0h
	inc [timeToCheck]
	jmp WHATEVER
	
didntCollide:
	mov [timeToCheck], 0h

WHATEVER:
	
	pop [sizeY]
	pop [sizeX]
	pop dx
	pop cx
	pop bx
	pop ax
	
	cmp [count], 5
	jz movdown
	inc [count]
	jmp notmovdown
	
	movdown:
	mov [count], 0h
	call UnDraw
	add [y], 10
	call DrawPiece
	
	notmovdown:
	
	in al, 64h ; Read keyboard status port
	cmp al, 10b ; Data in buffer ?
	jne dontWait ; Wait until data available
	jmp WaitForData
	dontWait:
	in al, 60h ; Get keyboard data
	
	
	cmp al, 1h ; Is it the ESC key ?
	jne notExit
	mov ax,3h
	int 10h	
	mov ax, 4c00h
	int 21h
notExit:
	
	cmp al, 1dh ; Is it the Ctrl key ?
	jne notPouse
	call PauseGame
	
notPouse:
	cmp al, 04bh ; Is it the LEFT key ?
	je left
	
	cmp al, 04dh ; Is it the RIGHT key ?
	jne Nright
	jmp right
	
Nright:
	cmp al, 48h ; Is it the UP key ?
	jne Nup
	jmp up
	
Nup:
	cmp al, 50h ; Is it the DOWN key ?
	jne Ndown
	jmp down
	
Ndown:
	
	push [delayT]
	call Sleep

	cmp [timeToCheck], 4h
	jnz WaitFor
	jmp toNewDraw
	
	WaitFor:
	jmp WaitForData
	
	left:
		mov [checkType], 0
		mov [check], 0h
		push offset check
		call CheckColor
		mov [checkType], 1
		cmp [check], 1
		jz toWait
		
		call UnDraw
		sub [x], 10
	
		call DrawPiece
		
		toWait:
		cmp [delayT], 40
		jb toFast
		cmp [delayT], 70
		ja toSlow
		push [delayT]
		jmp skip
	toSlow:
	push 70
	jmp skip
	toFast:
		push 40
		skip:
		call Sleep
		cmp [timeToCheck], 4h
		jz toNewDraw
		jmp WaitForData
	
	
	right:
		
		mov [checkType], 2
		mov [check], 0h
		push offset check
		call CheckColor
		mov [checkType], 1
		cmp [check], 1
		jz toWait
		
		call UnDraw
		add [x], 10
	
		call DrawPiece
		
		jmp toWait
	
	toNewDraw:
	mov [note], 9121
	call Sound
	add [score], 10
	jmp newDraw
	
	up:
		call UnDraw
		
		push [form]
		call Flip
		pop [flipedForm]
	
		mov [canFlip], 0h
		push offset canFlip
		call CheckFlip
		cmp [canFlip], 0h
		ja dontFlip
		jmp doFlip
		dontFlip:
		mov [canFlip], 0h
		mov [flipedForm], 2h
				
	doFlip:

		call DrawPiece
		push 80
		call Sleep
		
		cmp [timeToCheck], 4h
		jz toNewDraw
		
		jmp WaitForData
	
	down:
		cmp [timeToCheck], 0h
		ja toNewDraw
		
;		push [delayT] ax bx
		
;		mov ax, [delayT]
;		mov bl, 10
;		div bl
;		add al, ah
;		xor ah, ah
		
		push 5
		call Sleep
		
;		pop bx ax [delayT]
		
		jmp WaitForData

exit:
	mov ax,3h
		int 10h
		
		mov ax, 4c00h
		int 21h
END start
;}