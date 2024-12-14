section .data
newline db 0x0a, 0x00
nl_len equ $ - newline
nums db '0123456789'
num0 dq 1
num1 dq 1
num2 dq 1
count dq 2
iter dq 10
value db 0
pointer db 0
divider dq 2

section .text
global _start

_start:
    mov rax, 1
    push rax
    push rax
    call fn_print_number

next_number:
    mov rax, [value]
    cmp rax, 100
    jge done

    mov rbx, [divider]
    push rbx
    push rax
    call check_prime

    mov rax, [value]
	add rax, 1
	mov [value], rax
	jmp next_number

check_prime:
    pop rax
    pop rbx
    mov rcx, 0

check_divisibility:
    cmp rbx, rax
    jge prime_found

    mov rdx, 0
    div rbx
    cmp rdx, 0
    je not_prime

    mov rdx, [divider]
    add rbx, 1
    jmp check_divisibility

prime_found:
    cmp rcx, 0
    je print_prime
    jmp next_number

not_prime:
    mov rcx, 1
    jmp next_number

print_prime:
    push rax
    call fn_print_number
    cmp rbx, rax
    call fn_print_message
    mov rbx, newline
    call fn_print_message
    pop rax
    jmp next_number

done:
    mov rax, 1
    xor rbx, rbx
    int 0x80

fn_print_digit:
    pop rax
    pop rdx
    push rax
    mov rcx, nums
    add rcx, rdx
    mov rdx, 1
    mov rbx, 1
    mov rax, 4
    int 0x80
    ret

fn_print_number:
    pop rax
    pop rdx
    push rax
    cmp rdx, 10
    push rdx
    jge decomp
    call fn_print_digit

    mov rdx, nl_len
    mov rcx, newline
    mov rbx, 1
    mov rax, 4
    int 0x80
    ret
decomp:
    decomp_loop_init:
        mov r13, 0
        pop r11
    decomp_loop_head:
        cmp r11, 0
        je decomp_loop_exit
    decomp_loop_body:
        mov rdx, 0
        mov rcx, 0
        mov rbx, 10
        mov rax, r11
        div rbx
        mov r11, rax
        push rdx
    decomp_loop_tail:
        add r13, 1
        jmp decomp_loop_head
    decomp_loop_exit:
    decomp_print_loop_init:
    decomp_print_loop_head:
        cmp r13, 0
        je decomp_print_loop_exit
    decomp_print_loop_body:
        call fn_print_digit
    decomp_print_loop_tail:
        sub r13, 1
        jmp decomp_print_loop_head
    decomp_print_loop_exit:
        mov rdx, nl_len
        mov rcx, newline
        mov rbx, 1
        mov rax, 4
        int 0x80
        ret

fn_print_message:
    mov rdi, pointer
    mov rsi, 0
print_char_loop:
    mov al, [rdi + rsi]
    cmp al, 0
    je done_print_message
    mov rax, 1
    mov rdi, 1
    mov rdx, 1
    int 0x80
    inc rsi
    jmp print_char_loop

done_print_message:
    ret
