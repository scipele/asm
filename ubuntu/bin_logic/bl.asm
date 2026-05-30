section .data
    msg1 db 0xA, 0xA, "Examples of bitwise operations:", 0xA, 0xA   ;newline chars
    len1 equ $ - msg1

    msg2 db "1. xor operation scramles the initial byte:", 0xA, "          "
    len2 equ $ - msg2
    msg3 db "      xor "
    len3 equ $ - msg3
    msg4 db "     ---------------", 0xA
    len4 equ $ - msg4

    msg5 db 0xA, "2. and operation with mask to isolate low nibble:", 0xA, "          "
    len5 equ $ - msg5
    msg6 db "      and "
    len6 equ $ - msg6

    msg7 db 0xA, "3. or operation to set the third bit to 1 while leaving others unchanged:", 0xA, "          "
    len7 equ $ - msg7
    msg8 db "      or  "
    len8 equ $ - msg8
        
    msg9 db 0xA, "4. Shift right operation to isolate high nibble:", 0xA, "          "
    len9 equ $ - msg9
    msg10 db "   shr, 4 "
    len10 equ $ - msg10

    str_tab2 db "          " ; spaces for indentation
    len_tb2 equ $ - str_tab2

    end_spcs db 0xA, 0xA, 0xA, 0xA

section .bss
    buf_input resb 16       ; Reserve 16 bytes for user input
    buffer resb 10          ; Reserve 10 bytes for the string, space, and newline


section .text
    global _start


_start:
    ; print the initial messages
    call print_msg1_2
    
    ;----------------------------------
    ;--- Step 1 Binary Xor Example: ---
    ;----------------------------------
    mov al, 237          ; integer to convert
    call print_binary_string

    call print_msg3
    mov al, 213          ; integer to convert
    call print_binary_string
    call print_msg4

    call print_tab2
    mov al, 237          ; integer to convert
    xor al, 213           ; Perform XOR operation
    call print_binary_string


    ;-------------------------------------
    ; --- Step 2 Binary And Operation  ---
    ;-------------------------------------
    call print_msg5
    mov al, 237          ; integer to convert
    call print_binary_string

    call print_msg6
    mov al, 15          ; integer to convert
    call print_binary_string
    call print_msg4

    call print_tab2
    mov al, 237          ; integer to convert
    and al, 15           ; Perform XOR operation
    call print_binary_string

    ;-------------------------------------
    ; --- Step 3 Or Operation  ---
    ;-------------------------------------
    call print_msg7
    mov al, 193          ; integer to convert
    call print_binary_string

    call print_msg8
    mov al, 4          ; integer to convert
    call print_binary_string
    call print_msg4

    call print_tab2
    mov al, 193          ; integer to convert
    or al, 4           ; Perform OR operation
    call print_binary_string


    ;-------------------------------------
    ; --- Step 4 Shift Right Operation  ---
    ;-------------------------------------
    call print_msg9
    mov al, 0xF0          ; integer to convert
    call print_binary_string

    call print_msg10
    mov al, 0xF0          ; integer to convert
    shr al, 4            ; Perform shift right operation
    call print_binary_string


    ;---------------------------------
    ; --- Step 5 Cleanup and Exit  ---
    ;---------------------------------
    call print_end_spcs
    call exit

print_msg1_2:
    mov rsi, msg1
    mov rdx, len1
    call print_buffer

    mov rsi, msg2
    mov rdx, len2
    call print_buffer
    ret

print_msg3:
    mov rsi, msg3
    mov rdx, len3
    call print_buffer
    ret

print_msg4:
    mov rsi, msg4
    mov rdx, len4
    call print_buffer
    ret

print_msg5:
    mov rsi, msg5
    mov rdx, len5
    call print_buffer
    ret

print_msg6:
    mov rsi, msg6
    mov rdx, len6
    call print_buffer
    ret

print_msg7:
    mov rsi, msg7
    mov rdx, len7
    call print_buffer
    ret

print_msg8:
    mov rsi, msg8
    mov rdx, len8
    call print_buffer
    ret

print_msg9:
    mov rsi, msg9
    mov rdx, len9
    call print_buffer
    ret

print_msg10:
    mov rsi, msg10
    mov rdx, len10
    call print_buffer
    ret

print_end_spcs:
    mov rsi, end_spcs
    mov rdx, 4
    call print_buffer
    ret

print_tab2:
    mov rsi, str_tab2
    mov rdx, len_tb2
    call print_buffer
    ret

print_binary_string:
    ;print the binary string
    call print_bin_str
    mov rsi, buffer
    mov rdx, 10;        Binary String Length = 8 bits + 1 space + 1 newline
    call print_buffer
    ret

print_buffer:
    ; write(1, rsi, rdx)
    mov rax, 1           ; sys_write
    mov rdi, 1           ; stdout
    syscall    
    ret

print_bin_str:   
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


exit:
    mov rax, 60
    xor rdi, rdi
    syscall
