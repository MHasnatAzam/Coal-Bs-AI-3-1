org 100h
.data
array db 2,4,6,8
result db ?
.code
mov ax,@data
mov ds,ax  
mov cx,4
mov bl,0
LEA si,array
L1:
mov al,[si]
cmp al,bl
JL L2
mov bl,al
L2:
inc si
dec cx
JNZ L1
mov result,bl
mov dl,result
add dl,48
mov ah,2
int 21h
mov ah,4ch
int 21h