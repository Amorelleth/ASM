; задан байт, представить его в обратном коде

.model small	                                ; Модель памяти
	.stack 100h	                                ; Установка размера стека
    .486
	.data		                                ; Сегмент данных
        a db 10000000b
        b db ?

	.code	                                    ; Cегмент кода
        mov ax, @DATA	                        ; Пересылаем адрес сегмента данных в регистр AX
        mov ds, ax	                            ; Установка регистра DS на сегмент данных
        
        xor ax, ax
        mov al, a
        
        shl al, 1                               
        jc negative
        jnc positive
            
        negative:
            not al
            rcr al, 1
            mov b, al
            call exit

        positive:
            call exit    

        exit:
            mov ah, 4ch
            int 21h
            end
