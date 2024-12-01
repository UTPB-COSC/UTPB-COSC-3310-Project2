section .data
    ; Messages for output
    str_prime_check db " Is prime", 0x0a, 0   
    len_prime equ $ - str_prime_check         
    str_not_prime db " Is not prime", 0x0a, 0    
    len_not_prime equ $ - str_not_prime          

    ; Variables for loop and calculations
    counter dq 1                                 ; Starting number
    end_num dq 99                                ; Ending number
    current_divisor dq 0                         ; Divisor for checking primes
    number_to_check dq 0                         ; Number being checked
    nums db '0123456789'                         ; Characters for digits

section .text
    global _start                               

_start:
mainLoop:
    ; Loop through numbers from counter to end_num
    mov rax, [counter]
    cmp rax, [end_num]
    jg main_exit                                 ; Exit loop if counter > end_num

    push QWORD [counter]
    call fn_print_number                         ; Print the current number

    push QWORD [counter]
    call is_prime                                ; Check if the number is prime
    cmp rax, 0                                   ; 0 = not prime, 1 = prime
    je mainLoopNotPrime                          ; Jump if not prime

    ; Print "Is prime" message
    mov rdx, len_prime
    mov rcx, str_prime_check
    mov rbx, 1
    mov rax, 4
    int 0x80
    jmp mainLoopUpdate                           ; Skip "not prime" message

mainLoopNotPrime:
    ; Print "Is not prime" message
    mov rdx, len_not_prime
    mov rcx, str_not_prime
    mov rbx, 1
    mov rax, 4
    int 0x80

mainLoopUpdate:
    ; Increment counter and repeat the loop
    add QWORD [counter], 1
    jmp mainLoop

main_exit:
    ; Exit the program
    mov rax, 1
    xor rbx, rbx
    int 0x80

is_prime:
    ; Function to check if a number is prime
    pop rax
    pop QWORD [number_to_check]
    push rax
    mov QWORD [current_divisor], 2               ; Start dividing from 2

div_loop_mid:
    ; Check if the divisor equals the number
    mov rax, QWORD [current_divisor]
    cmp QWORD [number_to_check], rax
    je div_loop_end                              ; End loop if divisor equals number
    jmp div_loop_head

div_loop_head:
    ; Stop if divisor exceeds the number
    mov rax, QWORD [number_to_check]
    cmp QWORD [current_divisor], rax
    jge div_loop_end                             ; End loop if divisor > number
    jmp div_loop

div_loop:
    ; Perform division to check for factors
    mov rdx, 0
    mov rbx, QWORD [current_divisor]
    mov rax, QWORD [number_to_check]
    div rbx                                     ; Divide number by divisor
    add QWORD [current_divisor], 1              ; Increment divisor
    cmp rdx, 0                                  ; Check remainder
    je not_prime                                ; If divisible, not prime
    jmp div_loop_mid

div_loop_end:
    mov rax, 1                                  ; Number is prime
    ret

not_prime:
    xor rax, rax                                ; Number is not prime
    ret

fn_print_digit:
    ; Function to print a single digit
    pop rax
    pop QWORD [number_to_check]
    push rax

    mov rdx, 1
    mov rcx, nums                               ; Get digit characters
    add rcx, QWORD [number_to_check]            ; Offset for the digit
    mov rbx, 1
    mov rax, 4
    int 0x80
    ret

fn_print_number:
    ; Function to print a number (multiple digits)
    pop rax
    pop QWORD [number_to_check]
    push rax

    cmp QWORD [number_to_check], 10
    jge num_decomp                              ; Decompose if number >= 10

    push QWORD [number_to_check]
    call fn_print_digit                         ; Print single digit
    ret

num_decomp:
    ; Decompose number into individual digits
    mov QWORD [current_divisor], 0

decomp_loop_head:
    ; Continue until all digits are processed
    cmp QWORD [number_to_check], 0
    je rev_print

decomp_loop_body:
    ; Extract the least significant digit
    mov rdx, 0
    mov rbx, 10
    mov rax, QWORD [number_to_check]
    div rbx                                     ; Divide by 10
    push rdx                                    ; Push remainder (digit)
    mov QWORD [number_to_check], rax            ; Update number
    add QWORD [current_divisor], 1              ; Increment digit count
    jmp decomp_loop_head

rev_print:
    ; Print digits in reverse order
    cmp QWORD [current_divisor], 0
    je rev_print_exit

    call fn_print_digit                         ; Print a digit
    sub QWORD [current_divisor], 1
    jmp rev_print

rev_print_exit:
    ret

