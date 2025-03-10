.model small
.stack 100h
.data
    array dw 6 * 12 dup(0) ; масив 6x12
.code
main proc
    mov ax, @data
    mov ds, ax

    lea di, array          ; адреса початку масиву

    mov bx, 0              ; ініціалізація рядка (X)

row_loop:
    mov cx, 0              ; ініціалізація стовпця (Y)
col_loop:

    ; Викликаємо функцію для обчислення X * (Y - 3)
    push bx                 ; зберігаємо значення BX
    push cx                 ; зберігаємо значення CX
    call calc              ; викликаємо функцію
    pop cx                  ; відновлюємо значення CX
    pop bx                  ; відновлюємо значення BX

    ; записуємо результат у елемент масиву
    push ax                 ; зберігаємо результат
    push bx                 ; передаємо X (рядок)
    push cx                 ; передаємо Y (стовпець)
    call store_element      ; записуємо значення
    pop cx                  ; відновлюємо значення Y
    pop bx                  ; відновлюємо значення X
    pop ax                  ; відновлюємо результат

    inc cx                  ; збільшуємо стовпець (Y)
    cmp cx, 12
    jl col_loop             ; якщо Y < 12, повторюємо

    inc bx                  ; збільшуємо рядок (X)
    cmp bx, 6
    jl row_loop             ; якщо X < 6, повторюємо

    mov ah, 4Ch
    int 21h
main endp

; Функція для обчислення X * (Y - 3)
calc proc
    ; на вході: BX = X, CX = Y
    mov dx, cx              ; переміщаємо Y у DX
    sub dx, 3               ; Y - 3
    mov ax, bx              ; переміщаємо X в AX

    ; Виконуємо множення вручну: AX * (Y - 3) = X + X + ... (Y-3 разів)
    mov cx, dx              ; копіюємо Y-3 в CX (це кількість додавань)
    xor dx, dx              ; очищаємо DX (для накопичення результату)
multiply_loop:
    add dx, ax              ; додаємо AX до DX (множимо X на Y-3)
    loop multiply_loop      ; повторюємо, поки CX не стане 0

    mov ax, dx              ; результат множення зберігаємо в AX
    ret
calc endp

; Процедура для запису значення у елемент масиву за координатами (X, Y)
store_element proc
    ; на вході: BX = X, DX = Y, AX = значення
    ; розрахуємо адрес у масиві: 
    ; адрес = array + (BX * 12 + DX) * 2
    mov si, bx              ; si = X
    ; Множимо X на 12
    add si, si              ; si = X * 2
    add si, si              ; si = X * 4
    add si, si              ; si = X * 8
    add si, bx              ; si = X * 12
    add si, dx              ; si = X * 12 + Y
    shl si, 1               ; помножити на 2, оскільки елементи масиву - слова
    lea di, array           ; адреса початку масиву
    add di, si              ; додаємо обчислений індекс до початкової адреси
    mov [di], ax            ; записуємо значення у масив
    ret
store_element endp

end main
