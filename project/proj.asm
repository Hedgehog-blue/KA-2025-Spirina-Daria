.MODEL SMALL
.STACK 100h
.DATA

    argument        DB 128 DUP(0)
    param_count     DW 0   

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
main PROC
    mov ax, @data
    mov es, ax

; Parse command line arguments
    call get_argument
    
    ; Get the first parameter (substring to search for)
    mov cx, 1
    call get_param      ; Renamed from get_one_arg
    
    ; Copy the substring to our buffer and calculate its length
    call copy_substring
    
    ; Read input
    call read_input
    
    ; Process the buffer
    call process_buffer
    
    ; Sort the results
    call sort_results
    
    ; Print the results
    call print_results
    
    ; Exit program
    mov ah, 4Ch
    int 21h
main ENDP

separator PROC
    mov al, [si]        ; Load the current character into AL
    cmp al, 020h        ; Check if it's a space (ASCII 32)
    je separator_end
    cmp al, 09h         ; Check if it's a tab (ASCII 9)
    je separator_end
    cmp al, 0Dh         ; Check if it's a carriage return (ASCII 13)
separator_end:
    ret
separator ENDP
    
get_param_count PROC
    mov dx, [param_count]
    ret
get_param_count ENDP


get_argument PROC
    xor ch, ch
    mov cl, [ds:80h]    ; Get the length of the command line argument
    inc cx
    mov si, 81h         ; Start of the command line arguments
    mov di, offset argument ; Destination for the argument
skip_seps:
    call separator      ; Check if the current character is a separator
    jne copy_arg
    inc si              ; Move to the next character
    loop skip_seps      ; Continue until the end of the argument
copy_arg:
    push cx
    jcxz done_copy      ; If CX is zero, we're done copying
    cld                 ; Auto increment SI and DI
    rep movsb           ; copy cx bytes from ds:si to es:di
done_copy:
    push es
    pop ds              ; make ds = es
    pop cx
    xor bx, bx          ; Clear BX for counting parameters
    jcxz end_get_arg    ; If CX is zero, jump to end
    mov si, offset argument ; Load the address of the argument into SI
param_loop:             ; Renamed from numParams_loop
    call separator
    jne next_char       ; If not a separator, jump to next_char
    mov byte ptr [si], 0 ; Null-terminate the string
    inc bx              ; Increment the parameter count
next_char:
    inc si              ; Move to the next character
    loop param_loop     ; Continue until the end of the argument
end_get_arg:
    mov [param_count], bx ; Store the number of parameters
    ret
get_argument ENDP

get_param PROC
    xor al, al          ; AL = 0 (null terminator)
    mov di, offset argument ; Load the address of the argument into DI
    dec cx              ; Adjust parameter number to be 0-based
    jcxz end_copy       ; If CX is zero, we're looking for the first parameter
    cmp cx, [param_count]
    jae end_copy        ; If CX is greater than the number of parameters, jump to end_copy
    cld                 ; Auto increment SI and DI
search:
    scasb               ; Scan string for AL (null terminator)
    jnz search          ; Continue searching for the null terminator
    loop search         ; If CX is not zero, continue searching
end_copy:
    ret
get_param ENDP

copy_substring PROC
    push si
    push di
    push cx
    
    mov si, di          ; SI = pointer to the substring argument
    lea di, substring   ; DI = destination for the substring
    xor cx, cx          ; CX = length counter
    
copy_loop:
    mov al, [si]        ; Get character from argument
    cmp al, 0           ; Check for null terminator
    je copy_done
    
    mov [di], al        ; Copy character to substring buffer
    inc si
    inc di
    inc cx
    jmp copy_loop
    
copy_done:
    mov substring_len, cl ; Store substring length
    
    pop cx
    pop di
    pop si
    ret
copy_substring ENDP

read_input PROC 

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


    ret 
read_input ENDP
    


process_buffer PROC
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    ; Process each line in the buffer
process_next_line:
    ; Check if we've processed the entire buffer
    mov bx, buffer_pos
    cmp bx, bytes_read
    jae process_buffer_exit
    
    ; Find the start of current line
    lea si, buffer
    add si, bx               ; SI points to start of current line
    
    ; Save the starting position
    mov di, si               ; DI = start of current line

    call find_eol

    ; Process this line
    mov si, di          ; SI = start of line
    push bx
    call count_occurrences
    pop bx
    
    ; Store the results in arrays
    mov si, result_count
    shl si, 1           ; Multiply by 2 for word size
    mov occurrences[si], ax  ; Store occurrence count
    mov dx, line_number ; DX = line number
    mov line_numbers[si], dx ; Store line number
    inc result_count    ; Increment result counter
    
    inc line_number 
    
    ; Skip line ending characters and update buffer_pos
    call skip_line_endings
    
    jmp process_next_line
    
process_buffer_exit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
process_buffer ENDP


find_eol PROC   
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
    ret 
find_eol ENDP
    

skip_line_endings PROC
     ; Update buffer position (skip CR/LF if present)
    inc bx              ; Skip the null we just added
    mov buffer_pos, bx
    cmp bx, bytes_read
    jae skip_line_exit  ; If we've reached the end, exit
    
    ; Check for CR/LF sequence
    mov al, [buffer+bx]
    cmp al, 13          ; Check for CR
    jne check_lf
    inc bx
    mov buffer_pos, bx
    
check_lf:
    cmp bx, bytes_read
    jae skip_line_exit
    mov al, [buffer+bx]
    cmp al, 10          ; Check for LF
    jne skip_line_exit
    inc bx
    mov buffer_pos, bx
    
skip_line_exit:
    ret
skip_line_endings ENDP


count_occurrences PROC
    push si
    push di
    push cx
    push bx
    
    xor ax, ax          ; AX = count of occurrences (result)
    mov bx, si          ; BX = start of the string
    
next_pos:
    mov si, bx          ; SI = current position
    lea di, substring   ; DI = start of substring
    mov cl, substring_len ; CL = substring length
    cmp cl, 0
    je end_count
    xor ch, ch          ; Clear high byte
    
compare_loop:
    mov dl, [si]        ; Get character from main string
    cmp dl, 0           ; Check for end of string
    je end_count

    cmpsb               ; Compare bytes at DS:SI and ES:DI, increment both
    jne no_match        ; If not equal, no match
    loop compare_loop   ; Continue comparing
    
    ; If all characters matched
    inc ax              ; Increment counter
    mov cl, substring_len ; Calculate new position
    xor ch, ch          ; Clear high byte
    add bx, cx          ; Skip the entire substring (non-overlapping)
    jmp next_pos
    
no_match:
    inc bx              ; Move to next character
    jmp next_pos
    
end_count:
    pop bx
    pop cx
    pop di
    pop si
    ret
count_occurrences ENDP


sort_results PROC
    ; Sort results using bubble sort (from least to most occurrences)
    push ax
    push bx
    push cx
    push dx
    push si
    push di

    mov cx, result_count
    dec cx              ; N-1 passes
    jcxz sort_exit      ; If only 0 or 1 result, no need to sort
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


sort_exit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
sort_results ENDP

print_results PROC
    push ax
    push bx
    push cx
    push dx
    push si
    ; Print the sorted results
    mov cx, result_count    ; Number of results
    mov si, 0               ; Start at the first result
    
print_loop:
    cmp si, cx
    jge print_exit
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
    jmp print_loop

print_exit:
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_results ENDP


print_num PROC
    push ax
    push bx
    push cx
    push dx
    
    xor cx, cx                ; CX = digit counter
    mov bx, 10                ; BX = divisor
    
    ; Handle zero specially
    test ax, ax
    jnz print_num_nonzero
    mov dl, '0'
    mov ah, 02h
    int 21h
    jmp print_num_exit

print_num_nonzero:
    ; Convert number to digits
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
    
print_num_exit:
    pop dx
    pop cx
    pop bx
    pop ax
    ret
print_num ENDP

END main 