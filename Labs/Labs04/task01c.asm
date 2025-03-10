.model small
.stack 100h
.data
    array dw 10 dup(?) 
.code
main proc
    mov ax, @data
    mov ds, ax

    ; Step 1: Zero the array using XOR
    lea di, array
    mov cx, 10          
zero_loop:
    xor ax, ax          
    mov [di], ax        
    add di, 2           
    loop zero_loop

    ; Step 2: Set first two Fibonacci numbers manually
    lea di, array
    xor ax, ax
    mov [di], ax        
    mov ax, 1
    mov [di+2], ax      

    ; Step 3: Fill next 8 Fibonacci numbers
    mov cx, 8           
    mov si, 0           
    mov di, 4           
fib_loop:
    mov ax, array[si+2] 
    add ax, array[si]   
    mov array[di], ax   
    add si, 2           
    add di, 2          
    loop fib_loop

    
    mov ah, 4Ch
    int 21h
main endp
end main
