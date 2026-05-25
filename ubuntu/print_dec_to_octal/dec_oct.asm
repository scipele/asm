section .bss
    buffer resb 4        ; Buffer to hold octal string (3 digits + newline)

section .text
    global _start

_start:
    ; start with a hard coded base 10 integer to convert to octal
    mov rax, 79         ; example decimal number to convert
    mov rdi, buffer + 3 ; RDI points to final byte in our buffer
    mov byte [rdi], 0x0A  ; add newline character
    dec rdi             ; Move back to position for last octal digit

build_octal_str_loop:
    xor rdx, rdx        ; Clear RDX for division
    mov rbx, 8          ; Load Divisor for octal into rbx
    div rbx             ; RAX = RAX / 8, RDX = RAX % 8 (remainder)
    add rdx, '0'        ; Convert remainder to ASCII
    mov [rdi], dl       ; Store octal digit in buffer
    dec rdi             ; Move to next buffer position

    test rax, rax       ; Continue until quotient becomes 0
    jz loop_end
    jmp build_octal_str_loop

loop_end:
    inc rdi             ; Point to first digit in resulting octal string


;print the octal string stored in buffer moved to rdx
    mov rsi, rdi         ; pointer to first digit
    mov rax, 1           ; sys_write
    mov rdi, 1           ; stdout
    mov rdx, buffer + 4  ; one byte past end of buffer
    sub rdx, rsi         ; number of bytes to print (digits + newline)
    syscall


; Exit
mov rax, 60
xor rdi, rdi
syscall