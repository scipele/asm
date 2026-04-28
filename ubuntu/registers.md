### x64 Registers in Linux (System V AMD64 ABI)

| Register | 32-bit | 16-bit | 8-bit  | Type              | Usage in Linux |
|----------|--------|--------|--------|-------------------|---------------|
| **%rax** | %eax   | %ax    | %al    | Caller-saved      | **Return value**, Syscall number |
| **%rbx** | %ebx   | %bx    | %bl    | Callee-saved      | Preserved across calls |
| **%rcx** | %ecx   | %cx    | %cl    | Caller-saved      | 4th argument |
| **%rdx** | %edx   | %dx    | %dl    | Caller-saved      | 3rd argument |
| **%rsi** | %esi   | %si    | %sil   | Caller-saved      | 2nd argument |
| **%rdi** | %edi   | %di    | %dil   | Caller-saved      | **1st argument** |
| **%rbp** | %ebp   | %bp    | %bpl   | Callee-saved      | Frame pointer (optional) |
| **%rsp** | %esp   | %sp    | %spl   | Callee-saved      | **Stack Pointer** |
| **%r8**  | %r8d   | %r8w   | %r8b   | Caller-saved      | 5th argument |
| **%r9**  | %r9d   | %r9w   | %r9b   | Caller-saved      | 6th argument |
| **%r10** | %r10d  | %r10w  | %r10b  | Caller-saved      | Temporary / Syscall 4th arg |
| **%r11** | %r11d  | %r11w  | %r11b  | Caller-saved      | Temporary |
| **%r12** | %r12d  | %r12w  | %r12b  | Callee-saved      | Preserved |
| **%r13** | %r13d  | %r13w  | %r13b  | Callee-saved      | Preserved |
| **%r14** | %r14d  | %r14w  | %r14b  | Callee-saved      | Preserved |
| **%r15** | %r15d  | %r15w  | %r15b  | Callee-saved      | Preserved |

**Notes:**
- **Caller-saved**: Function can freely modify these. Caller must save if needed.
- **Callee-saved**: Function must preserve these values (`%rbx`, `%rbp`, `%r12`-`%r15`).
- First 6 integer/pointer arguments are passed in: `%rdi`, `%rsi`, `%rdx`, `%rcx`, `%r8`, `%r9`.
- System calls use `%rax` for syscall number and `%r10` as 4th argument (instead of `%rcx`).