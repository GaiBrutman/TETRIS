
	PROC TEXT_PRINTDEC
	;{
		;Input: Decimal array offset (array you want to print)
		;PRINTS A DECIMAL NUMBER.
		
		;START PROC {
			PUSH BP
			MOV  BP, SP
			
			PUSH AX
			PUSH BX
			PUSH DX
			PUSH SI
			PUSH DI
			
			ARR_OFF EQU [BP + 4]
		;}
		
		;CODE {
			MOV SI, ARR_OFF
			MOV DI, OFFSET PRINT_DEC; print_dec db 0,0,0,0,0,'$'
			XOR BX, BX
			
			@@COPY_ARR: ;{
				MOV AL, [SI + BX]
				MOV [DI + BX], AL
				
				INC BX
				CMP BX, 5
				JNZ @@COPY_ARR
			;}
			
			XOR BX, BX
			
			@@TO_ASCII: ;{
				ADD [BYTE PTR DI + BX], '0'
				INC BX
				CMP BX, 5
				JNZ @@TO_ASCII
			;}
			
			XOR BX, BX
			
			@@CHECK_ZERO: ;{
				CMP [BYTE PTR DI + BX], '0'
				JNZ @@PRINT_NUM
				MOV [BYTE PTR DI + BX], ' '
				
				INC BX
				CMP BX, 4
				JNZ @@CHECK_ZERO
			;}
			
			
			@@PRINT_NUM: ;{
				
				XCHG DI, DX
				MOV  AH, 9
				INT    21h
			;}
			
		;}
		
		@@END_PROC: ;{
			POP DI
			POP SI
			POP DX
			POP BX
			POP AX
			
			POP BP
			RET 2
		;}
	;}
	ENDP TEXT_PRINTDEC

;*****************************************************************************
;*****************************************************************************

PROC HEX2DEC
;{
	;input: array offset (length = 5 bytes), number(word)
	;START_PROC: {
		PUSH BP
		MOV  BP, SP
		
		DEC_OFF EQU [WORD PTR BP + 6]
		NUMBER 	EQU [WORD PTR BP + 4]
		
		PUSH AX
		PUSH BX
		PUSH CX
		PUSH DX
	;}
	
	;CODE {
		;BX = LAST ELEMENT IN ARR_DEC
		MOV BX, DEC_OFF
		MOV CX, 5
		
		@@ZERO_LOOP: ;{
			MOV [BYTE PTR BX], 0
			INC BX
			LOOP @@ZERO_LOOP
		;}
		
		DEC BX
		DEC DEC_OFF
		
		MOV AX, NUMBER
		MOV CX, 10
		XOR DX, DX
		
		@@DIV_LOOP:
		;{
			DIV  CX
			XCHG [BX], DL
			
			CMP AX, 0
			JZ  @@END_PROC
			
			@@EXIT_DIV: ;{
				DEC BX
				CMP BX, DEC_OFF
				JNZ @@DIV_LOOP
			;}
		;}
		
	;}
	
	@@END_PROC: ;{
		POP DX
		POP CX
		POP BX
		POP AX
		POP BP
		RET 4
	;}
;}
ENDP HEX2DEC
	
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
		call PrintScore
		
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
		
		@@loopEnter:
		
		mov ax, 13h
		int 10h
		
		mov dx, offset HighScoreStr
		mov ah, 9h
		int 21h
			
		mov ah, 1
		int 21h
		cmp al, 13
		jnz @@loopEnter
		
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
	
	;pop bx

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

proc PrintScore
	pop [adress]
	pop dx
	
	push offset score_arr
	push dx
	call HEX2DEC
	
	push offset score_arr
	call TEXT_PRINTDEC
	
	push [adress]
	ret
endp PrintScore

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
		mov bl, 3
		mul bl
		
		mov bl, 4
		div bl
		xor ah, ah
		
	mov [delayT], ax
	
	ret
endp AdjustSpeed
