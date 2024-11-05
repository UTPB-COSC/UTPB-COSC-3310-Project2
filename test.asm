section .data
	msg_prime db " is prime.", 0 ; Message from prime numbers
	msg_not_prime db " is not prime.", 0 ; For non-prime numbers
	
section .bss
	length resb 1
	
section .text
global main ; Our entry point

main:
	; RAX = A, RDI = B, RSI = C, RDX = D
	; Prepare for sys_write
	MOV RSI, msg_not_prime
	call print
	MOV RSI, msg_not_prime
	call print
	
	jmp exit
	
get_length:
	MOV RAX, 0
	.loop:
		MOV RDI, [RSI]
	
print:
	; Prepare for sys_write
	MOV RAX, 1
	MOV RDI, 1
	MOV byte [length], 10
	MOV RDX, [length]
	syscall

	
exit:
	MOV RAX, 60
	XOR RDI, RDI
	syscall