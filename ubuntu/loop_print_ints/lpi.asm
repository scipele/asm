section .data

section .bss
    buffer resb 8       ; what is resb? It reserves a block of memory for the buffer to hold the ASCII digits and the newline character.
                        ; We chose 8 bytes because we will print integers from 1 to 80, which can have up to 2 digits, plus a newline.    
                        ; but we only need 3 bytes (2 for digits and 1 for newline), so we have extra space in the buffer, but it doesn't affect our program.
    
section .text
    global _start


_start:
    ; Create a loop to print integers from 1 to ...
    ;why not just move 1 into eax? 
    mov r9d, 1          ; Initialize counter to 1
    ; what regiister can i used to hold the multiplier?
    mov r10d, 2         ; multiplier that will be used to count by 10s 

loop_start:
    ; Convert the current value of ecx to ASCII digits in buffer
    mov eax, r9d
    lea rsi, [buffer + 8]   ; lea (load effective address) is used to get the address of the end of the buffer, which is where we will start storing the ASCII digits. 
                             ; We start from the end of the buffer because we will be storing digits in reverse order as we convert them.
    ; To multiply the counter by x, we can simply use the imul instruction before calling the print_int function. Here's how you can modify the code:
    imul eax, r10d                 ; Multiplier used to count by multiplier
    ; how is the multiplied value in eax passed to the print_int function?
    ; The value in eax is passed to the print_int function because we are using the calling convention where the first argument is passed in rdi,
    ; but since we are using rax for the syscall, we can directly use rax to hold the value we want to print.
    call print_int          ; Call the conversion loop to convert the integer to ASCII
    inc r9d                 ; Increment the counter
    cmp r9d, 111             ; Compare counter with num of integers to print
    jl loop_start           ; If counter is less than the number, repeat the loop
    jmp done                ; jump to done to exit the program after printing all integers


print_int:
    ;initialize registers for conversion
    mov ebx, 10             ; Set divisor to 10 for converting integers to ASCII digits
    mov rsi, rsi            ; rsi already points to the end of the buffer
    xor r8d, r8d            ; Clear digit count

    loop:  
        xor edx, edx        ; Clear EDX (by xoring it with itself) to prepare for division  
        div ebx             ; Divide EAX by 10, quotient in EAX and remainder in EDX
        add dl, '0'         ; Convert the remainder to ASCII
        dec rsi             ; Move back the pointer to store the next digit
        mov [rsi], dl       ; Store the ASCII digit in the buffer
        inc r8d             ; Increment the digit count
        test eax, eax       ; Check if the quotient is zero
        jnz loop            ; If EAX is not zero, continue the loop

    ; Append newline after digits so one write syscall prints both
    ; why rsi + r8? Because rsi points to the start of the digits in the buffer,
    ; and r8d contains the count of digits, so rsi + r8 will point to the position right after the last digit 
    ; where we want to add the newline character. 
    mov byte [rsi + r8], 0x0A ; Add a newline after the number which is 10 in ASCII or 0x0A in hex

    ; Write the digits and trailing newline to stdout
    mov eax, 1
    mov edi, 1
    lea edx, [r8d + 1]
    syscall

    ret

done:
    ; Exit program
    mov rax, 60     ; 60 is the syscall number for exit, which is expected in rax in x86-64, so we move 60 into rax to indicate the exit syscall.
    xor edi, edi    ;  Set exit status to 0, why edi? Because the exit syscall expects the exit status in rdi, and we want to return 0 to indicate successful execution.
    syscall