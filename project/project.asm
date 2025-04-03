.MODEL SMALL
.STACK 100h
.DATA
    ; Buffers for input
    inputBuffer    DB 255 DUP(0)  ; Buffer for combined input
    substring      DB 255 DUP(0)  ; Buffer for substring
    mainstring     DB 255 DUP(0)  ; Buffer for main string
    substring_len  DB 0           ; Length of substring
    mainstring_len DW 0           ; Length of main string
    
    ; Results
    res_count      DB 0           ; Number of occurrences
    
    ; Prompts and messages
    prompt_input   DB 'Enter substring and mainstring (separated by space): $'
    result_msg     DB 'Number of occurrences: $'
    newline        DB 13, 10, '$'
    space          DB ' $'

.CODE
start:
    mov ax, @data
    mov ds, ax
    mov es, ax
    
    ; Prompt for input
    mov ah, 09h
    lea dx, prompt_input
    int 21h
    
    ; Read combined input from stdin
    lea dx, inputBuffer
    call read_string
    
    ; Parse the input to separate substring and mainstring
    lea si, inputBuffer
    lea di, substring
    call parse_input
    
    ; Process the main string
    lea si, mainstring
    call count_occurrences
    mov res_count, al
    
    ; Print newline
    mov ah, 09h
    lea dx, newline
    int 21h
    
    ; Display results
    call print_results
    
    ; Exit program
    mov ah, 4Ch
    int 21h

; --- read_string ---
; Reads a string from stdin into buffer pointed by DX
; Returns: AX = string length
read_string:
    push bx
    push cx
    push dx
    push si
    
    mov si, dx          ; SI = buffer pointer
    xor cx, cx          ; CX = character count
    
read_loop:
    mov ah, 01h         ; DOS input character function
    int 21h
    
    cmp al, 13          ; Check for Enter key (CR)
    je end_read
    
    mov [si], al        ; Store character in buffer
    inc si              ; Move to next buffer position
    inc cx              ; Increment character count
    
    cmp cx, 254         ; Check buffer limit
    jl read_loop
    
end_read:
    mov byte ptr [si], 0    ; Null-terminate the string
    mov ax, cx          ; Return length in AX
    
    pop si
    pop dx
    pop cx
    pop bx
    ret

; --- parse_input ---
; Parses inputBuffer to extract substring and mainstring
; SI = source buffer, DI = destination for substring
parse_input:
    push ax
    push bx
    push cx
    push dx
    
    ; First copy substring until space
    xor cx, cx          ; CX = substring length
copy_substring:
    mov al, [si]
    
    ; Check for space or end of string
    cmp al, ' '
    je end_substring
    cmp al, 0
    je end_parse
    
    ; Copy character to substring buffer
    mov [di], al
    inc si
    inc di
    inc cx
    jmp copy_substring
    
end_substring:
    ; Store substring length
    mov substring_len, cl
    
    ; Null-terminate substring
    mov byte ptr [di], 0
    
    ; Skip the space
    inc si
    
    ; Now copy mainstring to its buffer
    lea di, mainstring
    xor cx, cx          ; CX = mainstring length
    
copy_mainstring:
    mov al, [si]
    
    ; Check for end of string
    cmp al, 0
    je end_mainstring
    
    ; Copy character to mainstring buffer
    mov [di], al
    inc si
    inc di
    inc cx
    jmp copy_mainstring
    
end_mainstring:
    ; Store mainstring length
    mov mainstring_len, cx
    
    ; Null-terminate mainstring
    mov byte ptr [di], 0
    
end_parse:
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; --- count_occurrences ---
count_occurrences:
    push si
    push di
    push cx
    push bx
    
    xor ax, ax                ; AX = occurrence count (result)
    mov bx, si                ; BX = start of string
    
next_pos:
    mov si, bx
    lea di, substring
    mov cl, substring_len
    jcxz end_count            ; If substring is empty
    
compare_loop:
    mov dl, [si]
    cmp dl, 0                 ; Check for end of string
    je end_count
    
    cmpsb
    jne no_match
    loop compare_loop
    
    ; If all characters matched
    inc ax                    ; Increment counter
    mov bx, si                ; Move by substring length
    jmp next_pos
    
no_match:
    inc bx                    ; Move by 1 character
    jmp next_pos
    
end_count:
    pop bx
    pop cx
    pop di
    pop si
    ret

; --- print_results ---
print_results:
    push ax
    push bx
    push cx
    push dx
    
    ; Print result message
    mov ah, 09h
    lea dx, result_msg
    int 21h
    
    ; Print occurrence count
    xor ax, ax
    mov al, res_count
    call print_num
    
    ; Print newline
    mov ah, 09h
    lea dx, newline
    int 21h
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

; --- print_num ---
print_num:
    push ax
    push bx
    push cx
    push dx
    
    xor cx, cx
    mov bl, 10
    
print_loop1:
    xor ah, ah
    div bl
    push ax
    inc cx
    cmp al, 0
    jne print_loop1
    
print_loop2:
    pop dx
    mov dl, dh
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_loop2
    
    pop dx
    pop cx
    pop bx
    pop ax
    ret

END start