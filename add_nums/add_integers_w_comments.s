	.file	"add_integers.c"					; Specifies the original source file name
	.text										; Indicates the beginning of the code section
	.def	printf								;.scl	3;	.type	32;	.endef, Defines the symbol for printf function
	.seh_proc	printf							; Starts the structured exception handling (SEH) for printf
printf:
	pushq	%rbp								; Save the base pointer
	.seh_pushreg	%rbp
	pushq	%rbx								; Save the rbx register
	.seh_pushreg	%rbx
	subq	$56, %rsp							; Allocate 56 bytes of stack space
	.seh_stackalloc	56
	leaq	48(%rsp), %rbp						; Set the base pointer for the stack frame
	.seh_setframe	%rbp, 48
	.seh_endprologue
	movq	%rcx, 32(%rbp)						; Save the first four arguments passed to the function
	movq	%rdx, 40(%rbp)
	movq	%r8, 48(%rbp)
	movq	%r9, 56(%rbp)
	leaq	40(%rbp), %rax						; Load the address of the argument list
	movq	%rax, -16(%rbp)						; Save the address
	movq	-16(%rbp), %rbx						; Move it to rbx
	movl	$1, %ecx							; Load 1 into ecx
	movq	__imp___acrt_iob_func(%rip), %rax	; Load the address of __acrt_iob_func.
	call	*%rax								; Call the function to get the file handle
	movq	%rbx, %r8							; Move the argument list address to r8
	movq	32(%rbp), %rdx						; Move the format string to rdx
	movq	%rax, %rcx							; Move the file handle to rcx
	call	__mingw_vfprintf					; Call the vfprintf function.
	movl	%eax, -4(%rbp)						; Save the return value of vfprintf
	movl	-4(%rbp), %eax						; Deallocate the stack space
	addq	$56, %rsp							; Restore the rbx register
	popq	%rbx								; Restore the base pointer
	popq	%rbp								
	ret											; Return from the function
	.seh_endproc
	.def	__main								;	.scl	2;	.type	32;	.endef
	.section .rdata,"dr"
.LC0:											; Defines the string "a + b = ".
	.ascii "a + b = \0"
.LC1:											; Defines the format string "%d"
	.ascii "%d\0"
	.text
	.globl	main								; Make the main function global.
	.def	main								; .scl	2;	.type	32;	.endef
	.seh_proc	main							; Start SEH for main
main:
	pushq	%rbp								; Save the base pointer
	.seh_pushreg	%rbp
	movq	%rsp, %rbp							; Set the base pointer
	.seh_setframe	%rbp, 0
	subq	$48, %rsp							; Allocate 48 bytes of stack space
	.seh_stackalloc	48
	.seh_endprologue
	call	__main								; Call the initialization function.
	movl	$69, -4(%rbp)						; Store 69 in the first local variable (a)
	movl	$31, -8(%rbp)						; Store 31 in the second local variable (b)
	movl	-4(%rbp), %edx						; Move the value of a into edx
	movl	-8(%rbp), %eax						; Move the value of b into eax
	addl	%edx, %eax							; Add a and b
	movl	%eax, -12(%rbp)						; Store the result in the third local variable (sum).
	leaq	.LC0(%rip), %rax					; Load the address of the format string "a + b = ".
	movq	%rax, %rcx							; Move it to rcx (first argument to printf)
	call	printf								; Call printf
	movl	-12(%rbp), %eax						; Move the sum to register 'eax'
	movl	%eax, %edx							; Load the address of the format string "%d"
	leaq	.LC1(%rip), %rax					
	movq	%rax, %rcx							; Move it to rcx (first argument to printf)
	call	printf								; Call printf to print the sum
	movl	$0, %eax							; Return 0
	addq	$48, %rsp							; Deallocate the stack space
	popq	%rbp								; Restore the base pointer
	ret											; Return from the function
	.seh_endproc
	.ident	"GCC: (GNU) 11.2.0"
	.def	__mingw_vfprintf;	.scl	2;	.type	32;	.endef
