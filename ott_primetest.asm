section .data
is_prime db " is prime", 10
is_prime_len equ $ - is_prime
is_not_prime db " is not prime", 10
is_not_prime_len equ $ - is_not_prime
nums db '123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899'
count dq 0 ; counter for checking each num's primality
nums_count dq 0 ; counter for nums string position

section .text
global _start

_start:

loop_init:
	xor rax, rax ; clear rax before operations

loop_head:
	mov rax, [nums_count] ; restore rax to nums counter
	cmp rax, 189 ; 189 is the total num of chars in nums string
	jge loop_exit

loop_body:
	mov rcx, nums
	add rcx, rax
	mov rdx, 1
	cmp rax, 9
	jl print
	add rdx, 1

	print:
	; write number
	mov rbx, 1
	add rax, rdx
	mov [nums_count], rax ; preserve rax in nums counter
	mov rax, 4
	int 0x80

	; increment count
	mov rax, [count]
	add rax, 1
	mov [count], rax ; set count to rax

	; special cases for 1 and 2
	cmp rax, 1
	je print_not_prime
	cmp rax, 2
	je print_is_prime

	cmp rax, 99
	jg loop_exit ; exit if count > 99

	mov rbx, 2 ; start divisor at 2

	primality_test:
	xor rdx, rdx ; clear rdx before dividing
	div rbx
	cmp rdx, 0 ; check remainder (held in rdx after div)
	je print_not_prime ; if remainder = 0, print not prime
	add rbx, 1 ; rbx stores divisor, add 1 for every division
	mov rax, [count] ; restore rax to current num being checked for primality
	cmp rbx, rax
	jl primality_test ; continue dividing num while divisor < num

	jmp print_is_prime ; if loop finishes, print is prime

print_is_prime:
	mov rdx, is_prime_len
	mov rcx, is_prime
	mov rbx, 1
	mov rax, 4
	int 0x80

	jmp loop_head

print_not_prime:
	mov rdx, is_not_prime_len
	mov rcx, is_not_prime
	mov rbx, 1
	mov rax, 4
	int 0x80

	jmp loop_head

loop_exit:
	mov rax, 1
	int 0x80
