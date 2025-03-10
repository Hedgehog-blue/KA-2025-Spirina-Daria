.model small
.stack 100h
.data
    array dw 6 * 12 dup(0) 
.code
main proc
    mov ax, @data
    mov ds, ax

    lea di, array          

    mov bx, 0              

row_loop:
    mov cx, 0              
col_loop:

   
    push bx                 
    push cx                 
    call calc              
    pop cx                  
    pop bx                 

    
    push ax                 
    push bx                 
    push cx                 
    call store_element      
    pop cx                  
    pop bx                  
    pop ax                  

    inc cx                  
    cmp cx, 12
    jl col_loop             

    inc bx                 
    cmp bx, 6
    jl row_loop             

    mov ah, 4Ch
    int 21h
main endp


calc proc
   
    mov dx, cx              
    sub dx, 3               
    mov ax, bx              

    
    mov cx, dx             
    xor dx, dx              
multiply_loop:
    add dx, ax              
    loop multiply_loop      

    mov ax, dx             
    ret
calc endp


store_element proc

     mov si, bx            
    

    add si, si              
    add si, si              
    add si, si              
    add si, bx              
    add si, dx             
    shl si, 1               
    lea di, array           
    add di, si              
    mov [di], ax            
    ret
store_element endp

end main
