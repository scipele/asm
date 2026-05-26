default rel

section .data
    ; db: "define byte" and is used to allocate and initialize a byte of memory with a specific value.
    ; In this case, we are using db to define a string of bytes that represent the message we want to print,
    ; followed by a newline character (0xA in hexadecimal). The string is null-terminated, 
    ; meaning it ends with a 0 byte, which is common for strings in assembly language.
    strg db "dec | hex  |chr| binary    | Octal |", 0xA     ; message to print with newline
    len equ $ - strg                                ; calculate length of the message and store it in len
    ; We define some constants for the formatted output fields
    ; to make it easier to write the formatted string to the buffer later on.
    START_ASCII_NUMBER equ 32
    END_ASCII_NUMBER equ 126
    SPACE_PIPE_SPACE equ 0x00207C20         ; " | "
    SPACE_PIPE_SPACE_ZERO equ 0x30207C20    ; " | 0"
    SPACE_PIPE_NEWLINE equ 0x000A7C20       ; " |\n"

section .bss                     ; block started by symbol (bss) - uninitialized data section
    buffer resb 38               ; resb -> lower static memory region compared to the stack, memory for the buffer to hold the ASCII digits, | Ascii Symbol and the newline character.

section .text
    global _start

_start:
    call print_header
    call print_ascii_table
    jmp exit_program

; Print table header row.
; Clobbers: rax, rdi, rsi, rdx
print_header:
    mov rax, 1
    mov rdi, 1
    mov rsi, strg
    mov rdx, len
    syscall
    ret

; Iterate printable ASCII range and print one formatted row per value.
; Clobbers: r9d and all registers clobbered by print_ascii_row
print_ascii_table:
    mov r9d, START_ASCII_NUMBER

.table_loop:
    call print_ascii_row
    inc r9d
    cmp r9d, END_ASCII_NUMBER + 1
    jl .table_loop
    ret

; Build and write one row for the byte in r9b.
; Input:  r9b = current ASCII value
; Output: none
; Clobbers: rax, rbx, rcx, rdx, rsi, rdi, r8, r10, r11
print_ascii_row:
    mov eax, r9d
    lea rsi, [buffer + 38]

    call build_decimal_field
    call append_hex_and_char_fields
    call append_binary_field
    call append_octal_field
    call append_row_terminator
    call write_row
    ret

; Build decimal field right-to-left at end of buffer.
; Input:  eax = value, rsi = buffer end
; Output: rsi = start of row, rdi = cursor after decimal field
; Clobbers: rbx, rdx, r8d
build_decimal_field:
    mov ebx, 10
    xor r8d, r8d

.digit_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc r8d
    test eax, eax
    jnz .digit_loop

    cmp r9d, 100
    jge .ready
    dec rsi
    mov byte [rsi], ' '
    inc r8d

.ready:
    lea rdi, [rsi + r8]
    ret

; Append " | 0xHH | C | "
; Input:  r9b = value, rdi = write cursor
; Output: rdi = updated write cursor
; Clobbers: rax, rcx, r10, r11
append_hex_and_char_fields:
    mov cl, r9b
    call byte_to_hex

    mov dword [rdi], SPACE_PIPE_SPACE_ZERO
    add rdi, 4
    mov byte [rdi], 'x'
    inc rdi
    mov [rdi], r10b
    mov [rdi + 1], r11b
    add rdi, 2

    mov dword [rdi], SPACE_PIPE_SPACE
    add rdi, 3
    mov al, r9b
    mov [rdi], al
    inc rdi
    mov dword [rdi], SPACE_PIPE_SPACE
    add rdi, 3
    ret

; Append binary field as 8 bits with a space after bit 4,
; then append " | 0o" prefix for octal.
; Input:  r9b = value, rdi = write cursor
; Output: rdi = updated write cursor
; Clobbers: rax, rcx, rdx
append_binary_field:
    mov al, r9b
    mov ecx, 8

.binary_loop:
    shl al, 1
    mov dl, '0'
    adc dl, 0
    mov [rdi], dl
    inc rdi
    cmp rcx, 5
    jne .no_space
    mov byte [rdi], ' '
    inc rdi

.no_space:
    loop .binary_loop

    mov dword [rdi], SPACE_PIPE_SPACE_ZERO
    add rdi, 4
    mov byte [rdi], 'o'
    inc rdi
    ret

; Append 3-digit octal value (000..177).
; Input:  r9b = value, rdi = write cursor
; Output: rdi = updated write cursor
; Clobbers: rax, rbx, rcx, rdx
append_octal_field:
    movzx eax, r9b
    mov ebx, 8
    mov ecx, 3

.octal_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [rdi + rcx - 1], dl
    dec ecx
    jnz .octal_loop

    add rdi, 3
    ret

; Append " |\n" sequence and keep legacy cursor movement.
; Input:  rdi = write cursor
; Output: rdi = cursor positioned as before write_row
; Clobbers: none
append_row_terminator:
    mov dword [rdi], SPACE_PIPE_NEWLINE
    add rdi, 3
    ret

; Write one completed row to stdout.
; Input:  rsi = row start, rdi = cursor from append_row_terminator
; Output: none
; Clobbers: rax, rdi, rdx
write_row:
    lea rdx, [rdi + 1]
    sub rdx, rsi
    mov rax, 1
    mov rdi, 1
    syscall
    ret

; helper function to convert a byte in cl to two ASCII hex characters in r10b and r11b
byte_to_hex:
    movzx r10d, cl      ;r10b = full byte value
    movzx r11d, cl      ;r11b = full byte value
    shr r10b, 4         ;r10b = high nibble (0-15)    
    and r11b, 0x0F      ;r11b = low nibble  (0-15)    
                                               
    cmp r10b, 10                               
    jl .high_digit                             
    add r10b, 'A' - 10  ;map 10-15 -> 'A'-'F'    
    jmp .high_done                          
    .high_digit:                            
    add r10b, '0'       ;map 0-9 -> '0'-'9'    
    .high_done:                             
                                            
    cmp r11b, 10                            
    jl .low_digit                           
add r11b, 'A' - 10      ;map 10-15 -> 'A'-'F'                       
    jmp .low_done                           
    .low_digit:                            
    add r11b, '0'       ;map 0-9 -> '0'-'9'                          
    .low_done:                             
    ret

exit_program:
    mov rax, 60
    xor edi, edi
    syscall