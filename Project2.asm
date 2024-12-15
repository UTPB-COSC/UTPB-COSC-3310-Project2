section .data
    prime_msg db " is prime.", 0x0a, 0x00
	prime_len equ $ - prime_msg
	not_prime_msg db " is not prime." 0x0a, 0x00
	not_prime_len equ $ - not_prime_msg
	nums db '123456789'
    count dq 1
	final_num dq 99
	num_1 dq 0
	num_2 dq 0
	
section .text
global _start

_start:
			
	loop:
		push QWORD [count]
		call print_num
		push QWORD [count]
		call test_prime
		add QWORD [count], 1
		mov rax, QWORD [final_num]
		cmp QWORD [count], rax
		jge loop_exit
		jmp loop
	
	loop_exit:
		mov rax, 1
		int 0x80
		ret
		
	print_num:
		pop rax
		pop QWORD [num_1]
		push rax
		cmp QWORD [num_1], 10
		jge num_decomp
		push QWORD [num_1]
		call print_digit
		ret
		
	print_digit:
		pop rax
		pop QWORD [num_1]
		push rax
		mov rdx, 1
		add rcx, QWORD [num_1]
		mov rbx, 1
		mov rax, 4
		int 0x80
		ret
		rev_print:
			cmp QWORD [num_2], 0
			je rev_exit
			call print_digit
			sub QWORD [num_2], 1
			jmp rev_print
		rev_exit:
			ret
			
	num_decomp:
		mov QWORD [num_2], 0
		decomp_head:
			cmp QWORD [num_1], 0
			je rev_print
		decomp_loop:
			mov rdx, 0
			mov rcx, 0
			mov rbx, 10
			mov rax, QWORD [num_1]
			div rbx
			push rdx
			mov QWORD [num_1], rax
			add QWORD [num_2], 1
			jmp decomp_head
			
	is_prime:
		mov rdx, QWORD [prime_len]
		mov rcx, QWORD [prime_msg]
		mov rbx, 1
		mov rax, 4
		int 0x80
		jmp loop_head
		
	not_prime:
		mov rdx, QWORD [not_prime_len]
		mov rcx, QWORD [not_prime_msg]
		mov rbx, 1
		mov rax, 4
		int 0x80
		jmp loop_head
		
	test_prime
		pop rax
		pop QWORD [num_1]
		push rax
		mov QWORD [num_2], 2
		test_prime_div:
			mov rax, QWORD [num_2]
			cmp QWORD [num_1], rax
			je div_end:
			jmp div_head:
		div_head:
			mov rax, QWORD [final_num]
			cmp QWORD [num_2], rax
			je div_end
			jmp div_loop
		div_loop:
			mov rdx, 0
			mov rcx, 0
			mov rbx, QWORD [num_2]
			mov rax, QWORD [num_1]
			div rbx
			add QWORD [num_2], 1
			cmp rdx, 0
			je not_prime
			jmp test_prime_div
		div_end:
			jmp is_prime
		ret
		
			
		