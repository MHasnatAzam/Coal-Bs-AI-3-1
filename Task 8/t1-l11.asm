org 100h
.data
a db 1001010b
.code
mov ax,@data
mov ds,ax
mov bl,a
shl bl,1
shl bl,2
shl bl,3
shr bl,2
shr bl,3
ror bl,2
ror bl,1
rol bl,1
rol bl,2

