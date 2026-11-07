extern printf
extern atoi
extern exit

default rel

section .data
	msg db "Prosek: %.2f", 0x0a, 0
	error_msg db 0x1b, "[31mError:", 0x1b, "[0m Invalid usage.", 0x0a, "Usage: %s <numbers>", 0x0a, 0
	debug_msg db "DEBUG: rax (current arg): %s", 0x0a, 0
	debug_msg2 db "DEBUG: r15d (sum): %d", 0x0a, 0
	
section .bss
	argc resq 1
	argv resq 1
	pros resq 1

section .text
global main

main:
	sub rsp, 40

	mov [argc], rcx
	mov [argv], rdx

	mov rsi, [argc]
	cmp rsi, 2
	jl error_exit

	mov rcx, [argv]
	mov rdx, [argc]
	call prosek
	movsd [pros], xmm0

	lea rcx, [msg]
	mov rdx, [pros]
	call printf

	xor rcx, rcx
	call exit

prosek:
	push r12
	push r13
	push r14
	push r15
	sub rsp, 40

	mov r12, rcx
	lea r13, [rdx - 1]
	xor r14d, r14d
	xor r15d, r15d
	.loop:
		inc r14d

	%ifdef DEBUG
		mov rdx, [r12 + r14*8]
		lea rcx, [debug_msg]
		call printf
	%endif

		mov rcx, [r12 + r14*8]
		call atoi
		movsxd rax, eax
		add r15, rax

	%ifdef DEBUG
		lea rcx, [debug_msg2]
		mov rdx, r15
		call printf
	%endif

		cmp r14, r13
		jl .loop
		
	cvtsi2sd xmm0, r15
	cvtsi2sd xmm1, r13
	divsd xmm0, xmm1

	add rsp, 40
	pop r15
	pop r14
	pop r13
	pop r12

	ret

error_exit:
	lea rcx, [error_msg]
	mov rdx, [argv]
	mov rdx, [rdx]
	call printf

	mov ecx, 1
	call exit
