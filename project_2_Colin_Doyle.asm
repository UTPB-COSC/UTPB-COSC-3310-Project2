section .data
    str_prime db " Is prime", 0x0a, 0x00
    len_prime equ $ - str_prime
    str_not_prime db " Is not prime", 0x0a, 0x00
    len_not_prime equ $ - str_not_prime
    num_count dq 0x01
    counter dq 0x01
    max_num dq 1000
    decomp_a dq 0x00
    decomp_b dq 0x00
    nums db '0123456789'

section .text
global _start

_start:
    ; r10 is QWORD [counter]
    ; r11 is QWORD [decomp_b]
    ; r13 is QWORD [decomp_a]

loop:
    push QWORD [counter]
    call fn_print_digit
    push QWORD [counter]
    call is_prime
    add QWORD [counter], 1

    cmp QWORD [counter], 10
    je loop_tail
    jmp loop

loop_tail:
    push QWORD [counter]
    call fn_print_number
    push QWORD [counter]
    call is_prime
    add QWORD [counter], 1
    
    mov rax, QWORD [max_num] 
    cmp QWORD [counter], rax
    je loop_end
    jmp loop_tail
loop_end:
    mov rax, 1
    int 0x80
    ret
    
not_prime:
    mov rdx, len_not_prime
    mov rcx, str_not_prime
    mov rbx, 1
    mov rax, 4
    int 0x80
    
    ret
prime:
    mov rdx, len_prime
    mov rcx, str_prime
    mov rbx, 1
    mov rax, 4
    int 0x80
    
    ret

is_prime:
    pop rax 
    pop QWORD [decomp_b]
    push rax
    mov QWORD [decomp_a], 2
    div_loop_mid:
        mov rax, QWORD [decomp_a] ; two de refrences cant be in the same line
        cmp QWORD [decomp_b], rax
        je div_loop_end
        jmp div_loop_head
    
    div_loop_head:
        cmp QWORD [decomp_a], 10
        je div_loop_end
        jmp div_loop
    
    div_loop:
        mov rdx, 0
        mov rcx, 0
        mov rbx, QWORD [decomp_a]
        mov rax, QWORD [decomp_b]
        div rbx
        add QWORD [decomp_a], 1
        cmp rdx, 0
        je not_prime
        jmp div_loop_mid
        
    div_loop_end:
        call prime
        ret
    ret


fn_print_digit:
    pop rax 
    pop QWORD [decomp_b]
    push rax

    mov rdx, 1
    mov rcx, nums
    add rcx, QWORD [decomp_b]
    mov rbx, 1
    mov rax, 4
    int 0x80

    ret

fn_print_number:
    pop rax 
    pop QWORD [decomp_b]
    push rax

    cmp QWORD [decomp_b], 10
    jge num_decomp

    push QWORD [decomp_b]
    call fn_print_digit
    ret

    rev_print:
        cmp QWORD [decomp_a], 0
        je rev_print_exit

        call fn_print_digit
        sub QWORD [decomp_a], 1
        jmp rev_print
    rev_print_exit:
        ret
        
    num_decomp:
        mov QWORD [decomp_a], 0

        decomp_loop_head:
            cmp QWORD [decomp_b], 0
            je rev_print

        decomp_loop_body:
            mov rdx, 0
            mov rcx, 0
            mov rbx, 10
            mov rax, QWORD [decomp_b]
            div rbx

            push rdx 
            mov QWORD [decomp_b], rax
            
            add QWORD [decomp_a], 1
            jmp decomp_loop_head