.model small
.stack 100h
.data
	str1	db 4096 dup(?)
	str2    db 0, 30, 1000 dup(0)              ;строка с количеством слов разной длины в виде нормальной строки из числе и пробелов
	buf db 5000 dup(0)                      ;буфер для всяких чтений из файла и прочего
	path db 100 dup(0)                      ;стркоа - путь к файлу

	;буферы на случай доп заданий
	; dop1_str db 0, 30, 1000 dup(0)
	; dop2_str db 0, 30, 1000 dup(0)
	; dop3_str db 0, 30, 1000 dup(0)
	
	mSize equ 7 ; число пунктов меню, поменять в случае допа на 8, 9, 10
	;пункты меню
	mExit   db 'Exit', 0                    ;выход
	mMenu   db 'Menu', 0                    ;меню
	mPrint  db 'Print strings', 0           ;вывод
	mCreate db 'Create new strings', 0      ;рассчёт строк
	mInput  db 'Input strings', 0           ;ввод строк
	mRead   db 'Read file',0                ;чтение файла
	mSave   db 'Save file',0                ;сохранение файла
	; mDop1   db 'Optionally 1', 0            ;доп 1
	; mDop2   db 'Optionally 2', 0            ;доп 2
	; mDop3   db 'Optionally 3', 0            ;доп 3
	
	;различные сообщения
	strChoose   db 'Choose item',0          ;выберите пункт
	strPath     db 'Enter path to file',0   ;введите путь к файлу
	strNot      db 'File not found',0       ;файл не найден
	strOpen     db 'File opened',0          ;файл открыт
	strClose    db 'File closed',0          ;файл закрыт
	strCreate   db 'File created',0         ;файл создан
	strOld      db 'Old strings:',0         ;старые строки
	strNew      db 'New strings:',0         ;новые строки
	strEnter db 13, 10, 0                       ;перенос строки
	;массив сообщений (массив смещений строк)
	msgs dw offset mExit, offset mMenu, offset mPrint, offset mCreate, offset mInput, offset mRead, offset mSave;, offset mDop1, offset mDop2, offset mDop3 ;на случай допов
	;массив смещений функций меню
	func dw offset Exit, offset Menu, offset Print, offset Create, offset Input, offset Read, offset Save;, offset fDop1, offset fDop2, offset fDop3;на случай допов
	quit dw ?                               ;переменная для определения, не нужно ли выходить из главного цикла
	count dw ?                              ;число пунктов меню
	file dw 0                               ;переменная файла
	
.code
.486
	mov ax, @data
	mov ds, ax
	mov es, ax

	pusha
	push ax
	call Menu                               ;выводим меню
	pop ax
	popa

	;основной цикл программы
ml: pusha
	lea ax, strChoose
	push ax
	call puts                               ;выводим сообщение "Choose item"
	pop ax
	popa

	push ax
	call getchar                            ;чтение символа
	pop ax

	sub al, '0'
	movsx si, al                            ;получаем индекс функции
	cmp al, 0
	jl ml                                   ;проверяем, что индекс больше 0
	cmp al, mSize
	jg ml                                   ;проверяем, что меньше числа функций
	sal si, 1                               ;умножаем на 2

	pusha                                   ;сохраняем всё в стек
	push cx                                 ;место, куда будет записан результат выполнения функции (значение на возврате)
	call func[si]
	pop cx
	mov quit, cx                            ;переменная = 0, если остаёмся в цикле
	popa
	mov cx, quit

	jcxz ml                                 ;если не 0, то выходим из программы

	mov ah, 4ch
	int 21h

;интерфейсные функции
proc Exit near                              ;выход из программы
	push bp
	mov bp, sp
	mov word ptr [bp+4], 1                  ;пишем в стек 1
	pop bp
	ret
endp

proc Menu near                              ;вывод меню
	push bp
	mov bp, sp
	mov word ptr [bp+4], 0                  ;пишем в стек 0

	mov ax, '0'                             ;символ - номер пункта
	mov di, 0                               ;номер сообщения
	mov bx, ' '                             ;пробел для разделения

	;цикл вывода сообщений меню
lp: pusha
	push ax
	call putc                               ;вывод номера меню
	popa

	pusha
	push bx
	call putc                               ;вывод пробела
	popa

	pusha
	push msgs[di]                           ;вывод сообщения
	call puts
	pop ax
	popa

	add di, 2
	inc ax
	cmp di, 2*mSize                         ;проверка на выход из цикла
	jne lp

	mov bx, 13
	pusha
	push bx
	call putc                               ;возврат каретки
	popa	   
	mov bx, 10
	pusha
	push bx
	call putc                               ;перенос строки
	popa

	pop bp
	ret
endp


proc Print near                             ;вывод строк
	push bp
	mov bp, sp
	mov word ptr [bp+4], 0                  ;пишем 0 в стек
	;вывод старых строк
	lea ax, strOld
	pusha
	push ax
	call puts                               ;выводим строку: старые строки
	pop ax
	popa

	;цикл вывода старых строк
	lea di, str1
lprint:
	pusha
	push di
	call puts                               ;выводим строку
	pop si
	mov count, si                           ; в стеке останется число выведенных символов
	popa
	add di, count
	inc di
	cmp byte ptr[di], 30                    ;проверяем, что не дошли до конца
	jne lprint

	;вывод новых строк
	lea ax, strNew
	pusha
	push ax
	call puts
	pop di
	popa

	;цикл вывода новых строк
	lea di, str2
lprint2:
	pusha
	push di
	call puts                               ;вывод очередной строки
	pop si
	mov count, si
	popa
	add di, count                           ;перезодим на седующую строку
	inc di
	cmp byte ptr[di], 30
	jne lprint2

	mov bx, 13
	pusha
	push bx
	call putc                               ; в конце выводим возврат каретки
	popa		   

	mov bx, 10
	pusha
	push bx
	call putc                               ; в конце выводим перенос строки
	popa


	pop bp
	ret
endp

proc Create near                            ;расчёт новых строк
	push bp
	mov bp, sp
	mov word ptr [bp+4], 0
	lea di, str2
	lea si, str1
	pusha
	push di
	push si
	call reorg                              ;вызываем функцию расчёта новых строк
	popa


	pop bp
	ret
endp

proc Input near                             ;ввод строк с клавиатуры
	push bp
	mov bp, sp
	mov word ptr [bp+4], 0

	lea di, str1                            ;обнуляем массив для записи строк
	mov cx, 250
	xor ax, ax
	rep stosd


	lea di, str1
iml:pusha
	push di
	call gets                               ;считали строку
	pop di
	mov count, di                           ;выбрали из стека число считанных строк
	popa

	cmp word ptr count, -1                  ;проверили наличие конца файла
	je ine
	add di, count
	inc di
	jmp iml
ine:mov byte ptr[di], 30

	pop bp
	ret
endp

proc Read near                              ;чтение строк из файла
	push bp
	mov bp, sp
	mov word ptr [bp+4], 0

	lea di, str1
	mov cx, 250
	xor eax, eax
	rep stosd
	mov byte ptr str1[1], 30 ;пишем символ конца файла, на случай если вдруг строки не будут считаны
	pusha
	push offset strPath
	call puts                               ;пришлашение для ввод файла
	pop ax
	popa

	pusha
	push offset path
	call gets                               ;считали файл
	pop ax
	mov count, di
	popa

	pusha
	push offset path
	push 'r'
	call fopen                              ;открыли файл
	pop word ptr file
	popa

	cmp byte ptr file, 0
	jne rf

	pusha
	push offset strNot                      ;если не смогли считать - вывели сообщение об ошибке
	call puts
	pop ax
	popa

	jmp er

rf: lea di, str1
	pusha
	push di
	push word ptr file
	call fgets                              ;читаем строки из файла
	pop di
	popa

er: pop bp
	ret
endp

proc Save near                              ;запись в файл
	push bp
	mov bp, sp
	mov word ptr [bp+4], 0

	pusha
	push offset strPath
	call puts                               ;приглашение ввести имя файла
	pop ax
	popa

	pusha
	push offset path
	call gets                               ;считали имя файла
	pop ax
	mov count, di
	popa

	pusha
	push offset path
	push 'w'
	call fopen                              ;открыли файл
	pop word ptr file
	popa

	lea di, str2

lsave:



	pusha
	push di
	push word ptr file
	call fputs                              ;записали в файл
	pop count
	popa

	add di, count                           ;перешли к следующей строке
	inc di
	cmp byte ptr[di], 30                    ;проверили конец файла
	jne lsave



	pusha
	push word ptr file
	call fclose                             ;закрыли файл
	popa


	pusha
	push offset strClose
	call puts                               ;вывели сообщение о закрытии файла
	pop ax
	popa


	pop bp
	ret
endp

proc fclose near                            ;функция закрытия файла
	push bp
	mov bp, sp

	mov bx, [bp+4]                          ;взяли из стека идентификатор
	mov ah, 3Eh
	int 21h
	pop bp
	ret 2
endp

proc fopen near                             ;функция открытия файла
	push bp
	mov bp, sp

	cmp word ptr [bp+4], 'r'                ;если в стеке r открываем на чтение
	je frd                                  ;если в стеке не r, Открываем на запись
	mov ah, 3Dh
	mov al, 2
	xor cx, cx
	mov dx, word ptr [bp+6]                 ;выбрали из стека адрес файла
	int 21h
	mov bx, word ptr[bp+6]
	mov word ptr[bp+6], ax                  ;помещаем в стек идентификатор файла
	jnc foe

	mov word ptr[bp+6], bx                  ;если файл не получилось открыть, то создаём и открываем его
	pusha
	push offset strCreate
	call puts
	pop ax
	popa


	mov ah, 5Bh
	mov al, 2
	xor cx, cx
	mov dx, word ptr [bp+6]
	int 21h                                 ;создание и открытие файла
	mov word ptr[bp+6], ax                  ;помещаем в стек идентификатор файла
	jnc foe

	mov word ptr[bp+6], 0                   ;если не смогли открыть - помещаем в стек 0
	pop bp
	ret 2

frd:mov ah, 3Dh                             ;открытие файла на чтение
	mov al, 3
	xor cx, cx
	mov dx, word ptr [bp+6]
	int 21h
	jnc foe

	mov word ptr[bp+6], 0                   ;если не смогли открыть - помещаем в стек 0
	pop bp
	ret 2

foe:mov word ptr[bp+6], ax                  ;если смогли - помещаем индентификатор
	pop bp
	ret 2
endp

proc putc near                              ;вывод символа
	push bp
	mov bp, sp

	mov ah, 06h
	mov dx, [bp+4]                          ;берём символ из стека
	int 21h                                 ;выводим символ

	pop bp
	ret 2
endp

proc puts near                              ;вывод строки
	push bp
	mov bp, sp

	xor ax, ax                              ;ищем ноль байт
	mov cx, -1                              ;начальное состояние счтчика символов
	mov di, [bp+4]                          ;поместили в di значение указателя на строку
	repne scasb                             ;считаем число символов
	add cx, 2
	neg cx                                  ;получили корректное значение
	push cx
	mov ah, 40h                             ;код вывода
	mov bx, 1                               ;вывод в stdout
	pop cx
	mov dx, [bp+4]                          ;поместили в dx адрес начала строки
	mov [bp+4], cx                          ;записали в стек количество выведенных символов
	int 21h

	mov bx, 13
	pusha
	push bx
	call putc                               ;вывели возврат каретки
	popa
	mov bx, 10
	pusha
	push bx
	call putc                               ;вывели перенос строки
	popa

	pop bp
	ret
endp

proc fputs near                             ;вывод строки в файл
	push bp
	mov bp, sp

	xor ax, ax                              ;ищем ноль байт
	mov cx, -1                              ;начальное состояние счтчика символов
	mov di, [bp+6]                          ;поместили в di значение указателя на строку
	repne scasb                             ;считаем число символов
	add cx, 2
	neg cx                                  ;получили корректное значение

	push cx
	mov ah, 40h                             ;код вызода
	mov bx, [bp+4]                          ;вывод в файл (поместили идентификатор файла)
	pop cx
	mov dx, [bp+6]                          ;поместили в dx адрес начала строки
	mov [bp+6], cx                          ;занесли в стек число выведенных символов
	push bx
	int 21h
	pop bx

	mov ah, 40h
	mov cx, 1
	mov dx, offset strEnter                 ;записали в файл перенос строки
	int 21h

	pop bp
	ret 2
endp


proc getchar near                           ;функция получения символа из входного потока
	push bp
	mov bp, sp

	mov ah, 0Ch
	mov al, 01h
	int 21h
	mov [bp+4], ax                          ;поместили считанный символ в стек

	mov bx, 13
	pusha
	push bx
	call putc                               ;вывели возврат каретки
	popa
	mov bx, 10
	pusha
	push bx
	call putc                               ;вывели этот символ
	popa

	pop bp
	ret
endp

proc gets near                              ;функция чтения строки
	push bp
	mov bp, sp

	lea di, buf
	mov cx, 60
	xor ax, ax
	rep stosd                               ;заполнили буфер нулями
	lea di, buf
	mov byte ptr [di], 254                  ;размер строки ограничим 254
	mov ah, 0Ah
	mov dx, di
	int 21h                                 ;считали строку
	mov cx, -1
	add di, 2
	mov al, 13
	repne scasb                             ;ищем конец строки
	add cx, 2
	neg cx
	mov bx, cx
	lea si, buf
	add si, 2
	cmp byte ptr[si], 26                    ;проверяем на ввод ctrl-z
	je eof
	mov di, [bp+4]
	rep movsb
	mov [bp+4], bx                          ;помещаем в стек число считанных символов
	jmp ent
eof:mov word ptr[bp+4], -1                  ;если ввели ctrl-z помещаем в стек -1
ent:mov bx, 10
	pusha
	push bx
	call putc                               ;вывели перенос строки
	popa

	pop bp
	ret
endp

proc fgets near                             ;функция чтения из файла
	push bp
	mov bp, sp

	mov di, [bp+6]
	mov cx, 60
	xor ax, ax
	rep stosd                               ;записали нули в буфер

	mov cx, -1
	mov ah, 3Fh
	mov bx, [bp+4]                          ;считали идентификатор файла
	mov dx, [bp+6]                          ;считали адрес начала строки
	mov al, 2
	int 21h

	mov cx, ax
	mov di, [bp+6]
	xor bx, bx


fml:mov al, [di]
	cmp al, 13
	jne fg
	mov byte ptr[di], 0                     ;помещаем в конец строки 0
fg: inc bx
	inc di
	loop fml
	inc di
	mov byte ptr[di], 30                    ;после строки помещаем символ 30
	mov [bp+6], bx

	pop bp
	ret 2
endp


proc reorg near                             ;функция преобразования строки
	push bp
	mov bp, sp

	mov si, [bp+4]
	mov di, [bp+6]

; 	xor dx, dx      ;цикл прохода по всему тексту и замена
; 	dec si
; 	mov ah, ' '
; sl: inc si
; 	mov al, ','     ;запятых
; 	cmp [si], al
; 	jne s2
; 	mov [si], ah
; s2: mov al, ';'     ;точек с запятой на пробелы
; 	cmp [si], al
; 	jne s3
; 	mov [si], ah
; s3: mov al, 30      ;до тех пор, пока не встретим символ конца файла
; 	cmp [si], al
; 	jne sl


	mov di, [bp+6]
	mov cx, 50
	xor ax, ax
	rep stosd

	mov bl, 30
	xor ax, ax
	mov bh, ' '
	mov si, [bp+4]              ;источник
	mov di, [bp+6]              ;приёмник
	push di

	;начало обработки очередной строки
s12:cmp[si], bl                 ;проверяем наличие 30 символа - символ конца файла
	je ext
	cmp [si], bh                ;проверяем наличие пробела
	jne s11                     ;если не пробел - обрабатываем слово
	inc si
	jmp s12                     ;иначе начинаем обрабатывать пробелы (пропускать)
s11:cmp [si], ah
	je ex



	sw: pop di
		push di
		mov dx, si              ;сохраняем исходную строку
	ns: mov al, [si]
		cmp al, bh              ;проверка на пробел
		je ew
		cmp al, ah              ;проверка на 0
		je ew
		cmp al, [di]            ;сравниваем al с [di++]
		jne edw                 ;переход, елси не совпали
		inc si
		inc di
		jmp ns                  ;обрабатываем дальше

		;если закончилось исходное слово, переход сюда
	ew: cmp [di], ah            ;если в [di] = 0 - слова совпали
		je ewi
		cmp [di], bh            ; = пробел - слова совпали - слово не подходит
		je ewi
	sp1:inc di                  ;анализируем следующую букву
		cmp [di], ah            ;сравнили с 0 байтом
		je ewc                  ;если так, то больше сравнить не с чем, слово можно копировать
		cmp [di], bh            ;сравнили с пробелом, если не пробел пропускаем букву, проверяем снова
		jne sp1
		;иначе убираем пробелы
	s10:inc di
		cmp [di], ah            ;если ноль-байт, то всё ок
		je ewc
		cmp [di], bh            ;если пробел
		je s10                  ;обрабатываем следующий пробел
		mov si, dx              ;иначе - началось новое слово, загружаем начало исходного слова
		jmp ns                  ;переходим обратно к сравнению

		;сюда перешли, если обнаружили несовпадение с исхожным с
	edw:cmp [di], ah            ;если 0 в конце [di], то слово точно ОК
		je ewc                  ;переход на копирование слова
		cmp [di], bh            ;если встретили пробел, то анализируем
		je sp3                  ;
	sp7:inc di                  ;остаётся случай, когда в di не тот символ, переходим к следующему
		cmp [di], ah            ;проверка на конец строки
		je ewc
		cmp [di], bh            ;проверка на конец очередного слова
		je sp3                  ;переход кпропуску пробелов
		jmp sp7                 ;пропускаем конец старого слова

	sp3:inc di
		cmp [di], ah            ;если 0, то конец, всё ОК
		je ewc
		cmp [di], bh            ;если пробел - продолжаем анализ
		je sp3
		mov si, dx              ;иначе загружаем обратно слово
		jmp ns                  ;анализируем следующее из di
		;случай, когда слово нельзя копировать
	ewi:cmp [si], ah            ;если встретили 0
		jne sp9
		mov cx, -1
		pop di
		push di
		xor ax, ax
		repne scasb             ;пропускаем всю строку-приёмник
		dec di                  ;корректируем di
		jmp ex                  ;переход в конец
	sp9:mov al, ' '
		mov cx, -1
		cmp [si], al            ;проверка на пробел
		jne sw                  ;анализируем дальше, елси пробел
		inc si                  ;коррект.
		jmp ewi                 ;анализируем следующее слово

		;случай, когда слово можно копировать
	ewc:mov cx, -1              ;счётчик в -1
		xor ax, ax
		pop di                  ;заменить
		push di
		repne scasb             ;пропускаем всё до конца строки
		dec di
		add cx, 2
		neg cx
		jcxz sp4
		mov [di], bh            ;добавляем пробел
		inc di

		xor cx, cx
		mov si, dx              ;загружаем начало слова в si
	sp4:cmp [si], ah
		je sp5
		cmp[si], bh
		je sp5
		inc cx                  ;считаем длину слова
		inc si
		jmp sp4

	sp5:mov si, dx
		rep movsb               ;копируем слово


	sp8:cmp [si], bh            ;пропсукаем пробелы в конце
		jne sp6
		inc si
		jmp sp8
	sp6:cmp [si], ah
		jne sw                  ;если не 0 байт, то анализируем следующее слово
	ex: mov [di], ah            ;иначе помещаем ноль-байт в конец di
		inc di                  ;переход к следующему символу приёмника
		pop ax
		push di                 ;обновили в стеке значение
		xor ax, ax
		inc si                  ;переход к следующему символу исходного текста (следующая строка)
		jmp s12

ext:mov[di], bl             ;поместили символ 30, когда всё обработаем
	pop di

	pop bp
	ret 4
endp

end