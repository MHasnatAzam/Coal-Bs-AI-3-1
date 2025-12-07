org 100h
.data
a db "Hasnat"
.code
mov ax,@data
mov ds,ax
mov si,offset a
mov cx,6
l1:
mov bx,[si]
push bx
inc si
loop l1
mov cx,6
l2:
pop dx 
mov ah,2 
mov dl,dl 
int 21h
loop l2