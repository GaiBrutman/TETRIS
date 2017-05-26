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
	score					dw		0
	lines						dw		0
	level						dw		1h

	delayT					dw		100d

	flipedForm			dw		?

	canFlip				dw		0h

	mapColor				db		?

;												[Blue]					[Green]				[Cyan]				[Red]					[Purple]				[Orange]			[Yellow]
	RGB					db		00h, 80h, 0ffh,		00h, 0ffh, 00h,		66h, 0ffh, 0ffh,		0ffh, 00h, 00h,		66h, 00h, 0cch,		0ffh, 90h, 00h,		0ffh, 0ffh, 0h
	
	loopcount1			db		?
	loopcount2			db		?

	nextStr				db		'NEXT BLOCK$'
	loseStr					db		'YOU LOST!$'
	T10Str				db		'TOP 10 SCORES:$'
	ScoreStr				db		'SCORE$'
	HighScoreStr		db		'NEW HIGHSCORE! (PRESS ENTER TO CONTINUE)$'
	EnterNameStr		db		'ENTER NAME (THREE DIGITS): $'
	nme 					db 		6 dup (?)
	
	
	Clock					equ		es:6Ch

	x 							dw 		0
	y							dw		0
	color 					db		4
	nextColor			db		1
	sizeX					dw		?
	temp					dw		?
	tempForm			dw		?

	
	sizeY					dw		?
	count					dw		0h
	adress  				dw		?
	check					dw		0h
	timeToCheck		db		0
	
	form						dw		?	
	nextForm			dw		0
	
;														J									S									I									Z									T									L									O
	formwz				dw		0000000010001110b, 0000000001101100b, 0000000000001111b, 0000000011000110b, 0000000001001110b, 0000000000101110b, 0000000011001100b
	
	
	
	
	checkType			db		1
	
	filename				db		'top10.txt',0
	filehandle				dw		?

	ErrorMsg			db		'Error', 10, 13,'$'
	
	
	Buffer					db		'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0	; 'WIN90BOB57JMS50JOE36BER23JON22Jek15JOK12ABA09ABB06’
	
	print_dec				db		0,0,0,0,0,'$'
	score_arr				db		0,0,0,0,0
	
	note						dw		2394h ; 1193180 / 131 -> (hex)
	
; --------------------------
CODESEG

	include "MAP.asm"
	include "NEXT.asm"
	include "BLOCKG.asm"
	include "BLOCKC.asm"
	include "COLOR.asm"
	include "SCORE.asm"

start:
;{	
	mov ax, @data
	mov ds, ax

	mov ax, 13h
	int 10h
	
;	call OpenFile
;	call WriteToFile
;	call CloseFile
	
	call aditPallette
	
	call DrawWall
	
	newDraw:
	call checkLose
	
	call checkRow
	
	call ShowScore
	
	mov [flipedForm], 0h
	mov [timeToCheck], 0h
	;mov [delayT], 900
	
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
	jne Nup
	jmp up
	Nup:
	cmp al, 50h ; Is it the DOWN key ?
	jne Ndown
	jmp down
	Ndown:

	call sleep

	cmp [timeToCheck], 4h
	jz toNewDraw
	
	jmp WaitForData
	
	left:
		mov [checkType], 0
		mov [check], 0h
		push offset check
		call checkColor
		mov [checkType], 1
		cmp [check], 1
		jz toWait
		
		call undraw
		sub [x], 10
	
		call DrawBlock
		
		toWait:
		call sleep
		cmp [timeToCheck], 4h
		jz toNewDraw
		jmp WaitForData
	
	
	right:
		
		mov [checkType], 2
		mov [check], 0h
		push offset check
		call checkColor
		mov [checkType], 1
		cmp [check], 1
		jz toWait2
		
		call undraw
		add [x], 10
	
		call DrawBlock
		
		toWait2:
		call sleep
		cmp [timeToCheck], 4h
		jz toNewDraw
		jmp WaitForData
	
	toNewDraw:
	
	call sound
	
	add [score], 10
	jmp newDraw
	
	up:
		call undraw
		
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
		
		;jmp WaitForData
		
	doFlip:

		call DrawBlock
	
		call sleep
		
		jmp WaitForData
	
	down:
		cmp [timeToCheck], 0h
		ja toNewDraw
		
		push [delayT] ax bx
		mov ax, [delayT]
		mov bl, 10
		div bl
		xor ah, ah
		mov [delayT], ax
		;sub [delayT], 800
		
		call sleep
		
		pop bx ax [delayT]
		
		jmp WaitForData

exit:
	mov ax,3h
		int 10h
		
		mov dx, offset nextStr
		mov ah, 9h
		int 21h
		
		mov ax, 4c00h
		int 21h
END start
;}
