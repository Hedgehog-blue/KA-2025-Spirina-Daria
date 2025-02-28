.model small 
.stack 100h 
.data 


.code 
main    proc 
    mov ax, 200  
    mov dx, 100  

    mov bx, ax   
    mov ax, dx   
    mov dx, bx   
main endp 
end main 

