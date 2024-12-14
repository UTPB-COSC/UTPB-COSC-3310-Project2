; ASM File that will iterate through numbers 1-99 and check if they are prime or not and
; will print a different message depending if the number is prime or not.
; Coded NASM x64
bits 64
default rel

; This section contains the message strings for when
; a number is prime or not
section .data
    numberIsPrime db " is prime.", 10, 0
    numberIsNotPrime db " is not prime.", 10, 0

; This section contains variables with no value
; Block started by Symbol
section .bss
    number resq 1
    isPrime resq 1
    counter resq 1
    buffer resb 20

section .text
global _start

_start:
    ; Start iteration from 1 to 99
    mov qword [number], 1

check_next:
    ; Stop if number > 99
    cmp qword [number], 100      
    jge end_program

    ; Assume the number is prime
    mov qword [isPrime], 1
    mov rax, [number]
    mov qword [counter], 2

    ; The logic implemented in the prime check loop
    ; will only work for numbers gte to 3
    ; If one, it is not prime
    cmp rax, 1
    je not_prime_found

    ; If two, it is prime
    cmp rax, 2
    je prime_found

prime_check_loop:
    ; Grabs the number and counter and divides by counter and if it is ever 0 then it not a prime
    ; counter will increment until it greater than number
    mov rax, [number]
    mov rbx, [counter]
    xor rdx, rdx
    div rbx                    
    cmp rdx, 0
    je not_prime_found

    inc qword [counter]
    mov rax, [counter]
    mul rax  
    cmp rax, [number]
    jle prime_check_loop

prime_found:
    ; Print prime message
    mov rax, [number]
    call print_number
    mov rdx, 10
    lea rsi, [numberIsPrime]
    call print_message
    jmp increment_number

not_prime_found:
    ; Print not prime message
    mov rax, [number]
    call print_number
    mov rdx, 14  
    lea rsi, [numberIsNotPrime] 
    call print_message

increment_number:
    ; Increments the number
    inc qword [number]    
    jmp check_next

end_program:
    ; Stop the program
    mov rax, 60    
    xor rdi, rdi    
    syscall

print_number:
    ; Prints number based on buffer
    mov rcx, buffer + 19 
    mov rbx, 10     

.number_loop:
    ; Clears remainder and converts number into ASCII for printing
    ; since it is in binary
    xor rdx, rdx     
    div rbx           
    add dl, '0'      
    dec rcx             
    mov [rcx], dl       
    test rax, rax      
    jnz .number_loop

    ; Print number
    mov rax, 1          
    mov rdi, 1         
    mov rsi, rcx      
    mov rdx, buffer + 20 
    sub rdx, rcx    
    syscall
    ret

print_message:
    ; Print the message stored in rax with length in rdi
    mov rax, 1   
    mov rdi, 1   
    syscall
    ret
