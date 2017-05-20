; name: Gai Brutman
; *ASSEMBLY TETRIS*

IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
; <name>	<size>		<value>
;			db/dw/dd	?/*

	RGB		db		00h, 00h, 0ffh,		33h, 0ffh, 33h,		33h, 99h, 0ffh,		0ffh, 33h, 33h,		99h, 33h, 0ffh,		0ffh, 99h, 33h,		0ffh, 0ffh, 33h
	
	loopcount1	db	?
	loopcount2	db	?

	nextStr	db		'NEXT BLOCK$'

	Clock equ es:6Ch
	x 		dw 		0
	y 		dw 		0
	color 	db		4
	nextColor	db	1
	sizeX	dw		?
	temp	dw		?
	tempForm	dw		?

	
	sizeY	dw		?
	count	dw		0h
	adress  dw		?
	check	dw		0h
	loopTimes1	db	4
	loopTimes2	db	4						;0000
											;0000
											;1000
											;1110
	timeToCheck	db		0
	
	form	dw		?	
	nextForm	dw		0
	
;											J									S									I									Z									T									L									O
	formwz	dw		0000000010001110b, 0000000001101100b, 0000000000001111b, 0000000011000110b, 0000000001001110b, 0000000000101110b, 0000000011001100b
	
	flipedForm	dw	?
	
; --------------------------
CODESEG

	include "MAP.asm"
	include "NEXT.asm"
	include "BLOCKG.asm"
	include "BLOCKC.asm"
	include "COLOR.asm"

start:
;{	
	mov ax, @data
	mov ds, ax

	mov ax, 13h
	int 10h
	
	call aditPallette
	
	call DrawWall
	
	newDraw:
	mov [flipedForm], 0h
	mov [timeToCheck], 0h
	
	mov [x], 120
	mov [y], 10
	
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
	
	
	call drawNext
	
	drawFirst:
	
	call DrawBlock
	
	WaitForData :
	
	push ax
	push bx
	push cx
	push dx
	push [sizeX]
	push [sizeY]
	
	mov [sizeX], 40
	mov [sizeY], 40
	mov [check], 0h
	push offset check
	call checkColor
	cmp [check], 1h
	jz collided
	jmp didntCollide
collided:
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
	call undraw
	add [y], 10

	call DrawBlock
	
	notmovdown:
	
	in al, 64h ; Read keyboard status port
	cmp al, 10b ; Data in buffer ?
	je WaitForData ; Wait until data available
	in al, 60h ; Get keyboard data
	cmp al, 1h ; Is it the ESC key ?
	jne notExit
	mov ax,3h
	int 10h	
	mov ax, 4c00h
	int 21h
	notExit:
	cmp al, 04bh ; Is it the LEFT key ?
	je left
	cmp al, 04dh ; Is it the RIGHT key ?
	je right
	cmp al, 48h ; Is it the UP key ?
	je up
	cmp al, 50h ; Is it the DOWN key ?
	je down

	call sleep

	cmp [timeToCheck], 4h
	jz toNewDraw
	
	jmp WaitForData
	
	toNewDraw:
	jmp newDraw
	
	left:
	
		call undraw
		sub [x], 10
	
		call DrawBlock

		call sleep
	
		cmp [timeToCheck], 4h
		jz toNewDraw
		
		jmp WaitForData
	
	right:
		
		call undraw
		add [x], 10
	
		call DrawBlock
		
		call sleep
		
		cmp [timeToCheck], 4h
		jz toNewDraw
		
		jmp WaitForData
	
	up:
	
		call undraw
		
		push [form]
		call Flip
		pop [flipedForm]
	
		call DrawBlock
	
		call sleep
		
		;cmp [timeToCheck], 4h
		;jz toNewDraw

		jmp WaitForData
	
	down:
		cmp [timeToCheck], 0h
		ja toNewDraw
		
		call undraw
		add [y], 10

		call DrawBlock
	
		call sleep

		jmp WaitForData

exit:
	mov ax,3h
	int 10h
	
	mov ax, 4c00h
	int 21h
END start
;}
