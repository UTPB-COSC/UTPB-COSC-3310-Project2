section .data
newline db 0xa, 0x00
nl_len equ $ - newline
nums db '123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899'
counter dq 0
prime dq 0
divisor dq 2
isprime db ' is prime.'
notprime db ' is not prime.'

section .text
global _start

_start:
	loop_init:
		mov rax, 0
		mov rbx, counter
		mov rcx, prime
		mov rdx, divisor
	loop_head:
		add rbx, 1
		mov rdx, 2
		push rdx
		push rcx
		push rbx
		cmp rax, 189
		jge loop_exit
	loop_body:
		mov rcx, nums
		cmp rax, 9
		jle over_nine
		add rax, 1
		over_nine:
		add rcx, rax
		mov rdx, 1
		cmp rax, 9
		jl print
		add rdx, 1
		print:
		push rax
		mov rax, 4
		mov rbx, 1
		int 0x80

		primecheck:
		pop rax
		pop rbx
		pop rcx
		pop rdx
		cmp rbx, 2
		jg overtwo
		cmp rbx, 2
		je printisprime
		jmp printnotprime
		
		overtwo:
		cmp rbx, rdx
		jl determine
		push rcx
		push rax 
		push rbx
		pop rax
		push rdx
		pop rbx
		mov rdx, 0
		mov rcx, 0
		add rcx, rax
		add rdx, rbx
		push rcx
		push rdx
		mov rdx, 0
		mov rcx, 0
		div rbx
		cmp rdx, 0
		je increase
		mov rax, 0
		mov rdx, 0
		pop rdx
		add rdx, 1
		pop rbx
		pop rax
		pop rcx
		jmp overtwo

		determine:
		cmp rcx, 1
		jg printnotprime
		
		printisprime:	
		push rdx
		push rcx
		push rbx
		push rax
		mov rax, 4
		mov rbx, 1
		mov rcx, isprime
		mov rdx, 10
		int 0x80
		jmp primeend
		
		printnotprime:
		push rdx
		push rcx
		push rbx
		push rax
		mov rax, 4
		mov rbx, 1
		mov rcx, notprime
		mov rdx, 14
		int 0x80
		jmp primeend
		
		increase:
		mov rax, 0
		mov rdx, 0
		pop rdx
		add rdx, 1
		pop rbx
		pop rax
		pop rcx
		add rcx, 1
		jmp overtwo
		
		primeend:
		mov rax, 4
		mov rbx, 1
		mov rdx, nl_len
		mov rcx, newline
		int 0x80
		pop rax
		pop rbx
		pop rcx
		mov rcx, 0
		pop rdx
		add rax, 1
		jmp loop_head
	loop_exit:
		mov rax,1
		int 0x80
