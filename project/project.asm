.MODEL SMALL
.STACK 100h
.DATA
    substring       DB 'aa', 0     ; Hardcoded substring
    substring_len   DB 2           ; Length of substring
    
    ; Buffer for reading from file
    buffer          DB 255 DUP(0)  ; Buffer for the main string
    buffer_size     DW 255         ; Maximum buffer size
    bytes_read      DW 0           ; Number of bytes read
    
    ; Results
    res_counts      DB 0           ; Result: number of occurrences

.CODE
start:
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    ; Read from standard input (file redirected with < test.in)
    mov ah, 3Fh              ; DOS function: Read from file
    mov bx, 0                ; BX = 0 (stdin)
    lea dx, buffer           ; DS:DX points to buffer
    mov cx, buffer_size      ; CX = max bytes to read
    int 21h
    mov bytes_read, ax       ; Save number of bytes read
    
    ; Process the string from buffer
    lea si, buffer
    call count_occurrences
    mov res_counts, al
    
    ; Print just the number of occurrences
    xor ax, ax
    mov al, res_counts
    call print_num
    
    ; Print a new line
    mov ah, 02h              ; DOS function: Print character
    mov dl, 13               ; Carriage return
    int 21h
    mov dl, 10               ; Line feed
    int 21h
    
    ; Exit
    mov ah, 4Ch
    int 21h

; --- count_occurrences ---
; Input: SI = pointer to string
; Output: AL = number of occurrences
count_occurrences:
    push si
    push di
    push cx
    push bx
    
    xor ax, ax                ; AX = count of occurrences (result)
    mov bx, si                ; BX = start of the string
    
next_pos:
    mov si, bx                ; SI = current position
    lea di, substring         ; DI = start of substring
    mov cl, substring_len     ; CL = substring length
    jcxz end_count            ; If substring is empty, finish
    
compare_loop:
    mov dl, [si]              ; Get character from main string
    cmp dl, 0                 ; Check for end of string
    je end_count
    cmp dl, 13                ; Check for carriage return
    je end_count
    
    cmpsb                     ; Compare bytes at DS:SI and ES:DI, increment both
    jne no_match              ; If not equal, no match
    loop compare_loop         ; Continue comparing
    
    ; If all characters matched
    inc ax                    ; Increment counter
    dec si                    ; Adjust SI (because cmpsb incremented it)
    mov bx, si                ; Move to next position
    jmp next_pos
    
no_match:
    inc bx                    ; Move to next character
    jmp next_pos
    
end_count:
    pop bx
    pop cx
    pop di
    pop si
    ret

; --- print_num ---
; Input: AX = number to print
print_num:
    push ax
    push bx
    push cx
    push dx
    
    xor cx, cx                ; CX = digit counter
    mov bx, 10                ; BX = divisor
    
print_loop1:
    xor dx, dx                ; Clear DX for division
    div bx                    ; DX:AX / BX, quotient in AX, remainder in DX
    push dx                   ; Save remainder (digit)
    inc cx                    ; Increment digit counter
    test ax, ax               ; Check if quotient is 0
    jnz print_loop1           ; If not, continue
    
print_loop2:
    pop dx                    ; Get digit
    add dl, '0'               ; Convert to ASCII
    mov ah, 02h               ; DOS function: Print character
    int 21h                   ; Output the digit
    loop print_loop2          ; Repeat for all digits
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

END start