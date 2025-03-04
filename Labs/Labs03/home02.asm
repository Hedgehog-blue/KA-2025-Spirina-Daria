.model small
.stack 100h
.data
    a dw 150
    b dw 50
    c dw 0
.code
main proc
    ; Initialize data segment
    mov ax, @data
    mov ds, ax
; if (a > b) && (b < 100) then
;     if (a < 200) then
;         c = a + b
; else
;     a = 0
;     b = 0
    ; if (a > b)
    mov ax, a
    cmp ax, b
    jle else_part ; if a <= b, jump to else_part

    ; and (b < 100)
    mov ax, b
    cmp ax, 100
    jge else_part ; if b >= 100, jump to else_part

    ; THEN part
    ; if (a < 200)
    mov ax, a
    cmp ax, 200
    jge end_if ; if a >= 200, skip addition and go to end_if

    ; c = a + b
    mov ax, a
    add ax, b
    mov c, ax
    jmp end_program ; program end

else_part:
    ; a = 0
    mov a, 0
    ; b = 0
    mov b, 0

end_if:
end_program:
    ; Exit program
    mov ah, 4Ch
    int 21h
main endp
end main
