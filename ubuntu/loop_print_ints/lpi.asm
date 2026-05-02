section .bss                ; block started by symbol (bss) - uninitialized data section
    buffer resb 6           ; resb -> lower static memory region compared to the stack, near data  heap? memory for the buffer to hold the ASCII digits and the newline character.
                            ; We chose 6 bytes because we will print integers from 0 to 99999, which can have up to 5 digits, plus a newline.    
        
section .text
    global _start

_start:
    ; Create a loop to print integers from 100 to ...
    mov r9d, 100            ; Initialize counter to 100


ascii_conv_loop:
    ; Convert the current value of ecx to ASCII digits in buffer
    mov eax, r9d
    lea rsi, [buffer + 6]   ; lea (load effective address) is used to get the address of the end of the buffer,
                            ; which is where we will start storing the ASCII digits. 
                            ; We start from the end of the buffer (hence the +6) because we will be storing digits in reverse order as we convert them.
    call print_int          ; Call the conversion loop to convert the integer to ASCII
    inc r9d                 ; Increment the counter
    cmp r9d, 111            ; Compare counter with num of integers to print
    jl ascii_conv_loop      ; If counter is less than the number, repeat the loop
    jmp done                ; jump to done to exit the program after printing all integers


print_int:                  ; prints the integer in r9d as ASCII digits followed by a newline
                            ; how does it work? It takes the integer in r9d, converts it to ASCII digits, and stores those digits in the buffer. Then it appends a newline character after the digits and writes the entire string to stdout using a syscall. The conversion is done by repeatedly dividing the integer by 10 and storing the remainders as ASCII characters until the integer is reduced to zero.  

    ;initialize registers for conversion
    mov ebx, 10             ; Set divisor to 10 for converting integers to ASCII digits
    mov rsi, rsi            ; what does this do? It is essentially a no-op, it moves the value of rsi into itself.
                            ; This might be done to ensure that rsi is properly set up for the conversion process, as rsi is used as a pointer
                            ; to the buffer where the ASCII digits will be stored. By moving rsi into itself, we are just confirming that 
                            ; rsi is correctly initialized before we start using it in the conversion loop.
    xor r8d, r8d            ; Clear digit count
    loop_each_digit:  
        xor edx, edx        ; Clear EDX (by xoring it with itself) to prepare for division  
        div ebx             ; div - quotient is eax (based on cpu architecture
                            ; and divisor is ebx)
                            ; remainder goes to edx. 
        
        add dl, '0'         ; Convert the remainder to ASCII
        dec rsi             ; dec - decrements the value of rsi, which is a pointer to the current position in the buffer
                            ; where we want to store the next ASCII digit. By decrementing rsi, 
                            ; we move backwards through the buffer as we store each digit, since we are converting the integer 
                            ; from least significant digit to most significant digit. This way, when we finish the conversion, 
                            ; rsi will point to the start of the digits in the buffer.
        mov [rsi], dl       ; Store the ASCII digit in the buffer
        inc r8d             ; Increment the digit count
        test eax, eax       ; Check if the quotient is zero
        jnz loop_each_digit ; If EAX is not zero, continue the loop

    ; Append newline after digits so one write syscall prints both
    ; why rsi + r8? Because rsi points to the start of the digits in the buffer,
    ; and r8d contains the count of digits, so rsi + r8 will point to the position right after the last digit 
    ; where we want to add the newline character. 
    mov byte [rsi + r8], 0x0A ; Add a newline after the number which is 10 in ASCII or 0x0A in hex

    ; Write the digits and trailing newline to stdout
    mov rax, 1              ; Argument_a:  1 = sys_write
    mov rdi, 1              ; Argument_b:  1 = file descriptor 1 = (stdout) terminal output
    mov rsi, rsi            ; Argument_c:  confirming rsi is correct for the syscall, it should point to the start of the digits in the buffer, which it does because we set it up that way during the conversion loop.
    lea edx, [r8d + 1]      ; edx is loaded with the total number of bytes to write, which is the count of digits (r8d) plus one for the newline character.
    syscall                 ; syscall uses arguments above, which are set up according to the syscall convention for x86-64 Linux. 
    ret                     ; Return from the print_int function to the caller, which is the main loop that calls print_int for each integer.    

done:
    ; Exit program
    mov rax, 60     ; 60 is the syscall number for exit, which is expected in rax in x86-64, so we move 60 into rax to indicate the exit syscall.
    xor edi, edi    ;  Set exit status to 0, why edi? Because the exit syscall expects the exit status in rdi, and we want to return 0 to indicate successful execution.
    syscall