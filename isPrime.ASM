section .data
    prime_msg:     db " is prime.", 10
    prime_msg_len: equ $ - prime_msg

    notprime_msg:  db " is not prime.", 10
    notprime_msg_len: equ $ - notprime_msg

    num_buffer:     times 3 db 0   ; buffer for printing numbers

section .text
    global _start

_start:
    mov rbx, 1    ; current number = 1
    mov r9, 99    ; end number = 99, stored in r9 and never modified

loop_start:
    mov rax, rbx
    call is_prime   ; al=1 if prime, else 0

    call print_number

    cmp al, 1
    je print_prime

    ; print " is not prime.\n"
    mov rax, 1       ; write
    mov rdi, 1       ; stdout
    mov rsi, notprime_msg
    mov rdx, notprime_msg_len
    syscall
    jmp after_print

print_prime:
    mov rax, 1
    mov rdi, 1
    mov rsi, prime_msg
    mov rdx, prime_msg_len
    syscall

after_print:
    inc rbx
    cmp rbx, r9
    jg end_program   ; if rbx > 99, end
    jmp loop_start

end_program:
    mov rax, 60  ; exit
    xor rdi, rdi
    syscall

;-------------------------------------------
; is_prime:
; Input: rax = number
; Output: al = 1 if prime, 0 if not prime
;-------------------------------------------
is_prime:
    ; preserve rbx
    push rbx

    cmp rax, 2
    jb .not_prime

    mov rdi, 2        ; divisor starts at 2
.check_loop:
    cmp rdi, rax
    jge .prime_found

    ; Check remainder of rax / rdi
    ; We'll do a division safely:
    push rax
    push rdi
    mov rbx, rax
    xor rdx, rdx
    div rdi
    pop rdi
    pop rax

    cmp rdx, 0
    je .not_prime

    inc rdi
    jmp .check_loop

.prime_found:
    mov al,1
    jmp .done

.not_prime:
    mov al,0

.done:
    pop rbx
    ret

;-------------------------------------------
; print_number:
; Input: rbx = number to print (1..99)
; Prints the number without newline
;-------------------------------------------
print_number:
    ; save registers
    push rbx
    push rax
    push rdx
    push rcx

    mov rax, rbx
    mov rcx, 10
    xor rdx, rdx
    cmp rax, 10
    jb .single_digit

    ; Two-digit number
    xor rdx, rdx
    div rcx         ; rax = tens, rdx = ones
    add al, '0'
    mov [num_buffer], al
    mov rax, rdx
    add al, '0'
    mov [num_buffer+1], al
    mov byte [num_buffer+2], 0

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel num_buffer]
    mov rdx, 2
    syscall
    jmp .done_print

.single_digit:
    add al, '0'
    mov [num_buffer], al
    mov byte [num_buffer+1], 0

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel num_buffer]
    mov rdx, 1
    syscall

.done_print:
    pop rcx
    pop rdx
    pop rax
    pop rbx
    ret
