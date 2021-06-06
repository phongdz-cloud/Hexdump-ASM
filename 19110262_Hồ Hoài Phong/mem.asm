%macro  writeStr 2
        push    eax
        push    ebx
        push    ecx
        push    edx
        mov     eax,4
        mov     ebx,1
        mov     ecx,%1
        mov     edx,%2
        int 0x80
        pop     edx
        pop     ecx
        pop     ebx
        pop     eax
%endmacro
section .bss
	buff	resb	16	;đọc 16 kí tự lưu vào buff
section .data
	global		display_memory
	printTable	db	'|................|'	; bảng ký tự
	lenPrintTable	equ	$-printTable		; độ dài bảng kí tự
	address		dd	0x00000000
	length		dd	0
	extern		newline		; gọi thư viện newline
	extern		space		; gọi tới thư viện in khoảng cách
	extern		write_char	; gọi tới thư viện in khoảng cach	
	extern		write_hex	; gọi tới hàm in giá trị hex 
	extern  	write_hex_dword	; gọi tới hàm in địa chỉ của hexdump
	extern		write_str	; gọi tới hàm in chuỗi

; Tổng hợp tất cả các hàm

; hàm này có chức năng đọc vào 16 kí tự và giá trị địa chỉ  lưu  vào buff và address từ C
readData:
	push	ebp
	mov	ebp,esp
	mov	edx,[ebp+20]
	mov	ecx,[ebp+16]
	mov	dWord[length],edx
	leave
	ret
; Hàm này có chức năng lưu dữ liệu vừa đọc từ c 
writeData:
	call	readData
	;mov	dWord[address],edx	; chép giá trị vừa đọc vào ô nhớ địa chỉ
	xor	esi,esi
	writeArrChar:
	mov	eax,[ecx+esi]		; chép 1 kí tự vào thanh ghi eax
	mov	[buff+esi],eax		; chép vào 1 mảng kí tự của buff
	inc	esi			; tăng esi lên 1
	cmp	esi,16			; so sánh esi với 16
	jne	writeArrChar		; nhảy nếu không bằng
	ret
; hàm này có chức năng in 2 lần khoảng trắng
print_space:
	_print:
	call	space	;gọi hàm in khoảng cach	
	inc	edi	; tăng edi lên 1
	cmp	edi,2	; so sánh edi với 2 nếu bằng thì không tin tiếp
	jne	_print	; nhảy neu không bằng
	ret
; hàm này có chức năng in ra địa chỉ của hexdump
print_Address_hexdump:
	mov	edx,dWord[address]	; đầu vào là thanh edx
	call	write_hex_dword		; gọi tới hàm write_hex_dword
	xor	edi,edi			; xóa thanh ghi edi để in 2 lần khoảng trắng
	call	space
	call	space
	xor	edi,edi			; xóa thanh ghi edi
	xor	esi,esi
print_list_str:
                cmp     Byte[buff+esi],0x20     ;If mã ASCII nhỏ hơn kí tự khoảng trắng
                jb     not_print_list_str      ; Nhảy neu nho hon ki tu khoang trang
                cmp     Byte[buff+esi],0x7A     ; If mã ASCII lớn hơn kí tự z   
                jg      not_print_list_str
                ;kí tự hợp lệ
                mov     al,byte[buff + esi]     ; Lấy từng kí tự vào al
                mov     Byte[printTable + esi+1],al     ; gán giá trị al vào printTable
                jmp     next
not_print_list_str:
                mov     al,0x2E                 ; thay dấu chấm cho kí tự không hợp lệ
                mov     byte[printTable + esi +1],al    ; lưu vào bảng in
		;mov	byte[buff+esi],al
next:
                inc     esi                     ; tăng esi lên 1
                cmp     esi,16                  ; so sánh esi với 16
                jne     print_list_str          ; nhảy nếu không bằng 16
		xor	esi,esi			; xoa thanh esi 
		jmp     print_digithex
print_twospace:         ; nhãn in 2 lần khoảng trắng
                 call    space   ; gọi hàm in khoảng cách
		  cmp     esi,dWord[length]       ; so sanh voi chuoi do dai
                  je      print_space_length     ; nhay neu lon hon chuoi do dai
		  jmp	  print_digithex
print_digithex: ; in ra số hex 
		  
                  mov     al,byte[buff + esi]     ; lấy từng kí tự của buff đưa về hex
                  call    write_hex               ; gọi tới hàm write_hex
                  call    space                   ; gọi tới hàm in khoảng trắng
	          valid_character:
                  inc     esi                     ; tăng esi lên 1
                  cmp     esi,8                   ; so sánh esi với 8
                  je      print_twospace          ; nếu bằng thì nhảy lên nhãn print_twospace
		  cmp	  esi,dWord[length]	  ; so sanh voi chuoi do dai
		  je	  print_space_length	 ; nhay neu lon hon chuoi do dai
                  cmp     esi,16                  ; so sánh với 16
                  jne     print_digithex          ; nếu kh bằng thì nhảy print_digithex
                  call    space                   ; in 2 dấu khoảng trắng                 
                  xor     esi,esi                 ; xóa thanh ghi esi
		  jmp     Write			  ; nha xuong ham in chuoi
_print_space:
	call	space
	jmp	loop_space

print_space_length:
		  
		  cmp	esi,16
		  je	jump_write_esi
		  cmp	dWord[length],16
		  je	jump_write
		  mov	esi,dWord[length]
loop_space:
		  call  space
		  call	space
		  call  space
		  inc	esi
		  cmp	esi,0x08
		  je	_print_space
		  cmp	esi,0x10
		  jne	loop_space
		  jmp 	jump_write_esi
	jump_write:
		  call	space
		  call  space
		  xor	esi,esi
		  jmp	Write
	jump_write_esi:
		  call	space
			
Write:
               
		
		cmp	dWord[length],0x10
		jne	print_length	
		writeStr printTable,lenPrintTable
Exit:
		
                call    newline                 ; gọi tới hàm xuống dòng
		ret
print_length:
		add	dWord[length],1
		mov	esi,dWord[length]
		mov     Byte[printTable+esi],'|'
		inc	dWord[length]
		writeStr	printTable,dWord[length]
		xor		esi,esi
		jmp		Exit
display_memory:
       	call    writeData
	xor     esi,esi

        call    print_Address_hexdump
	add	dWord[address],16
        ret

