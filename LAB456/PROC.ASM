.model medium
    public	inputline, input, readfile, output, writefile, menu, algorithm
    extrn	start:far
    extrn   len:byte
    extrn   string:byte

.code
    inputline	proc
        locals @@
        @@buffer	equ [bp + 6]
            push bp
            mov bp,sp
            push ax
            push bx
            push cx
            push dx
            push di
            mov ah, 3fh
            xor bx, bx
            mov cx, 80
            mov dx, @@buffer
            int 21h
            jc @@ex
            cmp ax, 80
            jne @@m
            stc
            jmp short @@ex
        @@m:
            mov di, @@buffer
            dec ax
            dec ax
            add di, ax
            xor al, al
            stosb
        @@ex:
            pop di
            pop dx
            pop cx
            pop bx
            pop ax
            pop bp
            ret
    endp

    input	proc
        locals @@
        @@buffer	equ [bp + 6]
            push bp
            mov  bp, sp
            push ax
            push bx
            push cx
            push dx
            push di
            xor  bx, bx
            mov  cx, 4095
            mov  dx, @@buffer
        @@m1:	mov ah, 3fh
            int 21h
            jc @@ex
            cmp ax, 2
            je @@m2
            sub cx, ax
            jcxz @@m2
            add dx, ax
            jmp @@m1
        @@m2:	mov di, @@buffer
            add di, 4095
            sub di, cx
            xor al, al
            stosb
        @@ex:
            pop di
            pop dx
            pop cx
            pop bx
            pop ax
            pop bp
            ret
    endp

    output	proc
        locals @@
        @@buffer	equ [bp + 6]
            push bp
            mov  bp, sp
            push ax
            push bx
            push cx
            push dx
            push di
            mov di, @@buffer
            xor al, al
            mov cx, 0ffffh
            repne scasb
            neg cx
            dec cx
            dec cx
            jcxz @@ex
            cmp cx, 4095
            jbe @@m
            mov cx, 4095
        @@m:
            mov ah, 40h
            xor bx, bx
            inc bx
            mov dx, @@buffer
            int 21h
        @@ex:
            pop di
            pop dx
            pop cx
            pop bx
            pop ax
            pop bp
            ret
    endp

    readfile	proc
        locals @@
        @@buffer	equ [bp + 6]
        @@filnam	equ [bp + 8]
            push bp
            mov  bp, sp
            push ax
            push bx
            push cx
            push dx
            push di
            mov  ax, 3d00h
            mov  dx, @@filnam
            int 21h
            jc @@ex
            mov bx, ax
            mov cx, 4095
            mov dx, @@buffer
        @@m1:
            mov ah, 3fh
            int 21h
            jc @@er
            or ax, ax
            je @@m2
            sub cx, ax
            jcxz @@m2
            add dx, ax
            jmp @@m1
        @@m2:
            mov di, @@buffer
            add di, 4095
            sub di, cx
            xor al, al
            stosb
            mov ah, 3eh
            int 21h
        @@ex:
            pop di
            pop dx
            pop cx
            pop bx
            pop ax
            pop bp
            ret
        @@er:
            mov ah, 3eh
            int 21h
            stc
            jmp @@ex
    endp
    
    writefile proc
        locals @@
        @@filnam	equ [bp + 8]
        @@buffer	equ [bp + 6]
            push bp
            mov  bp, sp
            push ax
            push bx
            push cx
            push dx
            push di
            mov  ah, 3ch
            xor  cx, cx
            mov  dx, @@filnam
            int 21h
            jc @@ex
            mov  bx, ax
            mov  di, @@buffer
            xor  al, al
            mov  cx, 0ffffh
            repne scasb
            neg cx
            dec cx
            dec cx
            jcxz @@ex1
            cmp cx, 4095
            jbe @@m
            mov cx, 4095
        @@m:
            mov ah, 40h
            mov dx, @@buffer
            int 21h
            jc @@er
        @@ex1:
            mov ah, 3eh
            int 21h
        @@ex:
            pop di
            pop dx
            pop cx
            pop bx
            pop ax
            pop bp
            ret
        @@er:
            mov ah, 3eh
            int 21h
            stc
            jmp @@ex
    endp

    menu	proc
        locals @@
        @@ax		equ [bp - 82]
        @@buffer	equ [bp - 80]
        @@items	equ	[bp + 6]
            push bp
            mov bp, sp
            sub sp, 80
            push ax
        @@m:
            push @@items
            call output
            pop ax
            jc @@ex
            push ds
            push es
            push ss
            push ss
            pop  ds
            pop  es
            mov  ax, bp
            sub  ax, 80
            push ax
            call inputline
            pop ax
            pop es
            pop ds
            jc @@ex
            mov al, @@buffer
            cbw
            sub ax, '0'
            cmp ax, 0
            jl @@m
            cmp ax,@@ax
            jg @@m
            clc
        @@ex:
            mov sp, bp
            pop bp
            ret
    endp

    algorithm	proc
        locals @@
        @@ibuf	equ [bp + 6]
        @@obuf	equ [bp + 8]
        
            push bp
            mov bp,sp
            push ax
            push bx
            push cx
            push si
            push di

            
        mov cx,0ffffh
        mov di,@@ibuf
        mov si,@@obuf

        inc si
        mov dl, 'a'
        @@prewrite:
            mov [si], '0'
            add si, 2
            inc dl
            cmp dl, 123
            jne @@prewrite
        mov si, @@obuf


        @@cycle: 
            xor ax, ax
            mov al, [di]
            inc di
            cmp al, 0
            je @@ex

            cmp al, 96
            jle @@cycle
            
            cmp al, 123
            jge @@cycle

            sub al, 'a'
            add al, al
            inc al
            mov si, @@obuf
            add si, ax
            mov dl, [si]
            inc dl
            mov [si], dl

            jmp short @@cycle
        
        @@ex:
            mov di, @@obuf
            mov dl, 'a'
        @@prnt:
            mov al, dl
            mov [di], al
            add di, 2

            add dl, 1
            cmp dl, 123
            jne @@prnt
            mov al, 10
            mov [di], al
            inc di
            mov al, 13
            mov [di], al
            inc di
            mov al, 0
            mov [di], al
            inc di
            

            pop di
            pop si
            pop cx
            pop bx
            pop ax
            pop bp
            ret
    endp
                            
end start        
                            