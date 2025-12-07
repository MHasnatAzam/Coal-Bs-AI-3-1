org 100h
.data
a db "hasnat"
.code
mov ax,@data
mov ds,ax
mov si,offset a
mov cx,6
l1:
mov dl,[si]
inc si
mov ah,2
int 21h
loop l1

