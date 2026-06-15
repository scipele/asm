; compile with nasm -f elf64 prnt.asm -o prnt.o
; link with gcc: gcc -no-pie prnt.o -o prnt

extern printf                   ; This program calles the C library function printf, so we declare it as an external symbol

; Note: The "wrt ..plt" is used to ensure that the call goes through the Procedure Linkage Table (PLT)
; for dynamic linking, which is necessary when calling external functions like printf in a;
; position-independent executable (PIE).
%macro PRNT_HDR 0               ; 0 indicates the number of parameters passed by %# (excluding named format string)
    mov rdi, formatString1       
    xor rax, rax                 
    call printf wrt ..plt
%endmacro

%macro CALL_PRINTF 2             ; 2 indicates the number of parameters passed by %# (excluding named format string)
    mov rdi, formatString2       
    mov rsi, %1                  ; 2nd: Decimal
    mov rdx, %1                  ; 3rd: Character
    mov rcx, %1                  ; 4th: Hex
    mov r8,  %1                  ; 5th: Octal
    mov r9,  %2                  ; 6th: Binary string pointer
    xor rax, rax                 
    call printf wrt ..plt        
%endmacro

section .data
    formatString1: db "dec | ascii | hex  | octal | binary", 0x0A, 0x00
    formatString2: db "%3d |   %c   | 0x%02x | 0o%03o | %s", 0x0A, 0x00

section .bss
    binBuffer: resb 9

section .text
    global main

main:
    push rbp                    ; Set up the stack frame, rbp is a register that is commonly used to point
                                ; to the base of the current stack frame. By pushing it onto the stack, we 
                                ; save its previous value so that we can restore it later when we exit the function.
                                ; It's a common convention in x86-64 assembly to use the RBP register as a frame pointer.
                                ; By pushing RBP at the beginning of the function, we save the caller's frame pointer.
                                ; Then, by moving RSP into RBP, we establish a new frame for the current function.

    mov rbp, rsp                ; Move the stack pointer into the base pointer to set up the new stack frame

    PRNT_HDR

    mov r12, 32                  ; Start at space character

loop_thru_ints:
    mov rdi, binBuffer          
    mov rsi, r12                
    call int_to_binary_loop

    CALL_PRINTF r12, binBuffer             
    
    inc r12                     
    cmp r12, 127                 
    jl loop_thru_ints           

done:
    xor rax, rax                
    leave
    ret

; =====================================================================
; HELPER: Converts an 8-bit integer into an ASCII binary string (Looped)
; =====================================================================
int_to_binary_loop:
    mov rcx, 8                  ; 8 bits to process
    
.bit_loop:
    shl sil, 1                  ; Left shift automatically brings the (most significant bit (MSB)) into the Carry flag
    jc .set_one                 ; Jumps if the carry flag is set (i.e., if the MSB was 1) otherwise fall thru
    mov byte [rdi], '0'         ; If the MSB was 0, write '0' to the buffer
    jmp .next_bit

.set_one:
    mov byte [rdi], '1'

.next_bit:
    inc rdi
    loop .bit_loop

    mov byte [rdi], 0x00           ; Null terminator
    ret
