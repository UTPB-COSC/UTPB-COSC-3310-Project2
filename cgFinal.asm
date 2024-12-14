BITS 32 ; x32 Assembly - It seemed like you intended on us using 32 bit- I will be using eax, ebx, ecx, and edx (registers A-D)

section .data
	msg_prime db ' is prime.', 0x0A, 0
	msg_not_prime db ' is not prime.', 0x0A, 0
	return_address dd 0

section .bss
	num_str resb 20 ; Our integer string representation
	result_len resd 1 ; Our result length for printing a string.
	prime_message resb 20 ; Our prime or not message to be printed for each number.
	
section .text
	global _start

; Our initialization step and entry point	
_start:
	; We will be using ecx as our counter. Initializing it to 1:
	mov ecx, 1
	call main_loop

; Our testing method
testing:
	mov eax, 59

	call convert_int
	call prime_check
	call exit

	; mov eax, 13
	; call sqrt
	; mov eax, edx
	; call convert_int
	; mov ebx, num_str
	; call print

; Our main runtime loop.
main_loop:
	; Print counter value here
	; mov eax, ecx
	; call convert_int
	; mov ebx, num_str
	; call print
	mov eax, ecx

	call prime_check


	; Increment our counter
	inc ecx

	; Check if counter has reached 100 - not, continue loop
	cmp ecx, 100
	jl main_loop ; If ecx is less than 100, jump to beginning of loop

	; Main runtime loop is done here
	; Exit system call
	call exit

; Saves our registers to the stack
save_registers:
	pop dword [return_address] ; Store the return address
	push eax
	push ebx
	push ecx
	push edx
	push dword [return_address] ; Restore the return address
	ret

; Restores our registers from the stack
load_registers:
	pop dword [return_address] ; Store the return address
	pop edx
	pop ecx
	pop ebx
	pop eax
	push dword [return_address] ; Restore the return address
	ret

; Gets the length of the string stored in ebx. Stores the length in result_len
get_length:
	; Note: when loading msg into ebx, don't reference address, use the message (dont do [msg])
	mov ecx, 0
	mov edx, ebx ; Save our msg register so it can be restored
	.loop_start:
		; Check if the current byte is 0 (the null terminator)
		mov al, [ebx] ; Load next byte of string. Note: AL is part of EAX
		cmp al, 0 ; Compare with null
		je .finish ; If zero, we are done
		inc ecx ; Increment the length
		inc ebx
		jmp .loop_start
	.finish:
		mov [result_len], ecx ; Store the length
		mov ebx, edx ; Restore our message in case we want to do something like printing it again
		ret

; Prints the string stored in EAX
print:
	call save_registers
	call get_length
	mov ecx, ebx
	mov edx, [result_len]
	mov ebx, 1
	mov eax, 4
	int 0x80
	call load_registers
	ret

; Converts the integer stored in EAX into it's string representation and stores it in num_str
convert_int:
	call save_registers
	mov ecx, 0 ; Counter for number of digits

	.conversion_loop:
		mov edx, 0 ; Clear edx for division
		mov ebx, 10 ; Base 10 division
		div ebx ; Divide our int by 10 and store quotient in eax and remainder in edx
		add dl, '0' ; Convert remainder to ASCII (dl part of edx)
		push dx ; Save ascii digit (dx part of edx)
		inc ecx ; Inc amt of digits
		cmp eax, 0
		jne .conversion_loop ; If the quotient is not equal to 0, continue

	lea ebx, [num_str]

	.store_digits:
		pop ax ; Retrieve digits from stack and store them in ax (part of eax)
		mov [ebx], al
		inc ebx
		loop .store_digits

		mov byte [ebx], 0 ; Null terminate our integer string
		jmp .finish

	.finish:
		call load_registers
		ret

; Checks whether the integer stored in EAX is prime or not and sets the prime_message accordingly.
prime_check:
	call save_registers
	mov ecx, eax ; Store our original number
	xor edx, edx

	push edx ; Push an extra value to the stack that can be popped if we get not_prime here V

	cmp eax, 2
	mov ebx, ecx ; Pass our number into ebx so it works.
	jl not_prime ; Less than 2 means not prime
	je prime ; 2 means prime

	mov ebx, 2 ; Divisor 2
	div ebx

	cmp edx, 0 ; See if the remainder is 0 - if so, not prime
	mov ebx, ecx ; Pass our number into ebx so it works.
	je not_prime


	mov eax, ecx ; Move our saved number back into eax

	cmp eax, 3
	je prime ; Explicit def so the logic of our loop doesn't break (imagine plugging a 3 in there. see below)

	pop edx ; Remove the extra value since we didn't have a "pre-mature" exit

	call sqrt ; Get the sqrt of our number, rounded up. Result stored in edx

	mov ecx, 1 ; Initialize our counter for the square root loop. Start at 3 since 2 or lower was ruled out. Putting 1 here so we can inc at beginning of loop
	mov ebx, edx ; Move our sqrt to a different register so we can use div for the remainder. cgdev
	.sqrt_loop:
		add ecx, 2 ; Increment our counter by 2 to only include odd nums. On first loop, we will start at 3 essentially.
		xor edx, edx ; Clear edx so it doesn't throw an exception when we try div
		push ebx ; Temporarily store our sqrt on the stack to free up this register

		mov ebx, eax ; Temporarily save our number so we don't corrupt with div. Sqrt restored later.
		div ecx ; Divide by our counter. We want remainder in edx to see if evenly divided
		cmp edx, 0 ; See if evenly divided
		je not_prime ; Not prime if evenly divided

		; If past here, we need to restore our number to eax and restore our sqrt. 
		mov eax, ebx

		pop ebx ; Restore our sqrt value
		cmp ecx, ebx ; Compare our counter to the sqrt of our number
		jl .sqrt_loop ; Continue the loop if the counter is less than square root of n

	push edx ; Push a trash value to be popped
	jmp prime ; Number passed the test and is prime

	not_prime:
		mov eax, ebx ; Take our saved number 
		pop ebx ; Clean the stack since we didn't get to pop our ebx yet.
		call convert_int
		mov ebx, num_str
		call print ; Print our number
		mov ebx, msg_not_prime
		call print ; Print whether it is prime or not
		call load_registers
		ret

	prime:
		pop edx ; Pop the extra value and clean the stack
		call convert_int
		mov ebx, num_str
		call print ; Print our number
		mov ebx, msg_prime
		call print ; Print whether it is prime or not
		call load_registers
		ret

; Determines the INT square root for the number in eax. Doing this because I'm not allowed to use FPU. Result is stored in edx.
sqrt:
	mov ecx, 1 ; For trial squares 
	xor ebx, ebx ; For temporarily storing the result

	.square_loop:
		mov edx, ecx
		imul edx, edx ; Square the number
		cmp edx, eax
		jge .finish

		inc ecx
		jmp .square_loop
	
	.finish:
		mov edx, ecx
		ret

; Terminates the program.
exit:
	; Exit system call
	mov eax, 1
	xor ebx, ebx ; Set exit code to 0 (success)
	int 0x80

