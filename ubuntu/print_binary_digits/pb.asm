section .data
    msg db "Enter a integer number (0-255): "
    msg_len equ $ - msg

section .bss
    buf_input resb 16       ; Reserve 16 bytes for user input
    buffer resb 10          ; Reserve 10 bytes for the string, space, and newline

section .text
    global _start

_start:
    ; --- STEP 1: Print Prompt ---
    mov rax, 1           ; sys_write
    mov rdi, 1           ; stdout
    mov rsi, msg         ; pointer to message
    mov rdx, 32          ; message length
    syscall    
    
    ; --- STEP 2: READ INPUT ---
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    mov rsi, buf_input      ; memory address
    mov rdx, 16             ; max bytes
    syscall                 ; rax now holds number of bytes read

    ; --- STEP 3: CONVERT ASCII TEXT TO INTEGER ---
    mov rsi, buf_input      ; rsi points to start of input
    xor rax, rax            ; rax = 0 (accumulator)
convert_bin_loop:
    movzx rbx, byte [rsi]  ; load next character
    cmp rbx, '0'           ; below '0'? stop
    jl convert_done
    cmp rbx, '9'           ; above '9'? stop
    jg convert_done
    sub rbx, '0'           ; ASCII digit -> numeric value
    imul rax, 10           ; result *= 10
    add rax, rbx           ; result += digit
    inc rsi
    jmp convert_bin_loop
convert_done:

    ; --- STEP 4: CONVERT TO BINARY STRING ---
    ; al now holds the integer value (0-255)
    mov rdi, buffer     ; RDI points to our buffer
    mov rcx, 8          ; Loop 8 times


build_binary_str_loop:
    shl al, 1           ; Shift MSB into Carry Flag
    mov dl, '0'         ; Start with ASCII '0'
    adc dl, 0           ; Add the Carry Flag (0 or 1) to '0'
    mov [rdi], dl       ; Store '0' or '1' in buffer
    inc rdi             ; Move to next buffer position
    cmp rcx, 5          ; 4 bits have been written when rcx == 5
    jne .no_space
    mov byte [rdi], ' ' ; Insert space after 4th bit
    inc rdi             ; Move past the space

.no_space:
    loop build_binary_str_loop
    ; Add a newline for clean output
    mov byte [rdi], 10

    ; --- Single Syscall: write(1, buffer, 9) ---
    mov rax, 1           ; sys_write
    mov rdi, 1           ; stdout
    mov rsi, buffer      ; pointer to start of buffer
    mov rdx, 10           ; 8 bits + 1 space + 1 newline
    syscall

    ; Exit
    mov rax, 60
    xor rdi, rdi
    syscall