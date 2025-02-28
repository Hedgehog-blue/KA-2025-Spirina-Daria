.model small
.stack 100h

.code
main proc
   
    mov ds, ax      

    mov dx, 1234h   ; to check the results in debug 
    xor dx, dx      ;comparing each bit so that it is always 0 (xor)
    ; xor sometimes faster than mov so it is a good way to replace mov 

    mov ah, 4Ch     ; Завершення програми
    int 21h
main endp
end main
