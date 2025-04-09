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
    buffer_pos      DW 0           ; Result: number of occurrences
    line_number     DW 0 

    ; Arrays to store results before sorting
    occurrences     DW 100 DUP(0)  ; Array to store counts of occurrences
    line_numbers    DW 100 DUP(0)  ; Array to store line numbers
    result_count    DW 0           ; Count of results

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
    
    ; Initialize buffer position
    mov buffer_pos, 0
    mov line_number, 0
    mov result_count, 0
    
    ; Process each line in the buffer
process_next_line:
    ; Check if we've processed the entire buffer
    mov bx, buffer_pos
    cmp bx, bytes_read
    jae sort_results
    
    ; Find the start of current line
    lea si, buffer
    add si, bx               ; SI points to start of current line
    
    ; Save the starting position
    mov di, si               ; DI = start of current line
    
    ; Find the end of line (look for CR, LF, or null)
find_eol:
    mov al, [si]
    cmp al, 0                ; Check for null terminator
    je found_eol
    cmp al, 13               ; Check for CR
    je found_eol
    cmp al, 10               ; Check for LF
    je found_eol
    inc si
    inc bx                   ; Increment buffer position
    jmp find_eol
    
found_eol:
    ; Mark end of line with null terminator
    mov byte ptr [si], 0
    
    ; Process this line
    mov si, di               ; SI = start of line
    push bx
    call count_occurrences
    pop bx
    
    ; Store the results in arrays
    mov si, result_count
    shl si, 1                ; Multiply by 2 for word size
    mov occurrences[si], ax  ; Store occurrence count
    mov dx, line_number      ; DX = line number
    mov line_numbers[si], dx ; Store line number
    inc result_count         ; Increment result counter

    
    inc line_number 


    ; Update buffer position (skip CR/LF if present)
    inc bx                   ; Skip the null we just added
    mov buffer_pos, bx
    cmp bx, bytes_read
    jae sort_results         ; If we've reached the end, exit
    
    ; Check for CR/LF sequence
    mov al, [buffer+bx]
    cmp al, 13               ; Check for CR
    jne check_lf
    inc bx
    mov buffer_pos, bx
    
check_lf:
    cmp bx, bytes_read
    jae sort_results
    mov al, [buffer+bx]
    cmp al, 10               ; Check for LF
    jne process_next_line
    inc bx
    mov buffer_pos, bx
    
    ; Process next line
    jmp process_next_line

    ; Sort results using bubble sort (from least to most occurrences)
sort_results:
    mov cx, result_count
    dec cx                  ; N-1 passes
    jcxz print_results      ; If only 0 or 1 result, no need to sort

outer_loop:
    push cx                 ; Save outer loop counter
    mov si, 0               ; Initialize inner loop index
    
inner_loop:
    mov bx, si
    shl bx, 1               ; Convert to word index
    mov ax, occurrences[bx] ; Get current occurrence
    
    mov di, si
    inc di
    shl di, 1               ; Convert to word index
    mov cx, occurrences[di] ; Get next occurrence
    
    ; Compare current with next
    cmp ax, cx
    jle no_swap             ; If current <= next, no swap needed
    
    ; Swap occurrences
    mov occurrences[bx], cx
    mov occurrences[di], ax
    
    ; Swap line numbers
    mov ax, line_numbers[bx]
    mov cx, line_numbers[di]
    mov line_numbers[bx], cx
    mov line_numbers[di], ax
    
no_swap:
    inc si                  ; Next element
    mov dx, result_count
    dec dx
    cmp si, dx              ; Check if we reached the end
    jl inner_loop           ; If not, continue inner loop
    
    pop cx                  ; Restore outer loop counter
    loop outer_loop         ; Continue outer loop

print_results:
    ; Print the sorted results
    mov cx, result_count    ; Number of results
    mov si, 0               ; Start at the first result
    
print_loop:
    mov bx, si
    shl bx, 1               ; Convert to word index
    
    ; Print occurrence count
    mov ax, occurrences[bx]
    call print_num
    
    ; Print space
    mov ah, 02h
    mov dl, ' '
    int 21h
    
    ; Print line number
    mov ax, line_numbers[bx]
    call print_num
    
    ; Print new line
    mov ah, 02h
    mov dl, 13              ; CR
    int 21h
    mov dl, 10              ; LF
    int 21h
    
    ; Move to next result
    inc si
    cmp si, cx
    jl print_loop

exit_program:  
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
    cmp cl, 0
    je end_count
    xor ch, ch                ; If substring is empty, finish
    
compare_loop:
    mov dl, [si]              ; Get character from main string
    cmp dl, 0                 ; Check for end of string
    je end_count

    cmpsb                     ; Compare bytes at DS:SI and ES:DI, increment both
    jne no_match              ; If not equal, no match
    loop compare_loop         ; Continue comparing
    
    ; If all characters matched
    inc ax                    ; Increment counter
    mov cl, substring_len     ; Calculate new position
    xor ch, ch                ; Clear high byte
    add bx, cx                ; Skip the entire substring (non-overlapping)
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