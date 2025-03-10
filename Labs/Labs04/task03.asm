.model small
.stack 100h
.data
.code
main    proc
    mov ax, @data
    mov ds, ax

    ; Example num to check if code works 
    mov ax, 5678h    
    mov bx, 1234h   ; (we have to see 1234 in ax)

    
    push ax
    push bx

    
    pop ax           
    pop bx           

    cmp ax, bx      
    jbe skip       
    mov ax, bx      
    mov bx, 0       
skip:
    mov ah, 4Ch     
    int 21h
main endp
end main
