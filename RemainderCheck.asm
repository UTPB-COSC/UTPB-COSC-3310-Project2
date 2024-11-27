section .data
num dq 3                ; Number being divided
remainder db 1          ; Placeholder for remainder (as a byte for printing)
len_remainder equ 2     ; Length of the remainder buffer (since it's one byte)

section .text
global _start

_start:
  xor rdx, rdx             ; Clear register
  mov rax, [num]           ; Load number being divided
  mov rcx, 2               ; Load divisor
  div rcx                  ; Divides, quotient in rax, remainder in rdx
  add rdx, '0'             ; Convert remainder to ASCII (if it's a single digit)
  mov [remainder], dl      ; Store the ASCII value of remainder

print_rem:
  mov rax, 4
  mov rbx, 1
  mov rcx, remainder
  mov rdx, len_remainder
  int 0x80

rem_exit:
  mov rax, 1
  xor rdi, rdi
  int 0x80