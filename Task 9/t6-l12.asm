org 100h

.data
array1 db 10,13,"You entered Number$"
array2 db 10,13,"You entered Character$"
msg    db 10,13,"You entered Special Character$"
.code
mov ax, @data
mov ds, ax
mov ah, 1
int 21h       
mov bl, al
cmp bl, '0'
jl check_alpha
cmp bl, '9'
jle is_number
check_alpha:
cmp bl, 'A'
jl check_lower
cmp bl, 'Z'
jle is_char
check_lower:
cmp bl, 'a'
jl is_special
cmp bl, 'z'
jle is_char
is_special:
mov dx, offset msg
mov ah, 9
int 21h
jmp exit
is_number:
mov dx, offset array1
mov ah, 9
int 21h
jmp exit
is_char:
mov dx, offset array2
mov ah, 9
int 21h
exit:
mov ah, 4Ch
int 21h
