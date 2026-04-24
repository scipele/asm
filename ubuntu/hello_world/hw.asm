section .data
    strg db "This is my first assembly program!", 0xA ; message to print with newline
    len equ $ - strg ; calculate length of the message and store it in len

section .text
    global _start

_start:
    ; Write message to stdout
    mov rax, 1          ; system call for write
    mov rdi, 1          ; file descriptor 1 is stdout
    mov rsi, strg        ; address of string to output
    mov rdx, len        ; number of bytes
    syscall

    ; Exit program
    mov rax, 60         ; system call for exit
    xor rdi, rdi        ; exit code 0
    syscall