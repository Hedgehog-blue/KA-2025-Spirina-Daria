.model small
.stack 100h
.data
    a dw -2      
    b db -2       
.code
main proc
    mov ax, @data
    mov ds, ax

    mov ax, a    
    mov al, b    
    cbw           
    add ax, a    

    
    mov dx, ax   
    sar dx, 15   
    xor ax, dx   
    sub ax, dx   

    mov a, ax    

    mov ax, 4C00h
    int 21h
main endp
end main
