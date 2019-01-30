; name: Gai Brutman
; *ASSEMBLY TETRIS*

IDEAL
MODEL small
STACK 100h
DATASEG
; --------------------------
; Your variables here
;	<name>		<size>		<value>
;				db/dw/dd	?/*
	sav			db			18 dup (0)
	
	counter		dw			0
	
	score		dw			0
	lines		dw			0
	level		db			1

	delayT		dw			100d

	flipedForm	dw			?

	canFlip		dw			0h

	mapColor	db			?
;								1						2					3					4						5						6					7
;								[Blue]					[Green]				[Cyan]				[Red]					[Purple]				[Orange]			[Yellow]
	RGB			db			00h, 80h, 0ffh,			00h, 0ffh, 00h,		00h, 0ffh, 0ffh,	0ffh, 00h, 00h,			33h, 00h, 0ffh,			0ffh, 90h, 00h,		0ffh, 0ffh, 00h
				db			00h, 00h, 099h,			00h, 099h, 00h,		00h, 0aah, 0aah,	099h, 00h, 00h,			11h, 00h, 0cch,			099h, 4ch, 00h,		099h, 099h, 00h
;								[White]
				db			0ffh, 0ffh, 0ffh
	
	loopcount1	db			?
	loopcount2	db			?
	
	PauseStr	db			'PAUSE$'
	nextStr		db			'NEXT PIECE$'
	loseStr		db			'YOU LOST!$'
	T10Str		db			'TOP 10 SCORES:$'
	ScoreStr	db			'SCORE$'
	LinesStr	db			'LINES$'
	LevelStr	db			'LEVEL$'
	HighScoreStr	db		'NEW HIGHSCORE! (PRESS ENTER TO CONTINUE)$'
	EnterNameStr	db		'ENTER NAME (THREE DIGITS): $'
	EnterLevelStr	db		'ENTER START LEVEL (01 - 15): $'
	
	nme 		db 			6 dup (?)
	
	
	Clock equ es:6Ch

	x			dw 			0
	y			dw			0
	color 		db			4
	nextColor	db			1
	sizeX		dw			?
	temp		dw			?
	tempForm	dw			?

	
	sizeY		dw			?
	count		dw			0h
	adress  	dw			?
	check		dw			0h
	timeToCheck	db			0
	
	form		dw			?	
	nextForm	dw			0
	
;									J					S					I					Z				T					L					O
	formwz		dw			0000000010001110b, 0000000001101100b, 0000000000001111b, 0000000011000110b, 0000000001001110b, 0000000000101110b, 0000000011001100b
	
	
	
	
	checkType	db			1
	
	filename	db			'top10.txt',0
	filehandle	dw			?

	ErrorMsg	db			'Error', 10, 13,'$'
	
	
	Buffer		db			'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0, 'AAA', 0, 0
	
	print_dec	db			0,0,0,0,0,'$'
	score_arr	db			0,0,0,0,0
	
	note		dw			9121 ; 1193180 / 131 -> (hex)
	
;-------------------------------;
	MAX_BMP_WIDTH equ 320
	MAX_BMP_HEIGHT equ 200
;-------------------------------;
	OneBmpLine		db		MAX_BMP_WIDTH dup (0)  ; One Color line read buffer
	ScreenLineMax	db		MAX_BMP_WIDTH dup (0)  ; One Color line read buffer
	Header 			db		54 dup(0)
	Pallette 		db		400h dup (0)
;-------------------------------;
	StartScreenName		db	'starter.bmp', 0
	InstructionsName1	db	'inst.bmp', 0
	InstructionsName2 	db	'inst2.bmp', 0
;-------------------------------;
	BmpFileErrorMsg	db		'Error At Opening Bmp File .', 0dh, 0ah,'$'
	ErrorFile		db		0
	BB 				db		"BB..",'$'
;-------------------------------;
	BmpLeft		dw			?
	BmpTop		dw			?
	BmpColSize	dw			?
	BmpRowSize	dw			?
; --------------------------

CODESEG

	include "MAP.asm"
	include "NEXT.asm"
	include "BLOCKG.asm"
	include "BLOCKC.asm"
	include "COLOR.asm"
	include "SCORE.asm"
	include "BMP.asm"

start:
;{	
	mov ax, @data
	mov ds, ax

	mov ax, 13h
	int 10h
	
	push offset StartScreenName
	call PrintBmp		;	Prints Start Screen
	
@@loopEnter:
	mov ah, 0
	int 16h
	cmp ah, 1Ch
	jne @@loopEnter
	
	mov ax, 13h
	int 10h

	push offset InstructionsName1
	call PrintBmp		;	Prints Instructions Screen 1
	mov ah, 0 
	int 16h
	
	mov ax, 13h
	int 10h

	push offset InstructionsName2
	call PrintBmp		;	Prints Instructions Screen 2
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
	jmp skipCollideLable
	
didntCollide:
	mov [timeToCheck], 0h

skipCollideLable:
	
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
	jmp exit
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
	
		mov [canFlip], 1h
		push offset canFlip
		call CheckFlip
		cmp [canFlip], 0h
		je dontFlip
		jmp doFlip
		dontFlip:
		mov [canFlip], 1h
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
		
		push 5
		call Sleep
		
		jmp WaitForData

exit:
	mov ax,3h
		int 10h
		
		mov ax, 4c00h
		int 21h
END start
;}
