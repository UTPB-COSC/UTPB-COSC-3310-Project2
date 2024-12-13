section .data
newline db 0x0a, 0x00               ; Newline character
nl_len equ $ - newline
nums db '0123456789'
is_prime_msg db ' is prime', 0x0a, 0x00 ; " is prime" message
prime_len equ $ - is_prime_msg
not_prime_msg db ' is not prime', 0x0a, 0x00 ; " is not prime" message
not_prime_len equ $ - not_prime_msg
num db 1                      ; Current number

section .text
global _start

_start:


mov QWORD [num], 1     ; Initialize counter to 1

loop_head:
    ; Load current value
    mov rax, QWORD [num]

    ; This will check the # if it's greater than 99
    cmp rax, 100
    jge loop_exit

    ; Print the number
    call print_number

    ; Check if the number is prime
    call check_prime

    ; Print the appropriate message
    cmp rbx, 1                      ; rbx = 1 if prime, 0 if it's not
    je print_is_prime
    call print_not_prime
    jmp after_print                  ; Jump to after_print

print_is_prime:
    mov rdx, prime_len
    mov rcx, is_prime_msg
    mov rbx, 1
    mov rax, 4
    int 0x80
    jmp after_print

print_not_prime:
    mov rdx, not_prime_len
    mov rcx, not_prime_msg
    mov rbx, 1
    mov rax, 4
    int 0x80

after_print:
    ; Increment counter and loop
    add QWORD [num], 1
    jmp loop_head

loop_exit:
    ; Exit program
    mov rax, 1
    int 0x80

print_number:
    mov rax, QWORD [num]

    ; Check if single-digit
    cmp rax, 10
    jl print_single_digit

    ; Decompose and print multi-digit numbers
    call decompose
    ret

print_single_digit:
    ; Print single-digit number
    mov rdx, 1
    mov rcx, nums
    add rcx, rax                    ; Offset to correct digit
    mov rbx, 1
    mov rax, 4
    int 0x80
    ret

check_prime:
    mov rbx, 1                      ; Assume prime initially
    mov rax, QWORD [num]
    cmp rax, 2                      ; 2 is prime
    jl not_prime                    ; Numbers less than 2 are not prime
    cmp rax, 2                      ; 2 is prime
    je is_prime

    ; Divide by numbers from 2 to sqrt(n)
    mov rcx, 2                      ; Start divisor at 2
    mov rdx, 0                      ; Clear remainder
    mov rbx, rax                    ; Copy current number
    sqrt_loop:
        mov rdx, 0                  ; Clear remainder
        div rcx                     ; Divide rax by rcx
        cmp rdx, 0                  ; Check if divisible
        je not_prime
        inc rcx                     ; Increment divisor
        mov rax, QWORD [num]    ; Reload current number
        cmp rcx, rax                ; Stop when divisor >= number
        jl sqrt_loop                ; Loop until rcx >= rax

is_prime:
    mov rbx, 1                      ; Prime
    ret

not_prime:
    mov rbx, 0                      ; Not prime
    ret

decompose:
    mov rbp, 0                      ; Initialize digit count
    mov rdi, QWORD [num]        ; Load current number

decompose_head:
    cmp rdi, 0
    je decompose_exit

    ; Get the last digit
    mov rdx, 0
    mov rbx, 10
    div rbx                         ; rax = quotient, rdx = remainder

    ; Push remainder (last digit)
    push rdx
    add rbp, 1                      ; Increment digit count
    mov rdi, rax                    ; Update rdi with quotient
    jmp decompose_head

decompose_exit:
    ; Print digits in reverse order
rev_print_head:
    cmp rbp, 0
    je rev_print_exit

    ; Pop digit from stack and print
    pop rdi
    mov rdx, 1
    mov rcx, nums
    add rcx, rdi
    mov rbx, 1
    mov rax, 4
    int 0x80

    ; Decrement digit count
    sub rbp, 1
    jmp rev_print_head

rev_print_exit:
    ret
