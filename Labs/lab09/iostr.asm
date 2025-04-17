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
    jmp end_input

    pop cx

end_input:
    call display_output

    mov ax, 4C00h
    int 21h

main ENDP

;
display_msg1 PROC
    mov ah, 09h
    mov dx, offset prompt_msg
    int 21h
    ret
display_msg1 ENDP

;
get_input PROC
    mov bx, [position]
    mov [pointers + si], bx
    mov bx, [position]
read_letters:
    mov ah, 01h
    int 21h
    
    
    cmp al, 0Dh
    je process_newline
    
    ; Store the character in the buffer
    mov [bx], al
    inc bx
    jmp read_char_loop
process_lines:
    ; Read the Line Feed character (0Ah) that follows Enter
    mov ah, 01h
    int 21h
    
    ; Replace CRLF with $ (string terminator)
    mov byte ptr [bx], '$'
    inc bx
    
    ; Update the current position in the buffer
    mov [current_pos], bx
    
    ret
get_input ENDP
; 
display_msg2 PROC
    mov ah, 09h
    mov dx, offset output_msg
    int 21h
    
    ; Check if any strings were entered
    mov cx, [string_count]
    test cx, cx
    jz end_output             ; Skip if no strings were entered
    
    ; Calculate the starting index for the last string
    mov si, cx
    dec si
    shl si, 1  
msg2_loop:
    call display_string
    
    ; Move to the previous string
    sub si, 2
    loop output_loop
    
end_output:
    ret
display_msg2 ENDP 
;
display_string PROC
    mov dx, [pointers + si]
    
    ; Display the string
    mov ah, 09h
    int 21h
    
    ; Display CRLF
    call display_newline
    
    ret
display_string ENDP
;
display_new PROC
    mov dl, 0Dh
    mov ah, 02h
    int 21h
    mov dl, 0Ah
    int 21h
    ret
display_new ENDP


end main 



