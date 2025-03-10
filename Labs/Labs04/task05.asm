.model small
.stack 100h
.data
.code

main proc
    mov ax, @data       
    mov ds, ax

    ; Push parameters onto the stack
    push 1234h           ; second parameter
    push 5678h           ; first parameter
    call my_function

    ; Caller cleans up the stack
    add sp, 4            ; remove 2 parameters (2 bytes each)

main endp

my_function proc
    ; Function accesses parameters from the stack
    pop bx               ; get second parameter (1234h)
    pop ax               ; get first parameter (5678h)

    ; Compare the two parameters
    cmp ax, bx
    jbe skip_compare
    mov ax, bx

skip_compare:
    ret                  ; Return to the caller

my_function endp

end main
