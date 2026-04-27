section .data
    newline db 10

section .bss
    buffer resb 12
    
section .text
    global _start

_start:
    ; Create a loop to print integers from 1 to 10
     mov r9d, 1          ; Initialize counter to 1
    mov ebx, 10

loop_start:
    ; Convert the current value of ecx to ASCII digits in buffer
     mov eax, r9d
    lea rsi, [buffer + 12]
    xor r8d, r8d
    call print_int     ; Call the conversion loop to convert the integer to ASCII
    ; increment the counter
     inc r9d             ; Increment the counter
     cmp r9d, 81        ; Compare counter with num of integers to print
    jl loop_start       ; If counter is less than the number, repeat the loop
    jmp done


print_int:
    xor edx, edx        ; Clear EDX (by xoring it with itself) to prepare for division  
    div ebx             ; Divide EAX by 10, quotient in EAX and remainder in EDX
    add dl, '0'         ; Convert the remainder to ASCII
    dec rsi             ; Move back the pointer to store the next digit
    mov [rsi], dl       ; Store the ASCII digit in the buffer
    inc r8d             ; Increment the digit count
    test eax, eax       ; Check if the quotient is zero
    jnz print_int    ; If EAX is not zero, continue the loop

    ; Append newline after digits so one write syscall prints both
    mov byte [rsi + r8], ',' ; Add a comma after the number

    ; Write the digits and trailing newline to stdout
    mov eax, 1
    mov edi, 1
    lea edx, [r8d + 1]
    syscall

    ret

done:

    ; Exit program
    mov eax, 60
    xor edi, edi
    syscall