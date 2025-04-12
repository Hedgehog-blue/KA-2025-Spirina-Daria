.model SMALL
.stack 100h
.DATA

strings DB 4096 DUP(0)
pointers DW 20 DUP(0)

message_1 "Enter something ", 0Dh, 0Ah, "$"
message_output "Your input: ", 0Dh,0Ah, "$" 

string_count DW 0
position     DW 0

.code 
main PROC
    mov ax, @data
    mov ds, ax 

    mov word ptr [position], offset strings

    mov cx, 20
    mov si, 0


input_loop:
    push cx 

    call display_msg1
    call get_input 

    mov bx, [pointers + si]
    cmp byte ptr [bx], '$'
    je finish_input

    inc word ptr [string_count]
    add si, 2

    pop cx
    loop input_loop

main ENDP

;
display_msg1 PROC

display_msg1 ENDP

;
get_input PROC

read_letters:

process_lines:

get_input ENDP
; 
display_msg2 PROC

msg2_loop:

display_msg2 ENDP 
;
display_string PROC

display_string ENDP
;
display_new PROC

display_new ENDP


end main 



