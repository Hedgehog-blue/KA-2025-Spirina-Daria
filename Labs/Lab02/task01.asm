.model small 
.stack 100h 
.data 
msg db " $"

.code 
main proc
    mov ax, SEG @data 
    mov ds, ax
    mov dx, offset msg
    mov ah, 9
    mov di, offset msg
    mov cx, 30h
    mov [di], cl

    start_loop:
    int 21h 
    inc cx
    mov [di], cl
    cmp cx, 3ah 
    jnz start_loop

    mov ax, 4c00h
    int 21h
main endp
end main 