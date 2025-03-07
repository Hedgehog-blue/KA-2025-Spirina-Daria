.model small
.stack 100h
.data
    array dw 10 dup(?) ; uninitialized values 
    value db 30   ; starting value    
.code
main proc
    mov ax, @data
    mov ds, ax

    lea si, array     

    mov cx, 10         
fill_loop:
    mov al, value      
    mov [si], al       
    inc si           
    dec value         
    loop fill_loop     

    mov ah, 4Ch
    int 21h
main endp
end main
