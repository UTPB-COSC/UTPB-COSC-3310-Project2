section .data
num dq 1 ; num will take value 1:99
primeMsg db " is prime.",10
primeMsg_len equ $-primeMsg
notPrimeMsg db " is not prime.",10
notPrimeMsg_len equ $-notPrimeMsg
digits db "0123456789" ; this used by printInt for print the current char using it's value for example digits[0] = '0' and digits[9] = '9'
section .text
global _start
_start:

mainLoop:
    mov rax,[num] ; rax = current number 
    cmp rax,100
    jge main_exit
    ; here num <=99
    mov rax,[num] ; print the current number 
    call printInt
    call isPrime ; if the current number prime rax = 1 if not rax = 0
    cmp rax,0
    je mainLoopNotPrime ; not prime case 
    ; prime case 
    ; print " is prime."
    mov rax,4 
    mov rbx,1
    mov rcx,primeMsg
    mov rdx,primeMsg_len
    int 0x80
    jmp mainLoopU
mainLoopNotPrime:
    ; print " is not prime."
    mov rax,4 
    mov rbx,1
    mov rcx,notPrimeMsg
    mov rdx,notPrimeMsg_len
    int 0x80
mainLoopU:
    ; increamnet num 
    inc qword [num] ; go to next number 
    jmp mainLoop
main_exit:
    mov rax,1
    mov rbx,0 ; exit with 0
    int 0x80
isPrime: 
    ; save registers rbx rcx rdx to stack 
    push rbx
    push rcx
    push rdx
    xor rbx,rbx ; rbx = 0 ; we use rbx to count number of divisors that divise num 
    mov rcx,1 ; we start from 1:num 
isPrimeLoop:
    cmp rcx,[num]
    jg isPrimeLoopDone
    ; here rcx < num 
    ; rdx:rax = num 
    mov rax,[num] 
    xor rdx,rdx ; rdx = 0
    div rcx ; rax = num/rcx (quotient) rdx = num%rcx (remainder)
    cmp rdx,0
    jne isPrimeLoopUpdate ; if remainder !=0 mean num not divided by rcx 
    inc rbx ; here divided by rcx so we need to increamnet rbx 
isPrimeLoopUpdate:
    inc rcx ; increamnet rcx 
    jmp isPrimeLoop
isPrimeLoopDone:
    cmp rbx,2 ; compare number of divisor of num with 2
    je isPrime1 ; if number of divisor is 2 mean prime (prime accept just one and itself as divisors)
    xor rax,rax ; not prime we need to return 0
isPrimeDone:
    pop rdx
    pop rcx
    pop rbx
    ret
isPrime1:
    mov rax,1 ; prime we need to return 1 
    jmp isPrimeDone

printInt:
    push rax
    push rbx
    push rcx
    push rdx 

    xor rcx,rcx ; rcx = 0
    mov rbx,10
printIntL1:
    xor rdx,rdx ; rdx = 0
    div rbx
    push rdx
    inc rcx
    cmp rax,0
    jne printIntL1
printIntL2:
    pop rax
    push rcx
    mov rcx,digits
    add rcx,rax
    mov rdx,1
    mov rbx,1
    mov rax,4
    int 0x80
    pop rcx
    loop printIntL2
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret
