section .data
newline db 0x0a, 0x00
nl_len equ $ - newline

nums db '123456789101112131415161718192021222324252627282930313233343536373839404142434445464748495051525354555657585960616263646566676869707172737475767778798081828384858687888990919293949596979899'

prime_str db ' is prime.',0x00
prime_len equ $ - prime_str

not_prime_str db ' is not prime.',0x00
not_prime_len equ $ - not_prime_str

current_num dq 0      
nums_offset dq 0        

section .text
global _start

_start:
   
    xor rax, rax
    mov [current_num], rax
    mov [nums_offset], rax

loop_head:
  
    mov rax, [current_num]
    add rax, 1
    mov [current_num], rax


    cmp rax, 100
    jge loop_exit

   
    mov rbx, [nums_offset]

    
    mov rcx, nums
    add rcx, rbx

  
    mov rdx, 1
    cmp rax, 9
    jle short_num
    add rdx, 1

short_num:
   
    mov rbx, 1       
    mov rax, 4       
    int 0x80


    mov rbx, [nums_offset]
    add rbx, rdx
    mov [nums_offset], rbx

    
    mov rax, [current_num]

    cmp rax, 1
    jle print_not_prime
    mov rcx, rax
    mov rbx, 2

prime_check_loop:
    cmp rbx, rcx
    jge prime_found  
    mov rax, rcx
    xor rdx, rdx
    div rbx 

    cmp rdx, 0
    je print_not_prime 

    inc rbx
    jmp prime_check_loop

prime_found:
    mov rdx, prime_len
    mov rcx, prime_str
    mov rbx, 1
    mov rax, 4
    int 0x80
    jmp print_newline

print_not_prime:
    mov rdx, not_prime_len
    mov rcx, not_prime_str
    mov rbx, 1
    mov rax, 4
    int 0x80

print_newline:
    mov rdx, nl_len
    mov rcx, newline
    mov rbx, 1
    mov rax, 4
    int 0x80

    jmp loop_head

loop_exit:
    mov rax, 1 
    xor rbx, rbx
    int 0x80