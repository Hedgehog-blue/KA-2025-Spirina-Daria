.model small 
.stack 100h 

.data 
.data
    inputBuffer db 512 dup(0)     ; Buffer for combined input
    subStr      db 255 dup('$')   ; Buffer for substring
    mainStr1    db 255 dup('$')   ; Buffer for first main string
    mainStr2    db 255 dup('$')   ; Buffer for second main string
    subLen      dw 0              ; Length of substring
    mainLen1    dw 0              ; Length of first main string
    mainLen2    dw 0              ; Length of second main string
    occurrences1 dw 0             ; Counter for occurrences in first string
    occurrences2 dw 0             ; Counter for occurrences in second string
    totalOccur  dw 0              ; Total occurrences in both strings
    
    promptInput db 'Enter "substring mainstring1 mainstring2": $'
    resultMsg1  db 'Occurrences in string 1: $'
    resultMsg2  db 'Occurrences in string 2: $'
    resultTotal db 'Total occurrences: $'
    errorMsg    db 'Invalid input format!$'
    newline     db 13, 10, '$'    


.code 
main proc 
    mov ax, @data
    mov ds, ax
    
    ; Display prompt for input
    mov ah, 9
    lea dx, promptInput
    int 21h
    
    ; Read input string
    call ReadInput ; future func that will be writtten 
    
    ; Parse input to extract substring and main strings
    call ParseInput
    cmp ax, 0                ; Check if parsing was successful
    je error_exit
    
    ; Find occurrences in first string
    lea si, mainStr1
    mov cx, mainLen1
    call CountOccurrences
    mov occurrences1, ax

    ; Find occurrences in second string
    lea si, mainStr2
    mov cx, mainLen2
    call CountOccurrences
    mov occurrences2, ax
    
    ; Calculate total occurrences
    mov ax, occurrences1
    add ax, occurrences2
    mov totalOccur, ax
    
    ; Display results
    mov ah, 9
    lea dx, newline
    int 21h
    lea dx, resultMsg1
    int 21h
    
    mov ax, occurrences1
    call PrintDecimal
    
    mov ah, 9
    lea dx, newline
    int 21h
    lea dx, resultMsg2
    int 21h
    
    mov ax, occurrences2
    call PrintDecimal
    
    mov ah, 9
    lea dx, newline
    int 21h
    lea dx, resultTotal
    int 21h
    
    mov ax, totalOccur
    call PrintDecimal
    
    jmp program_exit
    
    error_exit:
    mov ah, 9
    lea dx, newline
    int 21h
    lea dx, errorMsg
    int 21h
    
program_exit:
    ; Exit program
    mov ah, 4Ch
    int 21h
main endp

; Procedure to read input from stdin
ReadInput proc
    push bx
    push cx
    push si
    
    lea si, inputBuffer      ; SI points to input buffer
    xor cx, cx               ; CX will count characters
    
read_loop:
    ; Read a character
    mov ah, 1
    int 21h
    
    ; Check for Enter key (CR, 13)
    cmp al, 13
    je done_reading
    
    ; Store character in buffer
    mov [si], al
    inc si
    inc cx
    jmp read_loop
    
done_reading:
    mov byte ptr [si], 0     ; Add null terminator
    
    pop si
    pop cx
    pop bx
    ret
ReadInput endp

; Procedure to parse input and extract substring and two main strings
; Format: "substring mainstring1 mainstring2"
; Returns:
;   AX - 1 if successful, 0 if error
ParseInput proc
    push bx
    push cx
    push dx
    push si
    push di
    
    lea si, inputBuffer      ; SI points to input buffer
    lea di, subStr           ; DI points to substring buffer
    
    ; Extract substring (first word)
    xor cx, cx               ; CX will count substring characters
    
extract_substring:
    mov al, [si]
    
    ; Check for end of string or space
    cmp al, 0
    je parse_error           ; Error if end of string before space
    cmp al, ' '
    je space_found1
    
    ; Copy character to substring buffer
    mov [di], al
    inc si
    inc di
    inc cx
    jmp extract_substring
    
space_found1:
    mov byte ptr [di], '$'   ; Add string terminator to substring
    mov subLen, cx           ; Save substring length
    
    ; Skip spaces
    inc si                   ; Move past the space
    
    ; Check if we've reached the end of input
    cmp byte ptr [si], 0
    je parse_error
    
    ; Extract first main string
    lea di, mainStr1         ; DI points to first main string buffer
    xor cx, cx               ; CX will count first main string characters
    
extract_mainstring1:
    mov al, [si]
    
    ; Check for end of string or space
    cmp al, 0
    je parse_error           ; Error if end of string before second main string
    cmp al, ' '
    je space_found2
    
    ; Copy character to first main string buffer
    mov [di], al
    inc si
    inc di
    inc cx
    jmp extract_mainstring1
    
space_found2:
    mov byte ptr [di], '$'   ; Add string terminator to first main string
    mov mainLen1, cx         ; Save first main string length
    
    ; Skip spaces
    inc si                   ; Move past the space
    
    ; Check if we've reached the end of input
    cmp byte ptr [si], 0
    je parse_error
    
    ; Extract second main string
    lea di, mainStr2         ; DI points to second main string buffer
    xor cx, cx               ; CX will count second main string characters
    
extract_mainstring2:
    mov al, [si]
    
    ; Check for end of string
    cmp al, 0
    je extract_done
    
    ; Copy character to second main string buffer
    mov [di], al
    inc si
    inc di
    inc cx
    jmp extract_mainstring2
    
extract_done:
    mov byte ptr [di], '$'   ; Add string terminator to second main string
    mov mainLen2, cx         ; Save second main string length
    
    mov ax, 1                ; Success
    jmp parse_exit
    
parse_error:
    mov ax, 0                ; Error
    
parse_exit:
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
ParseInput endp

; Procedure to count occurrences of substring in a main string
; Input:
;   SI - Pointer to main string
;   CX - Length of main string
; Output:
;   AX - Number of occurrences
CountOccurrences proc
    push bx
    push cx
    push dx
    push si
    push di
    
    mov dx, cx               ; Save main string length in DX
    xor bx, bx               ; Use BX for counting occurrences
    
    ; Check if substring is longer than main string
    mov ax, subLen
    cmp ax, dx
    ja count_done            ; If substring is longer, no occurrences possible
    
    ; Calculate maximum possible start position: mainLen - subLen + 1
    mov cx, dx
    sub cx, subLen
    inc cx                   ; CX = number of positions to check
    
    ; SI already points to main string
    
count_loop:
    ; Check if we've reached the end of positions to check
    cmp cx, 0
    je count_done
    
    ; Compare substring at current position
    push cx
    push si
    lea di, subStr
    mov cx, subLen
    call CompareStrings
    
    ; If match found, increment occurrences counter
    cmp ax, 1
    jne no_match
    inc bx
    
no_match:
    pop si
    pop cx
    
    inc si                   ; Move to next position in main string
    dec cx                   ; Decrement positions counter
    jmp count_loop
    
count_done:
    mov ax, bx               ; Return occurrences count in AX
    
    pop di
    pop si
    pop dx
    pop cx
    pop bx
    ret
CountOccurrences endp

; Procedure to compare strings
; Input:
;   SI - Offset of first string
;   DI - Offset of second string
;   CX - Length to compare
; Output:
;   AX - 1 if strings match, 0 if not
CompareStrings proc
    push si
    push di
    push cx
    push bx
    
    mov ax, 1                ; Assume strings match
    
compare_loop:
    cmp cx, 0
    je compare_done
    
    mov bl, [si]
    mov bh, [di]
    cmp bl, bh
    jne strings_different
    
    inc si
    inc di
    dec cx
    jmp compare_loop
    
strings_different:
    mov ax, 0                ; Strings don't match
    
compare_done:
    pop bx
    pop cx
    pop di
    pop si
    ret
CompareStrings endp

PrintDecimal proc
    push ax     ; Save registers we'll modify
    push bx
    push cx
    push dx
    
    mov bx, 10  ; Divisor
    xor cx, cx  ; Counter for number of digits
    
    ; Special case for 0
    test ax, ax
    jnz pd_convert
    
    ; Just print '0' directly
    mov ah, 02h
    mov dl, '0'
    int 21h
    jmp pd_exit
    
pd_convert:
    ; Convert to decimal digits and push them onto the stack
    xor dx, dx          ; Clear DX for division
    div bx              ; DX:AX / 10 = AX remainder DX
    
    push dx             ; Save remainder (will be a digit 0-9)
    inc cx              ; Increment digit counter
    
    test ax, ax         ; Check if quotient is 0
    jnz pd_convert      ; Continue if not zero

    ; Print digits from the stack (in correct order)
pd_print:
    pop dx              ; Get next digit
    add dl, '0'         ; Convert to ASCII
    mov ah, 02h         ; DOS function: output character
    int 21h             ; Display character
    
    loop pd_print       ; Decrement CX and loop if not zero
    
pd_exit:
    pop dx              ; Restore registers
    pop cx
    pop bx
    pop ax
    ret
PrintDecimal endp

end main