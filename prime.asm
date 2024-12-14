section .data
newline db 0x0a, 0x00
nl_len equ $ - newline
nums db '123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899'
prime_msg db " is prime.", 0x0a, 0x00
not_prime_msg db " is not prime.", 0x0a, 0x00

section .text
global _start

_start:
    loop_init:
        xor r10, r10          ; Index into nums array (offset)
        mov r11, 1            ; Current number to check (1 to 99)

    loop_head:
        cmp r10, 189          ; End of nums array (99 reached)
        jge loop_exit

    loop_body:
        ; Print the current number
        mov rcx, nums
        add rcx, r10          ; Get pointer to current number
        mov rdx, 1
        cmp r10, 9
        jl print_number
        add rdx, 1
    print_number:
        mov rbx, 1
        mov rax, 4
        add r10, rdx          ; Advance nums pointer
        int 0x80

        ; Check if the current number is prime
        mov rsi, r11          ; Pass current number to is_prime
        call is_prime
        cmp rax, 1            ; rax = 1 means prime, 0 means not prime
        je print_prime

        ; Print "is not prime."
        mov rcx, not_prime_msg
        mov rdx, 16           ; Length of " is not prime."
        jmp print_message

    print_prime:
        ; Print "is prime."
        mov rcx, prime_msg
        mov rdx, 11           ; Length of " is prime."

    print_message:
        mov rbx, 1
        mov rax, 4
        int 0x80

        ; Print a newline
        mov rdx, nl_len
        mov rcx, newline
        mov rbx, 1
        mov rax, 4
        int 0x80

        ; Advance to the next number
        inc r11               ; Increment current number
        jmp loop_head         ; Repeat the loop

    loop_exit:
        mov rax, 1
        int 0x80

is_prime:
    ; Input: rsi = number to check
    ; Output: rax = 1 (prime) or 0 (not prime)

    cmp rsi, 2
    je prime_case            ; 2 is prime
    cmp rsi, 1
    jle not_prime            ; 1 and 0 are not prime

    ; Initialize divisor to 2
    mov rdi, 2

prime_check_loop:
    ; Check if divisor >= number (stop the check if divisor is greater than or equal to the number)
    mov rax, rdi
    cmp rax, rsi
    jge prime_case            ; If divisor >= number, it's prime

    ; Check divisibility
    mov rax, rsi
    xor rdx, rdx
    div rdi                  ; rsi / rdi, result in rax, remainder in rdx
    cmp rdx, 0               ; Check remainder
    je not_prime             ; If remainder is 0, it's not prime

    inc rdi                  ; Increment divisor
    jmp prime_check_loop     ; Continue the loop

prime_case:
    mov rax, 1               ; Prime
    ret

not_prime:
    mov rax, 0               ; Not prime
    ret
