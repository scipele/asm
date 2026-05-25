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
    SPACE_PIPE_SPACE equ 0x00207C20                 ; " | "
    SPACE_PIPE_SPACE_ZERO equ 0x30207C20            ; " | 0"
    SPACE_PIPE_NEWLINE equ 0x000A7C20               ; " |\n"

section .bss                     ; block started by symbol (bss) - uninitialized data section
    buffer resb 38               ; resb -> lower static memory region compared to the stack, memory for the buffer to hold the ASCII digits, | Ascii Symbol and the newline character.

section .text
    global _start

_start:
; --- STEP 1 --- Write header string to stdout
    mov rax, 1                    ; system call for write
    mov rdi, 1                    ; file descriptor 1 is stdout
    mov rsi, strg                 ; address of string to output
    mov rdx, len                  ; number of bytes
    syscall

; --- STEP 2 --- Create a loop OF integers from 32 to 126 (printable ASCII characters)
    mov r9d, START_ASCII_NUMBER   ; Initialize counter to 32 which is the first printable ASCII character space

; --- STEP 3 --- setup registers and buffer for conversion and printing
ascii_conv_loop:                  ;
    mov eax, r9d                  ; Move the current integer value from r9d into eax, which is the register used for the conversion
                                  ; process in print_int. This sets up the integer we want to convert to ASCII digits for the print_int function.
    lea rsi, [buffer + 38]        ; lea (load effective address) is used to get the address of the end of the buffer,
                                  ; which is where we will start storing the ASCII digits. 
                                  ; We start from the end of the buffer (hence the +38) because we will be storing digits in reverse order as we convert them.
; --- STEP 4 --- Call the conversion and printing routine                                 
    call build_buffer_and_print   ; Call the conversion loop to convert the integer to ASCII
    inc r9d                       ; Increment the counter
    cmp r9d, END_ASCII_NUMBER + 1 ; Compare counter with num of integers to print
    jl ascii_conv_loop            ; If counter is less than the number, repeat the loop
    jmp done                      ; jump to done to exit the program after printing all integers
                                  
; --- STEP 5 --- Build buffer and print integer_
build_buffer_and_print:           ; prints the integer in r9d as ASCII digits followed by a newline
; Registers in this routine:
;   rsi = start of current output row
;   rdi = write cursor,
;   r8d = decimal field width

; --- STEP 6 --- Build decimal field (right-to-left), then pad values < 100 with one leading space
    mov ebx, 10
    xor r8d, r8d

loop_each_digit:
        xor edx, edx
        div ebx
        add dl, '0'
        dec rsi
        mov [rsi], dl
        inc r8d
        test eax, eax
        jnz loop_each_digit

    cmp r9d, 100
    jge .dec_field_ready
    dec rsi
    mov byte [rsi], ' '
    inc r8d
.dec_field_ready:
; rsi + r8 points just past the decimal field.

; --- STEP 7 --- Convert current byte to two hex chars
    mov cl, r9b
    call byte_to_hex

; --- STEP 8 --- Append hex field and character field
    lea rdi, [rsi + r8]
    mov dword [rdi], SPACE_PIPE_SPACE_ZERO   ; " | 0"
    add rdi, 4
    mov byte [rdi], 'x'
    inc rdi
    mov [rdi], r10b ; high hex char
    mov [rdi + 1], r11b ; low hex char
    add rdi, 2
    mov dword [rdi], SPACE_PIPE_SPACE   ; " | "
    add rdi, 3
    mov al, r9b
    mov [rdi], al
    inc rdi
    mov dword [rdi], SPACE_PIPE_SPACE   ; " | "
    add rdi, 3

; --- STEP 9 --- Append binary field (8 bits with a space after bit 4)
    mov ecx, 8

build_binary_str_loop:
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
    loop build_binary_str_loop
    
    ; finish binary, now add spacer
    
    mov dword [rdi], SPACE_PIPE_SPACE_ZERO   ; " | "
    add rdi, 4
    mov byte [rdi], 'o' ; start of octal field
    inc rdi


; --- STEP 10 --- now move forward since we will build the octal string in reverse order
    movzx eax, r9b      ; current value to convert to octal
    mov ebx, 8
    mov ecx, 3          ; fixed 3-digit octal field (000..177)

build_octal_str_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    mov [rdi + rcx - 1], dl
    dec ecx
    jnz build_octal_str_loop

octal_loop_end:
    add rdi, 3
   
    mov dword [rdi], SPACE_PIPE_NEWLINE   ; " |\n"
    add rdi, 3

; --- STEP 11 --- Write the formatted string to stdout with a single syscall
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


done:
    ; Exit program
    mov rax, 60             ; 60 is the syscall number for exit, which is expected in rax in x86-64, so we move 60 into rax to indicate the exit syscall.
    xor edi, edi            ; Set exit status to 0, why edi? Because the exit syscall expects the exit status in rdi, and we want to return 0 to indicate successful execution.
    syscall