section .data
prime db ' is prime', 0x0a, 0
prime_len equ $ - prime
not_prime db ' is not prime', 0x0a, 0
not_prime_len equ $ - not_prime
buffer db 0, 0

section.bss
loop_counter dq 

section .text
global _start

_start:
    mov rcx, 1           ; initialize loop counter to 1

loop_head:
    cmp rcx, 100              ; checks to ensure r10 is less than 100
    jge loop_exit            ; exits if r10 >= 100

loop_body:
    ; load number into rax
    mov rax, rcx
    ; ensures the first few prime numbers (necessary for rest of code to work) print
    ; compares current num in r10 to 1, 2, 3, 5, and 7 and sends them to print
    cmp rax, 1 
    je is_not_prime_10
    cmp rax, 2
    je is_prime_10
    cmp rax, 3
    je is_prime_10
    cmp rax, 5
    je is_prime_10
    cmp rax, 7
    je is_prime_10
    
    test rax, 1              ; checks least significant bit (if it's 0 then it is automatically not prime)
    jz is_not_prime_10

; checks if divisible by 3
    mov rdx, 0               ; clear rdx (holds remainder)
    mov rbx, 3               ; divisor (3)
    div rbx                  ; performs division: rax = rax / 3, rdx = remainder
    cmp rdx, 0               ; checks if remainder is zero
    je is_not_prime_10          ; if divisible by 3, it's not prime

    ; checks if divisible by 5
    mov rax, rcx ; makes sure rax is r10
    mov rdx, 0               ; clear rdx (holds remainder)
    mov rbx, 5               ; divisor (5)
    div rbx                  ; performs division: rax = rax / 5, rdx = remainder
    cmp rdx, 0               ; checks if remainder is zero
    je is_not_prime_10          ; if divisible by 5, it's not prime

    ; checks if divisible by 7
    mov rax, rcx ; makes sure rax is r10
    mov rdx, 0               ; clear rdx (holds remainder)
    mov rbx, 7               ; divisor (7)
    div rbx                  ; performs division: rax = rax / 5, rdx = remainder
    cmp rdx, 0               ; checks if remainder is zero
    je is_not_prime_10          ; if divisible by 7, it's not prime
    
    
  is_prime_10:
    mov rax, rcx      ; makes sure rax is r10

    ; the following addresses digits with ones and tens places by dividing it by 10
    ; to have two separate ASCII values printed consecutively in the buffer register
    ; it converts integers to characters so they are able to print

    ; addresses tens place
    mov rbx, 10      ; divisor = 10
    xor rdx, rdx     ; sets rdx to 0
    div rbx          ; RAX / RBX -> quotient in RAX (tens), remainder in RDX (ones)
    ; RAX now holds tens place digit, RDX holds ones place digit

    add al, '0'      ; converts the tens digit to character equivalent (ASCII) by adding integer equivalent of '0' 
    mov [buffer], al ; store the ASCII character in buffer[0]

    mov al, dl       ; moves the ones digit to AL
    add al, '0'      ; convert the ones digit to ASCII
    mov [buffer+1], al ; stores the ASCII character in buffer[1]
    
    mov [loop_counter], rcx

    ; prints the number
    mov rax, 4       
    mov rbx, 1       
    mov rcx, buffer  ; holds number
    mov rdx, 2       ; length of the output (2 characters for 2 digits)
    int 0x80         

    ; prints " is prime"
    mov rbx, 1               
    mov rax, 4               
    lea rcx, prime     
    mov rdx, prime_len   
    int 0x80
    
    mov rcx, [loop_counter]
    jmp increment

is_not_prime_10:
    ; exactly the same as is_prime_10 
    mov rax, rcx      
    
    mov rbx, 10      
    xor rdx, rdx     
    div rbx      

    add al, '0'      
    mov [buffer], al 

    mov al, dl       
    add al, '0'      
    mov [buffer+1], al 
    
    mov [loop_counter], rcx

    mov rax, 4       
    mov rbx, 1       
    mov rcx, buffer  
    mov rdx, 2       
    int 0x80        

    mov rbx, 1              
    mov rax, 4              
    mov rcx, not_prime     
    mov rdx, not_prime_len   
    int 0x80
    
    mov rcx, [loop_counter]
    jmp increment ; goes to increment
    
increment:
    inc rcx       ; increases r10 by 1           
    jmp loop_head    ; goes to the loop head        

loop_exit:
    mov rax, 1              
    xor rdi, rdi            
    int 0x80
