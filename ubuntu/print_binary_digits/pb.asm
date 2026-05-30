section .data
    msg db "Enter an integer number (0-255): "
    msg_len equ $ - msg
    msg_invalid db "Invalid input (must be 0-255)", 10
    msg_invalid_len equ $ - msg_invalid


section .bss
    buf_input resb 16       ; Reserve 16 bytes for user input
    buffer resb 10          ; Reserve 10 bytes for the string, space, and newline


section .text
    global _start


_start:
    call print_prompt
    call read_input
    call conv_ascii_to_int
    jc invalid_input
    call conv_int_to_binary_str
    call print_binary_string    
    call exit

invalid_input:
    call print_invalid
    call exit_error


print_prompt:
    ; --- STEP 1: Print Prompt ---
    mov rax, 1           ; sys_write
    mov rdi, 1           ; stdout
    mov rsi, msg         ; pointer to message
    mov rdx, msg_len     ; message length
    syscall    
    ret


print_invalid:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_invalid
    mov rdx, msg_invalid_len
    syscall
    ret


read_input:
    mov rax, 0              ; sys_read
    mov rdi, 0              ; stdin
    mov rsi, buf_input      ; memory address
    mov rdx, 16             ; max bytes
    syscall                 ; rax now holds number of bytes rea
    ret


conv_ascii_to_int:
    mov rsi, buf_input      ; rsi points to start of input
    xor rax, rax            ; rax = 0 (accumulator)
    xor rcx, rcx            ; digit count
    convert_bin_loop:
        movzx rdx, byte [rsi]  ; load next character
        cmp rdx, 10            ; newline ends input
        je convert_done
        cmp rdx, 13            ; CR also ends input
        je convert_done
        cmp rdx, 0             ; NUL also ends input
        je convert_done
        cmp rdx, '0'
        jl convert_invalid
        cmp rdx, '9'
        jg convert_invalid
        sub rdx, '0'           ; ASCII digit -> numeric value
        imul rax, 10           ; result *= 10
        add rax, rdx           ; result += digit
        cmp rax, 255
        ja convert_invalid
        inc rcx
        inc rsi
        jmp convert_bin_loop
    convert_done:
    cmp rcx, 0             ; empty input is invalid
    je convert_invalid
    clc                    ; valid parse
    ret

convert_invalid:
    stc                    ; invalid parse
    ret


conv_int_to_binary_str:   
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
ret


print_binary_string:
    ; --- Single Syscall: write(1, buffer, 9) ---
    mov rax, 1           ; sys_write
    mov rdi, 1           ; stdout
    mov rsi, buffer      ; pointer to start of buffer
    mov rdx, 10           ; 8 bits + 1 space + 1 newline
    syscall
ret


exit:
    mov rax, 60
    xor rdi, rdi
    syscall


exit_error:
    mov rax, 60
    mov rdi, 1
    syscall
