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
    