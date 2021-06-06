%macro writeStr 2
	push	eax
	push	ebx
	push	ecx
	push	edx
	mov		edx,%2
	mov		ecx,%1
	mov		ebx,1
	mov		eax,4
	int		0x80
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
%endmacro
section .data
    Printable db '|................|',10		;The printable sequence
	PrintableLen: equ $-Printable			;Printable length for indexing


  hexchar	db '0123456789ABCDEF'
	cMem	db 0

	global space
	global newline
	global write_char
	global write_str
	global write_hex_digit
	global write_hex
	global write_bin
	global write_dec

    section .bss

  BUFFLEN equ 16      ; read file in 16 byte chunks
  Buff: resb BUFFLEN  ; buffer to hold these chunks

section .text
space:
	push eax
	mov al,0x20
	call write_char
	pop eax
	ret
newline:
	push eax
	mov al,10
	call write_char
	pop eax
	ret
write_char:
	; input al
	mov byte[cMem],al
	writeStr cMem,1
;	mov byte[cMem],al
;	push cMem
;	push 1
;	call write_str
;	add  esp,8
	ret
write_str:
	; strAddr [ebp+12]
	; strLen [ebp+8]
	push ebp
	mov  ebp,esp
	writeStr [ebp+12],[ebp+8]
	leave
	ret 
write_hex_digit:
	; input al
	push ebx
	mov  ebx,hexchar	
	xlat
	call write_char
	pop  ebx
	ret
global _start

_start:

; Fill buffer from stdin
Read:
  mov eax, 3             ; sys_read
  mov ebx, 0             ; stdin fd
  mov ecx, Buff          ; offset to read to
  mov edx, BUFFLEN       ; number of bytes
  int 80h

  mov ebp, eax           ; Store the buffer length
  cmp eax, 0             ; check for EOF
  je  Done

; Prep registers for process buffer step
  mov esi, Buff          ; point esi at buffer
  xor ecx, ecx           ; zero out ecx

    call space
; Go through buffer and convert binary to hex digits
Scan: 
  xor eax, eax           ; zero out eax
  
; Calculate offset into HexStr which is ecx * 3
  mov edx, ecx           ; copy char counter
  shl edx, 1             ; multiply by 2
  add edx, ecx           ; add ecx

; Get char from buffer and put into eax and ebx
  mov al, byte [esi + ecx ] ; put byte from current position in input buffer into al
  mov ebx, eax             ; duplicate it into bl

write_hex:
	; input al
	push ebx
	mov  bl,al 
	shr  al,4
	call write_hex_digit
	mov  al,bl
	and  al,0x0f
	call write_hex_digit
	pop  ebx

    call space
	
; Bump buffer pointer to next char and check if we are done
  inc ecx
  cmp ecx, ebp    ; compare to number of bytes in buffer (we saved it earlier)
  jne Scan        ; while (ecx <= ebp)

	
  Continue:	xor ecx, ecx	;Clear the counter 

  Print:		
    cmp byte[Buff+ecx], 0x20	;If ASCII code is less than 'space'
		jl NotPrintable			;The char is not printable
		cmp byte[Buff+ecx], 0x7A	;If ASCII code is more than 'z'
		jg NotPrintable			;The char is not printable

		;If it's printable...
		mov al, byte[Buff+ecx]		;Process the character
		mov byte[Printable+ecx+1], al	;Move the processed char into the printMap
		jmp Next			;No need to substitute

		;Otherwise...
NotPrintable:	mov al, 0x2E			;Insert a point
		mov byte[Printable+ecx+1], al	;Store it into the array

Next:		inc ecx				;Add 1 to the char count
		cmp ecx, ebp			;Check if we're done
		jb Print			;If not, continue processing

;We need to fill the rest of the string with dots

		add ecx, 2			;This way we don't count the two | chars as wrong
Complete:	inc ecx				;Next char
		cmp ecx, PrintableLen		;See if the last sequence of chars left any char untouched
		je Write			;If nothing is left, go write
		mov byte[Printable+ecx-2], 0x2E	;Place a dot where needed
		jmp Complete
		
	Write:
    mov eax, 4
	mov ebx, 1
	mov ecx, Printable	;The string containing the printable chars
	mov edx, PrintableLen
	int 80h
	
	jmp Read        ; Keep reading from buffer
	
Done:
  mov eax, 1      ; exit with code zero
  mov ebx, 0
  int 80H

