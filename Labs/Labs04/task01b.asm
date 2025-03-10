.model small
.stack 100h
.data
    array dw 6 * 12 dup(0) ; array 6x12
.code
main proc
    mov ax, @data
    mov ds, ax

    lea di, array       

    mov bx, 0          

row_loop:
    mov cx, 0           
col_loop:

    mov dx, bx          
    sub dx, 3           

    mov ax, cx          
    imul dx             

    mov [di], ax        
    add di, 2           

    inc cx              
    cmp cx, 12
    jl col_loop         

    inc bx              
    cmp bx, 6
    jl row_loop         

    
    mov ah, 4Ch
    int 21h
main endp
end main
