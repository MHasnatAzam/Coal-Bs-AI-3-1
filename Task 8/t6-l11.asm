org 100h

.data
a db 0Dh,0Ah, "You entered Vowel.$"
b db 0Dh,0Ah, "You entered Numeric Value.$"
c db 0Dh,0Ah, "You entered Alphabet.$"
d db 0Dh,0Ah, "You entered Special Symbol.$"
e db 0Dh,0Ah, "Please enter a valid value.$"

.code
main:
    mov ax, @data
    mov ds, ax
    mov ah, 1
    int 21h
    mov bl, al      
    cmp bl, 'A'
    je vowel
    cmp bl, 'E'
    je vowel
    cmp bl, 'I'
    je vowel
    cmp bl, 'O'
    je vowel
    cmp bl, 'U'
    je vowel
    cmp bl, 'a'
    je vowel
    cmp bl, 'e'
    je vowel
    cmp bl, 'i'
    je vowel
    cmp bl, 'o'
    je vowel
    cmp bl, 'u'
    je vowel
    cmp bl, '0'
    jb not_num
    cmp bl, '9'
    ja not_num
    jmp number
not_num:
    cmp bl, 'A'
    jb symbol
    cmp bl, 'Z'
    jbe alphabet
    cmp bl, 'a'
    jb symbol
    cmp bl, 'z'
    jbe alphabet
    jmp symbol
vowel:
    mov ah, 09h
    lea dx, a
    int 21h
    jmp exit
number:
    mov ah, 09h
    lea dx, b
    int 21h
    jmp exit

alphabet:
    mov ah, 09h
    lea dx, c
    int 21h
    jmp exit

symbol:
    mov ah, 09h
    lea dx, d
    int 21h
    jmp exit

exit:
    mov ah, 4Ch
    int 21h
