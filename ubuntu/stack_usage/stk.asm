section .bss
    ; Expanded to 32 bytes to comfortably prevent buffer underflows 
    buffer resb 32          

section .data
    hdr1 db 0xA, 0xA, "Fibonacci Sequence (up to 100000)", 0xA, 0xA, 0 
    hdr2 db "Index: Fib No", 0xA, 0 

section .text
    global _start

; Clean inline printing macro matching standard calling conventions
%macro PRINTZ 1
    mov rsi, %1
    call print_cstr
%endmacro

_start:
    PRINTZ hdr1             ; Print headers
    PRINTZ hdr2 

    ; Pre-allocate 256 bytes on the stack for our array scratchpad
    sub rsp, 256              
    mov rdi, rsp            ; rdi = Array pointer

    call gen_fib            ; Step 1: Generate values. Returns total count in rax.
    
    mov r11, rax            ; r11 = Total number of elements generated
    mov r10, 0              ; r10 = Current loop index (Starts at 0)
    mov rsi, rsp            ; rsi = Base address of our stack array
    call print_loop         ; Step 2: Loop and print index + Fibonacci results
    
    add rsp, 256            ; Clean up the stack allocation cleanly
    call done               ; Step 3: Exit cleanly

; Subroutine to print a null-terminated string safely
print_cstr:
    xor rdx, rdx
.find_null:
    cmp byte [rsi + rdx], 0
    je .len_ready
    inc rdx
    jmp .find_null
.len_ready:
    ; Fixed: Replaced missing print_buffer function with direct sys_write
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    syscall
    ret

gen_fib:
    mov r8, 0               ; F_0 = 0
    mov r9, 1               ; F_1 = 1
    
    mov [rdi + 0], r8       ; Store first number at index 0
    mov [rdi + 8], r9       ; Store second number at index 1
    mov rcx, 2              ; Element count = 2

fib_loop:
    mov r10, r8
    add r10, r9             ; r10 = next Fibonacci number
    
    cmp r10, 2000000          ; Stop loop condition boundary
    jge fib_done            
    
    mov [rdi + rcx*8], r10  ; Store directly into our array
    inc rcx                 ; Increment our element counter
    
    mov r8, r9              ; Move sliding window forward
    mov r9, r10
    jmp fib_loop

fib_done:
    mov rax, rcx            ; Return total count in rax
    ret

print_loop:
    cmp r10, r11            ; Have we printed all elements?
    jge print_done          
    
    mov rax, [rsi + r10*8]  ; rax = The Fibonacci number to print
    mov rbx, r10            ; rbx = The current loop index to print
    
    push r10                ; Protect loop registers from sys_write changes
    push r11
    push rsi
    call print_combined     ; Call formatting layout function
    pop rsi                 ; Restore loop registers
    pop r11
    pop r10
    
    inc r10                 ; Increment the loop index
    jmp print_loop

print_done:
    ret

print_combined:
    ; Inputs: rax = Fibonacci number, rbx = Loop index
    
    ; Setup our starting pointer at the absolute end of our 32-byte buffer
    lea rsi, [buffer + 31]  
    mov byte [rsi], 0x0A    ; Place trailing newline character (\n)
    mov r12, 1              ; r12 tracks total string size (starts at 1 for \n)

    ; --- 1. Convert Fibonacci Number ---
    dec rsi                 
    call convert_to_ascii   ; Returns: rsi = updated pointer, rax = digit count
    add r12, rax            ; Add Fibonacci digit count to total size

    ; --- 2. Insert Separator ---
    ; Fixed: Adjusted to output " . " cleanly using 4-byte layout alignment.
    ; Little-endian swap means '   .' prints forward as '.   '
    sub rsi, 4              
    mov dword [rsi], '.   ' 
    add r12, 4              

    ; --- 3. Convert Loop Index ---
    dec rsi                 
    mov rax, rbx            ; Move index into rax for conversion
    call convert_to_ascii   ; Returns: rsi = updated pointer, rax = digit count
    add r12, rax            ; Add Index digit count to total size

    ; --- 4. Padding Adjustment ---
    cmp rbx, 9
    jg .no_pad
    dec rsi                 ; Move back 1 extra byte for single digit alignments
    mov byte [rsi], ' '     
    inc r12                 
.no_pad:

    ; --- 5. Call Linux sys_write ---
    mov rax, 1              ; sys_write
    mov rdi, 1              ; stdout
    mov rdx, r12            ; Total exact string length
    syscall
    ret

; =========================================================================
; REUSABLE UTILITY FUNCTION: convert_to_ascii
; =========================================================================
convert_to_ascii:
    push rbx                
    mov ecx, 10             ; Base-10 divisor
    xor rbx, rbx            ; Clear local digit counter
.loop:
    xor edx, edx            
    div rcx                 ; rax / 10. Quotient -> rax, Remainder -> rdx
    add dl, '0'             ; Convert remainder integer to ASCII character
    
    mov [rsi], dl           ; Store character at the current rsi pointer position
    inc rbx                 ; Increment local digit counter
    
    test rax, rax           ; Is the quotient zero?
    jz .done                
    
    dec rsi                 ; Move rsi backward 1 byte for next digit
    jmp .loop
.done:
    mov rax, rbx            ; Return the digit count in rax
    pop rbx                 
    ret

done:
    mov rax, 60             ; sys_exit
    xor rdi, rdi            ; Exit status code 0
    syscall