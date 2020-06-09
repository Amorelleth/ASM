; Определить, сколько раз в строке повторяются одинаковые буквы.

.model small	                    ; Модель памяти
	.stack 100h	                    ; Установка размера стека
    .486

    .data
        string  db 41               ; 40 символов
        symbol  db 2
        len     db ?                ; длина

	.code
        start:
            mov ah, 0Ah             ; ввод строки
            lea dx, string
            int 21h
        
            mov ah, 2h              ; перевод строки
            mov dl, 10
            int 21h
        
            xor bx, bx              ; очистить счетчик
            xor cx, cx
            mov cl, [len + 1]       ; длина строки
            lea di, string          ; на строку
            mov al, 'c'             ; символ, который надо подсчитать

        m1:
            repne scasb             ; искать символ в строке
            jnz short exit          ; символ не найден, выход

        m2:                         ; найден
            inc bl                  ; увеличить счетчик на 1
            test cx, cx             ; если СХ не 0, в строке есть символы,
            jnz short m1            ; продолжить поиск
        
        exit:
            mov ax, bx              ; вывод на экран
            xor cx, cx
            mov bx, 10              ; основание сс. 10 для десятеричной и т.п.
        
        oi2:
            xor     dx, dx
            div     bx
                                    
            push    dx              ; Делим число на основание сс. В остатке получается последняя цифра.
            inc     cx              ; Сразу выводить её нельзя, поэтому сохраним её в стэке.

            test    ax, ax
            jnz     oi2

            mov     ah, 2h

        oi3:
            pop     dx
            add     dl, '0'         ; Извлекаем очередную цифру, переводим её в символ и выводим.
            int     21h
            loop    oi3

            xor ax, ax              ; ждать нажатия клавиши
            int 16h
        
            mov ah, 4ch
            int 21h
            end
        
    end start
