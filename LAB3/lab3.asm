; Дана матрица M*N.
; Выделить в ней наиболее подходящую квадратную матрицу и
; вычислить сумму элементов ее главной диагонали.

.model small 
.stack 100h
.486
.data
        N       dw      3
        M       dw      4
	MM      dw      5

        Matrix  dw      1,   2,   3,  4
                dw      5,   6,   7,  8
                dw      9,  10,  11, 12

        Sum     dw      ?
.code
        mov     ax,     @data
        mov     ds,     ax

        mov     dx,     [MM]            ;вычислим длину строки матрицы
        shl     dx,     1

        lea     bx,     [Matrix]
        mov     si,     0
        shl     si,     1
        mov     ax,     0  
        mov     cx,     [N]

        For:
                add     ax,     [bx + si]
		add     si,     dx
        loop    For

        mov     [Sum],  ax

        mov     ax,     4C00h
        int     21h
end
