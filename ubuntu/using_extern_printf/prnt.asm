; compile with nasm -f elf64 prnt.asm -o prnt.o
; link with gcc: gcc -no-pie prnt.o -o prnt

extern printf

section .data
    formatString: db "Hello, the number is %d!", 0x0A, 0x00   
    ;                 |                     |      |     |
    ;                 |                     |      |     +--- null terminator for the string
    ;                 |                     |      +--------- newline character (0x0A)
    ;                 |                     +---------------- format specifier
    ;                 +-------------------------------------- string to print       

section .text
    global main

main:
    ; 1. Stack alignment (x86_64 ABI requires RSP to be 16-byte aligned before calling)
    push rbp
    mov rbp, rsp    ; rbp is now the base pointer for this function
                    ; rsp is still 16-byte aligned at this point, so we can call printf directly 

    ; 2. Set up arguments for printf
    mov rdi, formatString       ; 1st argument: Address of format string
    mov rsi, 42                 ; 2nd argument: Integer to print
    xor rax, rax                ; RAX must be 0 (no vector/floating-point arguments used)

    ; 3. Call printf (WRT ..plt is necessary for position-independent linking)
    call printf wrt ..plt

    ; 4. Restore stack and exit
    xor rax, rax                ; Set return value to 0
    leave                       ; Equivalent to mov rsp, rbp; pop rbp
    ret
