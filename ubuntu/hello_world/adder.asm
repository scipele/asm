section .data
    a dd 65              ; define a variable a with value 5
    b dd 35             ; define a variable b with value 10
    newline db 10

section .bss
    buffer resb 12
    
section .text
    global _start

_start:
    ; Add the values of a and b
    mov eax, [a]        ; load the value of a into eax register
    add eax, [b]        ; add the value of b to eax
    ; Convert the result in eax to ASCII digits in buffer
    lea rsi, [buffer + 11]
    mov byte [rsi], 10
    mov ecx, 1
    mov ebx, 10

convert_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc ecx
    test eax, eax
    jnz convert_loop

    ; Write the digits and trailing newline to stdout
    mov eax, 1
    mov edi, 1
    mov edx, ecx
    syscall

    ; Exit program
    mov eax, 60
    xor edi, edi
    syscall