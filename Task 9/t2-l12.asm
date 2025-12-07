org 100h
.data
.code
mov bl,2
mov al,3
mul bl
mov dx,ax
add dx, 48
mov ah,2
int 21h
mov ah, 4ch
int 21h


