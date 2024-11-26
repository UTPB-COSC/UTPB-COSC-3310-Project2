;Holden G, 11/25/24
;Program prints numbers 1-99, tests if number is prime or not, then prints the result

section .data
    newline db 0x0a, 0x00 ;Newline
    nl_len equ $ - newline ;Length of Newline

    ;Array of numbers from 1 to 99 as a string (189 characters total)
    nums db '123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899'

    prime_msg db " is prime.", 0x00 ;Message for prime numbers
    not_prime_msg db " is not prime.", 0x00 ;Message for non-prime numbers

    number db '0', '0', 0 ;Buffer to hold number and exit character

section .text ;Start of program
global _start
;Changed rdi registers to rsi ones
_start:
    xor rbp, rbp ;Clear rbp register (index variable) to 0 for loop iteration

loop_head:
    cmp rbp, 189 ;Compare current index (rbp) to 189 (length of nums array)
    jge loop_exit ;If index is >= 189, exit loop

    ;Get current number from the nums string using rbp as index
    mov rcx, nums ;Load address of current num into rcx
    add rcx, rbp ;Add the index (rbp) to rcx to get current number
    mov rdx, 1 ;Assume it's a single digit number (1 byte)
    cmp rbp, 9 ;If the index is less than 9, it's a single digit number
    jl single_digit
    add rdx, 1 ;Otherwise, it's a two-digit number (2 bytes)

single_digit:
    ;Print the current number (1 or two 2)
    mov rbx, 1
    mov rax, 4
    add rbp, rdx ;Increment rbp by 1 or 2, depending on number length
    int 0x80

    ;Convert the ASCII character(s) to integer value in rax
    xor rax, rax ;zero out register
    mov bl, byte [rcx] ;Load the current number's character
    sub bl, '0' ;Convert ASCII to integer (subtract '0')
    movzx rax, bl
    cmp rdx, 2 ;If it's a two-digit number
    jne check_prime ;Jump to check_prime if it's a single-digit number
    mov dl, byte [rcx + 1] ;Load the second byte for two-digit numbers
    sub dl, '0' ;Convert second ASCII digit to integer
    imul rax, rax, 10
    add rax, rdx ;Add the second digit to result

check_prime:
    ;Check if the current number is prime
    mov rsi, rax ;Move the number into rsi for prime check
    call is_prime

    ;Print newline after the current number and message
    mov rdx, nl_len
    mov rcx, newline
    mov rbx, 1
    mov rax, 4
    int 0x80

    ;Jump back to the loop head to process the next number
    jmp loop_head

loop_exit:
    ;Exits program
    mov rax, 1
    int 0x80

is_prime:
    ;Function to check if the number in rsi is prime
    push rbp
    mov rbp, rsp
    sub rsp, 8 ;Reserve space for local variables (8 bytes)

    ;Handle special cases for prime check
    cmp rsi, 2 ;Check if the number is 2
    je print_prime ;If number is 2, jump to print_prime
    cmp rsi, 1 ;Check if the number is 1
    jle print_not_prime ;If number is 1, jump to print_not_prime

    mov rcx, 2 ;Start checking divisors from 2

check_loop:
    mov rax, rsi ;Copy the number into rax for division
    xor rdx, rdx ;Clear rdx (remainder)
    div rcx
    cmp rdx, 0 ;If remainder (rdx) is 0, its not prime
    je print_not_prime
    inc rcx
    mov rax, rcx
    mul rcx ;rax = rcx^2
    cmp rax, rsi ;Compare rax (rcx^2) to rsi (number)
    jle check_loop ;If rcx^2 <= rsi, continue checking

print_prime:
    ;Print " is prime" message
    mov rdx, 10 ;Length of "is prime" message
    mov rcx, prime_msg
    mov rbx, 1
    mov rax, 4
    int 0x80
    jmp cleanup

print_not_prime:
    ;Print " is not prime" message
    mov rdx, 14 ;Length os "is not prime" message
    mov rcx, not_prime_msg
    mov rbx, 1
    mov rax, 4
    int 0x80

cleanup:
    ;Return from is_prime function
    mov rsp, rbp
    pop rbp
    ret
