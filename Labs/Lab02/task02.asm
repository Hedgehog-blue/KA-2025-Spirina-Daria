.model small
.stack 100h
.data 
    msg db '9 $'

.code 
main    proc 

    mov ax, SEG @data
    mov ds, ax
    mov dx, offset msg
    mov ah, 9
    mov di, offset msg 
    mov cl, [di]

    start_loop:
    int 21h 
    dec cl
    mov [di], cl
    cmp cl, 2fh
    jnz start_loop

    mov ax, 4c00h 
    int 21h 

main endp
end main