.model small
.stack 100h
.data
.code

main proc

    push ax              
    push bx              
    push cx              

    call my_function

    pop cx               
    pop bx               
    pop ax               

main endp

my_function proc
    push ax              
    push bx              
    push cx              

    mov ax, 5678h        
    mov bx, 1234h        

    ; comparing 
    cmp ax, bx           
    jbe skip_compare     
    mov ax, bx           

skip_compare:
    pop cx               
    pop bx               
    pop ax    
    
               
    mov ah, 4Ch 
    ret   
                   
my_function endp

end main
