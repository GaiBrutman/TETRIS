
	proc Text_Printdec
	;{
		;input: decimal array offset (array you want to print)
		;prints a decimal number.
		
		;start proc {
			push bp
			mov  bp, sp
			
			push ax
			push bx
			push dx
			push si
			push di
			
			arr_off equ [bp + 4]
		;}
		
		;code {
			mov si, arr_off
			mov di, offset print_dec; print_dec db 0,0,0,0,0,'$'
			xor bx, bx
			
			@@copy_arr: ;{
				mov al, [si + bx]
				mov [di + bx], al
				
				inc bx
				cmp bx, 5
				jnz @@copy_arr
			;}
			
			xor bx, bx
			
			@@to_ascii: ;{
				add [byte ptr di + bx], '0'
				inc bx
				cmp bx, 5
				jnz @@to_ascii
			;}
			
			xor bx, bx
			
			@@check_zero: ;{
				cmp [byte ptr di + bx], '0'
				jnz @@print_num
				mov [byte ptr di + bx], ' '
				
				inc bx
				cmp bx, 4
				jnz @@check_zero
			;}
			
			
			@@print_num: ;{
				
				xchg di, dx
				mov  ah, 9
				int    21h
			;}
			
		;}
		
		@@end_proc: ;{
			pop di
			pop si
			pop dx
			pop bx
			pop ax
			
			pop bp
			ret 2
		;}
	;}
	endp Text_Printdec

;*****************************************************************************
;*****************************************************************************

proc HEX2DEC
;{
	;input: array offset (length = 5 bytes), number(word)
	;start_proc: {
		push bp
		mov  bp, sp
		
		dec_off equ [word ptr bp + 6]
		number 	equ [word ptr bp + 4]
		
		push ax
		push bx
		push cx
		push dx
	;}
	
	;code {
		;bx = last element in arr_dec
		mov bx, dec_off
		mov cx, 5
		
		@@zero_loop: ;{
			mov [byte ptr bx], 0
			inc bx
			loop @@zero_loop
		;}
		
		dec bx
		dec dec_off
		
		mov ax, number
		mov cx, 10
		xor dx, dx
		
		@@div_loop:
		;{
			div  cx
			xchg [bx], dl
			
			cmp ax, 0
			jz  @@end_proc
			
			@@exit_div: ;{
				dec bx
				cmp bx, dec_off
				jnz @@div_loop
			;}
		;}
		
	;}
	
	@@end_proc: ;{
		pop dx
		pop cx
		pop bx
		pop ax
		pop bp
		ret 4
	;}
;}
endp HEX2DEC
	
;*****************************************************************************
;*****************************************************************************


proc OpenFile
	; Open file for reading and writing

	mov ah, 3Dh
	mov al, 2
	mov dx, offset filename
	int 21h
	jc openerror
	mov [filehandle], ax
	ret
openerror:
	mov dx, offset ErrorMsg
	mov ah, 9h
	int 21h
	ret
endp OpenFile

proc ReadFile
	; Read file
	mov ah,3Fh
	mov bx, [filehandle]
	mov cx,51
	mov dx,offset Buffer
	int 21h
	ret
endp ReadFile

proc WriteToFile
; Write message to file
mov ah,40h
mov bx, [filehandle]
mov cx, 50
mov dx,offset Buffer
int 21h
ret
endp WriteToFile

proc CloseFile
	; Close file
	mov ah,3Eh

	mov bx, [filehandle]
	int 21h
	ret
endp CloseFile

proc PrintHighScore

		call OpenFile
		call ReadFile
	
		mov bx, 0
	@@loopa:
		mov dl, [Buffer + bx]
		mov ah, 2h
		int 21h
		inc bx
		mov dl, [Buffer + bx]
		mov ah, 2h
		int 21h
		inc bx
		mov dl, [Buffer + bx]
		mov ah, 2h
		int 21h
		inc bx
		
		mov dl, ' '
		mov ah, 2h
		int 21h
		
		mov ah,  [Buffer + bx]
		inc bx
		mov al,  [Buffer + bx]
		
		push ax
		call PrintNum
		
		mov dl, 10
		mov ah, 2
		int 21h
		mov dl, 13
		mov ah, 2
		int 21h
		
	inc bx
	cmp bx, 50
	jb @@loopa
	
	call CloseFile
	
	ret
	
endp PrintHighScore

proc AddHighScore

		call OpenFile
		call ReadFile
	
	mov bx, 3
	@@loopa:
		mov ah,  [Buffer + bx]
		inc bx
		mov al,  [Buffer + bx]
		
		cmp [score], ax
		jna notRep
		
		push bx
		
		mov ax, 13h
		int 10h	
		
		mov dx, offset HighScoreStr
		mov ah, 9h
		int 21h
			
	@@loopEnter:
		mov ah, 0
		int 16h
		cmp ah, 1Ch
		jne @@loopEnter
		
		mov dl, 0ah
		mov ah, 2h
		int 21h

		mov dx, offset EnterNameStr
		mov ah, 9h
		int 21h
		
		mov dx, offset nme
		mov bx, dx
		mov [byte ptr bx], 4 ;the last input is ENTER
		mov ah, 0Ah
		int 21h

;								 ^
;		[a][b][c][1][2]
		pop bx
		push bx
				
		call PushList
		
		sub bx, 4
		
		mov si, 2
		@@loopb:
		mov al, [offset nme + si]
		mov [Buffer + bx], al
		inc bx
		inc si
		cmp si, 5
		jnz @@loopb
		
		mov ax, [score]
		mov [Buffer + bx], ah
		inc bx
		mov [Buffer + bx], al
		
		pop bx
				
		call CloseFile

		ret
		
		notRep:
		
	add bx, 4
	cmp bx, 50
	jb @@loopa

	call CloseFile
	
	ret
	
endp AddHighScore

proc PushList
;												   		44  45  46  47  48  49
;														  ^                          +5
;	[a][a][c][1][1][a][a][b][0][5][a][a][a][0][1]
	mov si, 44
	mov di, 49
	@@loopa:
		mov al, [offset Buffer + si]
		mov [offset Buffer + di], al
		dec si
		dec di
		
	cmp di, bx
	jnz @@loopa
	ret
endp PushList

proc PrintNum
	pop [adress]
	pop dx
	
	push offset score_arr
	push dx
	call HEX2DEC
	
	push offset score_arr
	call Text_Printdec
	
	push [adress]
	ret
endp PrintNum


proc EnterLevel
	push ax cx dx
	
	@@start:
	
	mov ax, 13h
	int 10h
	
	mov dx, offset EnterLevelStr
	mov ah, 9h
	int 21h
	
	mov ah, 1h
	int 21h
	sub al, 30h
	mov ah, al
	
	mov ch, ah
	mov ah, 1h
	int 21h
	mov ah, ch
	sub al, 30h
	
	AAD
	
	push 100
	call Sleep
	
	cmp al, 1
	jb @@start
	cmp al, 15
	ja @@start
	
	mov [level], al
	
	mov ax, 13h
	int 10h
	
	pop dx cx ax
	ret
endp EnterLevel

proc CheckLevel
	push ax bx
			
	mov ax, [lines]

	mov bl, 10
	
	div bl

	cmp ah, 0h
	jnz doNothing
	
	inc [level]
		
	call AdjustSpeed
	
doNothing:
	
	pop bx ax
	ret
endp CheckLevel

proc AdjustSpeed

	mov al, [byte ptr delayT]
	mov bl, 4
	mul bl
		
	mov bl, 5
	div bl
	xor ah, ah
		
	mov [delayT], ax
	
	ret
endp AdjustSpeed
