section .data
    ;db: "define byte" and is used to allocate and initialize a byte of memory with a specific value.
    ; In this case, we are using db to define a string of bytes that represent the message we want to print,
    ; followed by a newline character (0xA in hexadecimal). The string is null-terminated, 
    ; meaning it ends with a 0 byte, which is common for strings in assembly language.
    strg db "dec|hex|char|", 0xA ; message to print with newline
    len equ $ - strg ; calculate length of the message and store it in len
    
section .bss                    ; block started by symbol (bss) - uninitialized data section
    buffer resb 16              ; resb -> lower static memory region compared to the stack, near data  heap? memory for the buffer to hold the ASCII digits, | Ascii Symbol and the newline character.
                                ; We chose 16 bytes to ensure we have enough space for any integer conversion and additional characters.
        
section .text
    global _start

_start:
    ; Write header string to stdout
    mov rax, 1                  ; system call for write
    mov rdi, 1                  ; file descriptor 1 is stdout
    mov rsi, strg               ; address of string to output
    mov rdx, len                ; number of bytes
    syscall

    ; Create a loop to loop integers from 32 to 126 (printable ASCII characters)
    mov r9d, 32                 ; Initialize counter to 32 which is the first printable ASCII character space


ascii_conv_loop:
    mov eax, r9d                ; Move the current integer value from r9d into eax, which is the register used for the conversion process in print_int. This sets up the integer we want to convert to ASCII digits for the print_int function.
    lea rsi, [buffer + 16]      ; lea (load effective address) is used to get the address of the end of the buffer,
                                ; which is where we will start storing the ASCII digits. 
                                ; We start from the end of the buffer (hence the +6) because we will be storing digits in reverse order as we convert them.
    call print_int              ; Call the conversion loop to convert the integer to ASCII
    inc r9d                     ; Increment the counter
    cmp r9d, 127                ; Compare counter with num of integers to print
    jl ascii_conv_loop          ; If counter is less than the number, repeat the loop
    jmp done                    ; jump to done to exit the program after printing all integers


print_int:                      ; prints the integer in r9d as ASCII digits followed by a newline
                                ; how does it work? It takes the integer in r9d, converts it to ASCII digits, and stores those digits in the buffer. Then it appends a newline character after the digits and writes the entire string to stdout using a syscall. The conversion is done by repeatedly dividing the integer by 10 and storing the remainders as ASCII characters until the integer is reduced to zero.  

    ;initialize registers for conversion
    mov ebx, 10                 ; Set divisor to 10 for converting integers to ASCII digits
    mov rsi, rsi                ; what does this do? It is essentially a no-op, it moves the value of rsi into itself.
                                ; This might be done to ensure that rsi is properly set up for the conversion process, as rsi is used as a pointer
                                ; to the buffer where the ASCII digits will be stored. By moving rsi into itself, we are just confirming that 
                                ; rsi is correctly initialized before we start using it in the conversion loop.
    xor r8d, r8d                ; Clear digit count
    loop_each_digit:  
        xor edx, edx            ; Clear EDX (by xoring it with itself) to prepare for division  
        div ebx                 ; div - quotient is eax (based on cpu architecture
                                ; and divisor is ebx)
                                ; remainder goes to edx. 
        add dl, '0'             ; Convert the remainder to ASCII
        dec rsi                 ; dec - decrements the value of rsi, which is a pointer to the current position in the buffer
                                ; where we want to store the next ASCII digit. By decrementing rsi, 
                                ; we move backwards through the buffer as we store each digit, since we are converting the integer 
                                ; from least significant digit to most significant digit. This way, when we finish the conversion, 
                                ; rsi will point to the start of the digits in the buffer.
        mov [rsi], dl           ; Store the ASCII digit in the buffer
        inc r8d                 ; Increment the digit count
        test eax, eax           ; Check if the quotient is zero
        jnz loop_each_digit     ; If EAX is not zero, continue the loop

    ; Append newline after digits so one write syscall prints both
    ; why rsi + r8? Because rsi points to the start of the digits in the buffer,
    ; and r8d contains the count of digits, so rsi + r8 will point to the position right after the last digit 
    ; where we want to add the newline character. 
    mov byte [rsi + r8], "|"        ; separator after decimal digits
    mov cl, r9b                     ; pass the byte value to byte_to_hex
    call byte_to_hex                ; returns: r10b = high nibble char, r11b = low nibble char
    mov byte [rsi + r8 +1], "0"     ; separator after decimal digits
    mov byte [rsi + r8 +2], "x"     ; separator after decimal digits
    mov [rsi + r8 + 3], r10b        ; store hex high nibble
    mov [rsi + r8 + 4], r11b        ; store hex low nibble
    mov byte [rsi + r8 + 5], "|"    ; separator after hex
    mov al, r9b                     ; the ASCII symbol itself
    mov [rsi + r8 + 6], al          ; store symbol
    mov byte [rsi + r8 + 7], "|"    ; separator after hex
    mov byte [rsi + r8 + 8], 0x0A   ; newline

    ; Write the digits and trailing newline to stdout
    mov rax, 1                      ; sys_write
    mov rdi, 1                      ; stdout
    mov rsi, rsi                    ; rsi points to start of digits in buffer
    lea edx, [r8d + 9]              ; dec digits + | + 2 hex chars + | + symbol + newline
    syscall
    ret

; byte_to_hex: converts a byte to two ASCII hex characters
; Input:  cl  = byte value to convert from register r9b (the current integer value we are converting)
; Output: r10b = high nibble ASCII char ('0'-'9' or 'A'-'F')
;         r11b = low nibble ASCII char  ('0'-'9' or 'A'-'F')
byte_to_hex:    ;
    movzx r10d, cl          ; r10b = full byte value
    movzx r11d, cl          ; r11b = full byte value
    shr r10b, 4             ; r10b = high nibble (0-15)
    and r11b, 0x0F          ; r11b = low nibble  (0-15)

    cmp r10b, 10
    jl .high_digit
    add r10b, 'A' - 10      ; map 10-15 -> 'A'-'F'
    jmp .high_done
    .high_digit:
    add r10b, '0'           ; map 0-9 -> '0'-'9'
    .high_done:

    cmp r11b, 10
    jl .low_digit
    add r11b, 'A' - 10
    jmp .low_done
    .low_digit:
    add r11b, '0'
    .low_done:
    ret


done:
    ; Exit program
    mov rax, 60             ; 60 is the syscall number for exit, which is expected in rax in x86-64, so we move 60 into rax to indicate the exit syscall.
    xor edi, edi            ; Set exit status to 0, why edi? Because the exit syscall expects the exit status in rdi, and we want to return 0 to indicate successful execution.
    syscall