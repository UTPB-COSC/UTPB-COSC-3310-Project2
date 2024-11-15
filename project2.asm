; Making use of Prof.'s code for printing values 1-99 in order
section .data:
newline db 0x0a, 0x00
nl_len equ $ - newline
nums db '123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899'
prime db " is prime", 0xA
prime_len equ $ - prime

no_prime db " is not prime", 0xA
no_prime_len equ $ - no_prime
section .text
global _start
_start:
	loop_init:
		xor r10, r10 ; set iterator variable value to 0
        xor r11, r11 ; prime number counter set to 0 because it will have 1 added to it the first iteration
	loop_head:
		cmp r10, 189
		jge loop_exit
	loop_body:
		mov rcx, nums
		add rcx, r10
		mov rdx, 1
		cmp r10, 9
        ; if r10, the iterator, is less than 9, go straight to print
		jl print 
        ; if it isn't, then add 1 more to rdx, which will be added to r10 in print
		add rdx, 1
		print:
        ; print the number
		mov rbx, 1
		mov rax, 4  
		add r10, rdx
		int 0x80

		; increment r11 by 1
		add r11, 1
		call is_prime ; call to check if is prime, 1 = prime, 0 = not prime
		cmp rax, 0
		je print_no_prime

		cmp rax, 1
		; if rax is 1, print the no prime string
		je print_prime

		print_prime: ; print prime statement
		mov rdx, prime_len
		mov rcx, prime
		mov rbx, 1
		mov rax, 4
		int 0x80
		
		jmp print_newline ; don't want to print the no prime statement, so unconditional jump

		print_no_prime: ; print is not a prime statement
		mov rdx, no_prime_len
		mov rcx, no_prime
		mov rbx, 1
		mov rax, 4
		int 0x80

		print_newline: 
        ; print the newline
		mov rdx, nl_len
		mov rcx, newline
		mov rbx, 1
		mov rax, 4
		int 0x80
        ; go back to loop header
		jmp loop_head
	loop_exit:
		mov rax, 1
		int 0x80

is_prime: 
    ; this is the function that will check if numbers 1-99 are prime using a very simple technique
    ; since every number is divisible by its square root, and the exlusive bound 100's square root is 10,
    ; we only need to divide every number 1-99, by prime numbers less than 10, AKA 2, 3, 5, and 7

	; use "brute force" to deal with numbers below 7
	mov rax, r11
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
	mov rax, r11 ; move the value of r11 into rax
	mov rbx, 2
	div rbx ; divide rax by rbx
	cmp rdx, 0
	je return_zero
	; if not equal to zero, try dividing by 3
	xor rdx, rdx
	mov rax, r11
	mov rbx, 3
	div rbx
	cmp rdx, 0
	je return_zero
	; if not equal to zero, try dividing by 5
	xor rdx, rdx 
	mov rax, r11
	mov rbx, 5
	div rbx
	cmp rdx, 0
	je return_zero
	; if not equal to zero, try dividing by 7
	xor rdx, rdx
	mov rax, r11
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
	
