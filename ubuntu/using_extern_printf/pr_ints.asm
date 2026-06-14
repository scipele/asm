; compile with nasm -f elf64 prnt.asm -o prnt.o
; link with gcc: gcc -no-pie prnt.o -o prnt

extern printf

%macro CALL_HEADER 0
    mov rdi, formatString1       
    xor rax, rax                 
    call printf wrt ..plt
%endmacro

%macro CALL_PRINTF 2
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
    push rbp
    mov rbp, rsp

    CALL_HEADER

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
    shl sil, 1                  ; Shift MSB into Carry Flag
    jc .set_one
    
    mov byte [rdi], '0'
    jmp .next_bit

.set_one:
    mov byte [rdi], '1'

.next_bit:
    inc rdi
    loop .bit_loop

    mov byte [rdi], 0           ; Null terminator
    ret
