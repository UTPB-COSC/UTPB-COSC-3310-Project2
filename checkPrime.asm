section .data
    msg_display_prime:     db " is prime.", 10
    len_prime: equ $ - msg_display_prime

    notmsg_display_prime:  db " is not prime.", 10
    notlen_prime: equ $ - notmsg_display_prime

    buffer_chunk:     times 3 db 0

section .text
    global _start

_start:
    mov rbx, 1    ;
    mov r9, 99    ;

loop_start:
    mov rax, rbx
    call is_prime   ; al=1 if prime, else 0

    call display_number

    cmp al, 1
    je print_prime

    ; print " is not prime.\n"
    mov rax, 1       ; write
    mov rdi, 1       ; stdout
    mov rsi, notmsg_display_prime
    mov rdx, notlen_prime
    syscall
    jmp after_print

print_prime:
    mov rax, 1
    mov rdi, 1
    mov rsi, msg_display_prime
    mov rdx, len_prime
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

    mov rdi, 2
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
; display_number:
; Input: rbx = number to print (1..99)
; This would print the number without newline
;-------------------------------------------
display_number:
    ; save registers
    push rbx
    push rax
    push rdx
    push rcx

    mov rax, rbx
    mov rcx, 10
    xor rdx, rdx
    cmp rax, 10
    jb .digit_one

    ; Two-digit number
    xor rdx, rdx
    div rcx         ; rax = tens, rdx = ones
    add al, '0'
    mov [buffer_chunk], al
    mov rax, rdx
    add al, '0'
    mov [buffer_chunk+1], al
    mov byte [buffer_chunk+2], 0

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel buffer_chunk]
    mov rdx, 2
    syscall
    jmp .print_finish

.digit_one:
    add al, '0'
    mov [buffer_chunk], al
    mov byte [buffer_chunk+1], 0

    mov rax, 1
    mov rdi, 1
    lea rsi, [rel buffer_chunk]
    mov rdx, 1
    syscall

.print_finish:
    pop rcx
    pop rdx
    pop rax
    pop rbx
    ret
