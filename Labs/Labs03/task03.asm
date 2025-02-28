.model small
.stack 100h
.data
    a dw 0001h  
    b dw 0010h

.code
main proc
    mov ax, @data
    mov ds, ax  
    
    mov ax, a   
    and ax, b   
    cmp ax, b   
    jne set_zero 

    mov ax, 1  
    jmp store_a

set_zero:
    mov ax, 0   

store_a:
    mov a, ax  
    
    mov ax, 4C00h
    int 21h     

main endp
end main
