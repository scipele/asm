section .data
    a dd 101              ; define a variable a with value 5
    b dd 202             ; define a variable b with value 10
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
    lea rsi, [buffer + 11]  ; Point RSI to the end of our 12-byte buffer
    mov byte [rsi], 10
    mov ecx, 1
    mov ebx, 10

convert_loop:
    xor edx, edx        ; Clear EDX (by xoring it with itself) to prepare for division  
    div ebx             ; Divide EAX by 10, quotient in EAX and remainder in EDX
    add dl, '0'         ; Convert the remainder to ASCII
    dec rsi             ; Move back the pointer to store the next digit
    mov [rsi], dl       ; Store the ASCII digit in the buffer
    inc ecx             ; Increment the digit count
    test eax, eax       ; Check if the quotient is zero
    jnz convert_loop    ; If EAX is not zero, continue the loop

    ; Write the digits and trailing newline to stdout
    mov eax, 1
    mov edi, 1
    mov edx, ecx
    syscall

    ; Exit program
    mov eax, 60
    xor edi, edi
    syscall