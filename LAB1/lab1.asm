; 2(a + b^2)(2c - d^2)/4e операнды байты, вычисления знаковые

.model small	                                ; Модель памяти
    .stack 100h	                                ; Установка размера стека
    .486
    .data		                        ; Сегмент данных
        a db 2
        b db 2
        c db 1
        d db 2
        e db 2

        ; movsx операнд_1,операнд_2 — переслать с распространением знака.
        ; Расширяет 8 или 16-разрядное значение операнд_2, которое может быть регистром или операндом в памяти,
        ; до 16 или 32-разрядного значения в одном из регистров, используя значение знакового бита для заполнения
        ; старших позиций операнд_1. Данную команду удобно использовать для подготовки операндов со знаками
        ; к выполнению арифметических действий;

        ; Команда CWD преобразовывает имеющее знак слово в регистре AX в имеющее знак двойное слово в паре
        ; регистров DX:AX путем расширения старшего бита регистра AX (бита знака) на все биты регистра DX.

	.code	                                ; Cегмент кода
        mov ax, @DATA	                        ; Пересылаем адрес сегмента данных в регистр AX
        mov ds, ax	                        ; Установка регистра DS на сегмент данных

        movsx ax, b
        movsx bx, b
        imul  bx                                ; b^2
        movsx bx, a
        add   bx, ax                            ; (a + b^2)
        mov   ax, 2
        imul  bx                                ; 2(a + b^2)
        mov   bx, ax                            ; 2(a + b^2) -> BX


        movsx cx, c
        mov   ax, 2
        imul  cx                                ; 2c
        mov   cx, ax                            ; 2c -> CX
        movsx ax, d
        movsx dx, d
        imul  dx                                ; d^2
        sub   cx, ax                            ; (2c - d^2)
        mov   ax, cx                            ; CX -> AX
        imul  bx                                ; 2(a + b^2)(2c - d^2)
        mov   bx, 4                             ; 2(a + b^2)(2c - d^2) / 4
        idiv  bx
        cwd
        movsx bx, e                             ; 2(a + b^2)(2c - d^2) / 4e
        idiv  bx
        
        mov ax, 4C00h	                        ; DOS функция выхода из программы
        int 21h	                                ; Выход из программы
	end
