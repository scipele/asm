section .data
    msg1 db 0xA, 0xA, "Examples of bitwise operations:", 0xA, 0xA, 0   ;newline chars

    msg2 db "1. xor operation scrambles the initial byte:", 0xA, "          ", 0
    msg3 db "      xor ", 0
    msg4 db "     ---------------", 0xA, 0

    msg5 db 0xA, "2. and operation with mask to isolate low nibble:", 0xA, "          ", 0
    msg6 db "      and ", 0

    msg7 db 0xA, "3. or operation to set the third bit to 1 while leaving others unchanged:", 0xA, "          ", 0
    msg8 db "      or  ", 0
        
    msg9 db 0xA, "4. Shift right operation to isolate high nibble:", 0xA, "          ", 0
    msg10 db "   shr, 4 ", 0

    str_tab2 db "          ", 0 ; spaces for indentation

    end_spcs db 0xA, 0xA, 0xA, 0xA, 0

section .bss
    buf_input resb 16       ; Reserve 16 bytes for user input
    buffer resb 10          ; Reserve 10 bytes for the string, space, and newline


section .text
    global _start

%macro PRINTZ 1
    mov rsi, %1
    call print_cstr
%endmacro

%macro PRINT_BIN 1
    mov al, %1
    call print_binary_string
%endmacro


_start:
    ; print the initial messages
    PRINTZ msg1
    PRINTZ msg2
    
    ;----------------------------------
    ;--- Step 1 Binary Xor Example: ---
    ;----------------------------------
    PRINT_BIN 237
    PRINTZ msg3
    PRINT_BIN 213
    PRINTZ msg4
    PRINTZ str_tab2
    mov al, 237          ; integer to convert
    xor al, 213           ; Perform XOR operation
    call print_binary_string


    ;-------------------------------------
    ; --- Step 2 Binary And Operation  ---
    ;-------------------------------------
    PRINTZ msg5
    PRINT_BIN 237
    PRINTZ msg6
    PRINT_BIN 15
    PRINTZ msg4
    PRINTZ str_tab2
    mov al, 237          ; integer to convert
    and al, 15           ; Perform XOR operation
    call print_binary_string

    ;-------------------------------------
    ; --- Step 3 Or Operation  ---
    ;-------------------------------------
    PRINTZ msg7
    PRINT_BIN 193
    PRINTZ msg8
    PRINT_BIN 4
    PRINTZ msg4
    PRINTZ str_tab2
    mov al, 193          ; integer to convert
    or al, 4           ; Perform OR operation
    call print_binary_string


    ;-------------------------------------
    ; --- Step 4 Shift Right Operation  ---
    ;-------------------------------------
    PRINTZ msg9
    PRINT_BIN 0xF0
    PRINTZ msg10
    mov al, 0xF0          ; integer to convert
    shr al, 4            ; Perform shift right operation
    call print_binary_string


    ;---------------------------------
    ; --- Step 5 Cleanup and Exit  ---
    ;---------------------------------
    PRINTZ end_spcs
    call exit

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

print_cstr:
    xor rdx, rdx
.find_null:
    cmp byte [rsi + rdx], 0
    je .len_ready
    inc rdx
    jmp .find_null
.len_ready:
    call print_buffer
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
