.model small
.stack 100h
.data
    num1 dw 5678h
    num2 dw 1234h
    result dw ?

.code

main proc
    mov ax, @data       
    mov ds, ax

    push num2  
    push num1  

    call my_function  
    
    add sp, 4  

    mov result, ax  

    mov ah, 4Ch
    int 21h
main endp

my_function proc
    push bp
    mov bp, sp  

    mov ax, [bp+4]  
    mov bx, [bp+6]  

    cmp ax, bx
    jbe skip_compare
    mov ax, bx

skip_compare:
    pop bp
    ret

my_function endp

end main
