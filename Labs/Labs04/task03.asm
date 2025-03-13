.model small
.stack 100h
.data
.code
main    proc

    ; Example num to check if code works 
    mov ax, 5678h    
    mov bx, 1234h   ; (we have to see 1234 in ax)

    
    push ax
    push bx

    
    pop ax           
    pop bx  
    add ax,bx   

    push ax 
    pop ax     

          
    mov ah, 4Ch     
    int 21h
main endp
end main
