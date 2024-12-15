section .data
linefeed db 0x0a, 0x00                
linefeed_len equ $ - linefeed
digits db '0123456789'
primeText db ' is prime', 0x0a, 0x00    
primeText_len equ $ - primeText
notPrimeText db ' is not prime', 0x0a, 0x00 
notPrimeText_len equ $ - notPrimeText
counter db 1                        

section .text
global _start

_start:

    mov QWORD [counter], 1          

check_loop:
    
    mov rax, QWORD [counter]

    
    cmp rax, 100
    jge exit_program

    call display_number

    call is_number_prime

    
    cmp rbx, 1                     
    je output_prime
    call output_not_prime
    jmp post_message                

output_prime:
    mov rdx, primeText_len
    mov rcx, primeText
    mov rbx, 1
    mov rax, 4
    int 0x80
    jmp post_message

output_not_prime:
    mov rdx, notPrimeText_len
    mov rcx, notPrimeText
    mov rbx, 1
    mov rax, 4
    int 0x80

post_message:
    
    add QWORD [counter], 1
    jmp check_loop

exit_program:
   
    mov rax, 1
    int 0x80

display_number:
    mov rax, QWORD [counter]

    cmp rax, 10
    jl single_digit_output

    call split_and_print
    ret

single_digit_output:
   
    mov rdx, 1
    mov rcx, digits
    add rcx, rax                    
    mov rbx, 1
    mov rax, 4
    int 0x80
    ret

is_number_prime:
    mov rbx, 1                      
    mov rax, QWORD [counter]
    cmp rax, 2                      
    jl set_not_prime                
    cmp rax, 2                      
    je confirm_prime

    
    mov rcx, 2                      
    mov rdx, 0                      
    mov rbx, rax                    
    divisor_loop:
        mov rdx, 0                  
        div rcx                     
        cmp rdx, 0                  
        je set_not_prime
        inc rcx                     
        mov rax, QWORD [counter]    
        cmp rcx, rax                
        jl divisor_loop             

confirm_prime:
    mov rbx, 1                      
    ret

set_not_prime:
    mov rbx, 0                     
    ret

split_and_print:
    mov rbp, 0                      
    mov rdi, QWORD [counter]        

split_digits:
    cmp rdi, 0
    je finish_split

    mov rdx, 0
    mov rbx, 10
    div rbx                         

    push rdx
    add rbp, 1                      
    mov rdi, rax                    
    jmp split_digits

finish_split:
   
print_digits:
    cmp rbp, 0
    je end_digit_print

    pop rdi
    mov rdx, 1
    mov rcx, digits
    add rcx, rdi
    mov rbx, 1
    mov rax, 4
    int 0x80

   
    sub rbp, 1
    jmp print_digits

end_digit_print:
    ret
