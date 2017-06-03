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

	notes					dw		250, 3619, 3619, 4831, 4560, 4063, 4063, 4560, 4831, 5423, 5423, 5423
								dw		4560, 3619, 3619, 4063, 4560, 4831, 4831, 4831, 4560, 4063, 4063
								dw		3619, 3619, 4560, 4560, 5423, 5423, 5423, 5423, 4831, 4560, 4063
								dw		4063, 4063, 3416, 2711, 2711, 3043, 3416, 3619, 3619, 3619, 4560
								dw		3619, 3619, 4063, 4560, 4831, 4831, 4831, 4560, 4063, 4063, 3619
								dw		3619, 4560, 4560, 5423, 5423, 5423, 5423, 0 , 0
								dw		3619, 3619, 3619, 3619, 4560, 4560, 4560, 4560, 4063, 4063, 4063, 4063	
								dw		4831, 4831, 4831, 4831, 4560, 4560, 4560, 4560, 5423, 5423, 5423, 5423
								dw		5746, 5746, 5746, 5746, 4831, 4831, 0, 0
								dw		3619, 3619, 3619, 3619, 4560, 4560, 4560, 4560, 4063, 4063, 4063, 4063
								dw		4831, 4831, 4831, 4831, 4560, 4560, 3619, 3619, 2711, 2711, 2711, 2711
								dw		2873, 2873, 2873, 2873
	adress					dw		?
CODESEG
proc sounds
	out     43h, al         ;  note.
	
	mov ax, [offset notes + bx] 
	
   ; mov     ax, [note]        ; Frequency number (in decimal)
                                ;  for middle C.
	out     42h, al         ; Output low byte.
	mov     al, ah          ; Output high byte.
	out     42h, al 
	in      al, 61h         ; Turn on note (get value from
                                ;  port 61h).
	or      al, 00000011b   ; Set bits 1 and 0.
	out     61h, al         ; Send new value.
	mov     bx, 30         ; Pause for duration of note.
pausee1:
	mov     cx, 65535
pausee2:
	dec     cx
	jne     pausee2
	dec     bx
	jne     pausee1
	in      al, 61h         ; Turn off note (get value from
                                ;  port 61h).
	and     al, 11111100b   ; Reset bits 1 and 0.
	out     61h, al         ; Send new value.
		
;	pop dx cx bx ax
	ret
endp sounds


proc sleep
	pop [adress]
	pop cx
	
	@@loopa:
		push cx
		
		mov cx, 20000
		cmp [counter], 150
		jz dontLoop
		@@loopb:
		nop
		loop @@loopb
	dontLoop:
		inc [counter]
		cmp [counter], 150
		jnz @@coninue
		mov [counter], 0
		call music
		@@coninue:
		pop cx
	loop @@loopa

	push [adress]
	ret
endp sleep

proc sounds
;	push ax bx cx dx
	
	out     43h, al         ;  note.
	
	mov ax, [offset notes + bx] 
	
   ; mov     ax, [note]        ; Frequency number (in decimal)
                                ;  for middle C.
	out     42h, al         ; Output low byte.
	mov     al, ah          ; Output high byte.
	out     42h, al 
	in      al, 61h         ; Turn on note (get value from
                                ;  port 61h).
	or      al, 00000011b   ; Set bits 1 and 0.
	out     61h, al         ; Send new value.
	mov     bx, 15         ; Pause for duration of note.
pausee1:
	mov     cx, 65535
pausee2:
	dec     cx
	jne     pausee2
	dec     bx
	jne     pausee1
	in      al, 61h         ; Turn off note (get value from
                                ;  port 61h).
	and     al, 11111100b   ; Reset bits 1 and 0.
	out     61h, al         ; Send new value.
		
;	pop dx cx bx ax
	ret
endp sounds

proc music
	push ax bx cx dx
		mov bx, [np]
		
		call sounds
		add [np], 2
		mov bx, [np]
		cmp bx, [offset notes]
		jz startOver
	
	
	jmp dontStartOver
	startOver:
	mov [np], 2
	
	dontStartOver:
	pop dx cx bx ax
	ret
endp music

start:
;{	
	mov ax, @data
	mov ds, ax

	mov ax, 3h
	int 10h
	
	mov bx, 2
	loopa:
		
		push bx
		call sounds
		pop bx
		add bx, 2
		cmp bx, [offset notes]
		jnz loopa

exit:
		
		mov ax, 4c00h
		int 21h
END start
;}