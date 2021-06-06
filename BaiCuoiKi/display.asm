%macro writeStr 2	
	push	eax
	push	ebx
	push	ecx
	push	edx
	mov	eax,4
	mov	ebx,1
	mov	ecx,%1
	mov	edx,%2
	int 0x80
	pop	edx
	pop	ecx
	pop	ebx
	pop	eax
%endmacro

section .data
	hexchar	db	'0123456789ABCDEF'
	bMem	times	8	db	0x30;Memory to strore str
	cMem	db	0
	rowAddress dd	4
	temp	db	0
	temp_pow	db	2
	flag		db	0
	arrAddress	db	"0000000000"
	lenArrAddress	equ	$-arrAddress
	count		dd	9
	global	write_str
	global	newline
	global	write_char
	global	space
	global  write_hex_digit
	global	write_hex
	global	write_hex_dword	
write_hex_digit:
	; input al
	push	ebx
	mov	ebx,hexchar
	xlat
	call	write_char
	pop	ebx
	ret
write_hex_digit_dWord:
	; input al
	push	ebx
	mov	ebx,hexchar
	xlat
	pop	ebx
	ret
write_hex:
	;input al
	push	ebx
	mov	bl,al
	shr	al,4
	call	write_hex_digit
	mov	al,bl
	and	al,0x0f
	call	write_hex_digit
	pop	ebx
	ret
write_hex_reverse_flag_0:
	;input al
	push	ebx
	mov	bl,al
	shl	al,4
	call	write_hex_digit_dWord
	mov	Byte[arrAddress+esi],al
	dec	esi
	mov	al,bl
	shr	al,4
	call	write_hex_digit_dWord
	mov     Byte[arrAddress+esi],al
	dec	esi
	pop	ebx
	ret
write_hex_reverse_flag_1:
	;input al
	push	ebx
	mov	bl,al
	and	al,0x0f
	call	write_hex_digit_dWord
	mov     Byte[arrAddress+esi],al
	dec	esi
	mov	al,bl
	shr	al,4
	call	write_hex_digit_dWord
	mov     Byte[arrAddress+esi],al
	dec	esi
	pop	ebx
	ret	
write_hex_dword:
	;input edx
	xor eax,eax	;xóa thanh ghi eax
	xor esi,esi		; mỗi hàng có 8 cột tương đương 8 bit
	xor edi,edi	;
	mov ebx,edx	;
	mov	byte[flag],0
	mov	dWord[count],9
_loop1:	
		shr	ebx,1	; dịch 8 bit luu vào thanh ghi al		
		jc	flag_bit_1	; nhảy nếu bit là 1	
		_point:
		inc	esi
		cmp	esi,8		; so sánh esi với 0
		jne	_loop1		; nếu khác 0 thực hiện _loop1
_loop2:
			mov	esi,dWord[count]
			cmp byte[flag],0
			je  flag_reverse_flag_0
			call	write_hex_reverse_flag_1
_point2:
			shr	edx,8	  ; lap lai giá trị cho esi			
			xor	eax,eax
			mov	ebx,edx
			mov	dWord[count],esi
			xor	esi,esi
			inc	edi
			cmp	edi,4
			jne	_loop1
			writeStr	arrAddress,lenArrAddress	
			ret	
flag_reverse_flag_0:
	call	write_hex_reverse_flag_0
	inc	byte[flag]
	jmp	_point2
flag_pow_zero:
        add     al,1    ; nếu 2^0 thì cộng cho 1
        jmp     _point  ; nhảy tới hàm wri_hex_dword
flag_bit_1:
        ; input al
	cmp	esi,0
	je	flag_pow_zero
        mov     byte[temp],al   ; giu gia tri cho thanh ghi al
        mov     al,1            ; khơi tạo biến al  = 1
        xor	ecx,ecx         ; đưa số lần lap vào thanh ghi ecx
        pow:
                mul     byte[temp_pow]      ; pow cho 2 ^ ecx
		inc	ecx
                cmp	ecx,esi
		jne	pow
        add     al,     Byte[temp]      ; Cong them gia tri cua temp
        jmp     _point
; ham ghi chuoi
write_str:
	push		ebp
	mov		ebp,esp
	writeStr	[ebp+12],[ebp+8]
	leave
	ret
space:
	push		eax
	mov		al,0x20
	call		write_char
	pop		eax
	ret
newline:
	push		eax
	mov		al,0xA
	call		write_char
	pop		eax
	ret
write_char:
	;input al
	mov		 Byte[cMem],al
	writeStr	 cMem,1
	ret
