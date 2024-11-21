; Making use of Prof.'s code for printing values 1-99 in order
section .data
newline db 0x0a, 0x00
nl_len equ $ - newline
nums db '123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899'
prime db " is prime", 0xA
prime_len equ $ - prime

no_prime db " is not prime", 0xA
no_prime_len equ $ - no_prime

iterator dq 0 ; replaces r10

prime_tracker dq 0 ; replaces r11

section .text
global _start
_start:
; couldn't get anything to work, and tried switching to only x86-64 syntax
	loop_init:
		mov rax, [iterator]
	loop_head:
		mov rax, [iterator]
		cmp rax, 189
		jge loop_exit
	loop_body:
		mov rcx, nums 
		add rcx, rax ; rcx is updated to point to correct index

		mov rdx, 1
		cmp rax, 9 ; rax is iterator, if less than 9, jusmp to print 
		jl print
		add rdx, 1 ; if not, add 1 more to rdx

		print: ; using updated 64 bit standards
		; updating iterator
		
		add rax, rdx ; update iterator
		mov [iterator], rax

		push rdi
		push rsi
		mov rax, 1 ; 64 bit call
		mov rdi, 1 ; 64 bit call
		mov rsi, rcx ; pointer to nums
		syscall

		pop rsi
		pop rdi



		; increment prime_tracker
		mov rcx, [prime_tracker]
		add rcx, 1
		mov [prime_tracker], rcx

		call is_prime

		cmp rax, 0 ; rax -> return value -> print no prime
		je print_no_prime
		cmp rax, 1 ; rax -> return value -> print prime
		je print_prime;

		print_prime: ; using updated 64 bit standards
		push rdi
		push rsi
		mov rdx, prime_len
		mov rsi, prime
		mov rdi, 1
		mov rax, 1
		syscall

		pop rsi
		pop rdi
		
		jmp print_newline ; skip not prime

		print_no_prime: ; using updated 64 bit standards
		push rdi
		push rsi
		mov rdx, no_prime_len
		mov rsi, no_prime
		mov rdi, 1
		mov rax, 1
		syscall

		pop rsi
		pop rdi

		print_newline: ; using updated 64 bit standards
		push rdi
		push rsi
		mov rdx, nl_len
		mov rsi, newline
		mov rdi, 1
		mov rax, 1
		syscall

		pop rsi
		pop rdi

		jmp loop_head

	loop_exit: ; updated 64 bit call
		mov rax, 60
		xor rdi, rdi
		syscall

is_prime: 
    ; this is the function that will check if numbers 1-99 are prime using a very simple technique
    ; since every number is divisible by its square root, and the exlusive bound 100's square root is 10,
    ; we only need to divide every number 1-99, by prime numbers less than 10, AKA 2, 3, 5, and 7

	; use "brute force" to deal with numbers below 7
	mov rax, rcx
	; mov rax, r11 -> chnaged to be prime_tracker
	cmp rax, 1
	je return_zero
	cmp rax, 2
	je return_one
	cmp rax, 3
	je return_one
	cmp rax, 5
	je return_one
	cmp rax, 7
	je return_one

	; if r11 is greater than 7, then divide to check if they are prime	

	; first divide by 2
	xor rdx, rdx; clear value of rdx for remainder.
	mov rax, [prime_tracker]
	; mov rax, r11 ; move the value of r11 into rax ->  changed to prime_tracker
	mov rbx, 2
	div rbx ; divide rax by rbx
	cmp rdx, 0
	je return_zero
	; if not equal to zero, try dividing by 3
	xor rdx, rdx
	mov rax, [prime_tracker]
	; mov rax, r11 -> changed to prime_tracker
	mov rbx, 3
	div rbx
	cmp rdx, 0
	je return_zero
	; if not equal to zero, try dividing by 5
	xor rdx, rdx 
	mov rax, [prime_tracker]
	; mov rax, r11 -> changed to prime_tracker
	mov rbx, 5
	div rbx
	cmp rdx, 0
	je return_zero
	; if not equal to zero, try dividing by 7
	xor rdx, rdx
	mov rax, [prime_tracker]
	; mov rax, r11 -> changed to prime_tracker
	mov rbx, 7
	div rbx
	cmp rdx, 0
	je return_zero

	; finally, if not divisble by any, return 1 = prime
	return_one:
	mov rax, 1
	ret

	return_zero: 
	; if rdx, aka the remainder, is equal to zero = no prime
	mov rax, 0
	ret
	
