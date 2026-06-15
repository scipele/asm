; compile and link with
; nasm -f elf64 hw.asm -o hw.o
; then link with ld hw.o -o hw

section .data
    ;db: "define byte" and is used to allocate and initialize a byte of memory with a specific value.
    ; In this case, we are using db to define a string of bytes that represent the message we want to print,
    ; followed by a newline character (0xA in hexadecimal). The string is null-terminated, 
    ; meaning it ends with a 0 byte, which is common for strings in assembly language.
    strg db "This is my first assembly program!", 0xA, 0x00 ; message to print with newline, and null terminator
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