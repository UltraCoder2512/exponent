bits 64
default rel

section .data
    fmt db "%d", 0xd, 0xa, 0
    err db "This utility does not support negative exponents", 0xd, 0xa, 0
    wnaerr db "Correct usage: exp <base> <power>", 0xd, 0xa, 0

section .text
    extern printf
    extern ExitProcess
    extern atoi
    global main

    main:
        ;Set up stack
        push rbp
        mov rbp, rsp
        sub rsp, 32

        ;Preserve cli args in r10 and r11
        mov r10, rcx ;argc
        mov r11, rdx ;argv

        ;Validate args
        cmp r10, 3 ;2 args after program name
        jne .wrong_num_of_args ;Throw error

        ;Calculate index of argv[1]
        mov r12, 1
        imul r12, 8 ;Pointer size
        add r12, r11 ;r12 now points to argv[1]

        ;Calculate index of argv[2]
        mov r13, 2
        imul r13, 8 ;Pointer size
        add r13, r11 ;r13 now points to argv[2]

        ;Parse args to int
        mov rcx, [r12]
        call atoi
        mov r14, rax

        mov rcx, [r13]
        call atoi
        mov r15, rax

        ;Prepare to call exp
        mov rcx, r14
        mov rdx, r15

        call exp

        ;Prepare to call printf
        mov rcx, fmt
        mov rdx, rax
        mov rax, 0
        call printf

        xor rax, rax
        call ExitProcess

        .wrong_num_of_args:
            mov rcx, wnaerr
            mov rax, 0
            call printf
            call ExitProcess

    exp:
        ;*Args: base rcx, power rdx Returns result: rax
        ;Set up stack
        push rbp
        mov rbp, rsp
        sub rsp, 32

        ;Check if exponent > 0
        cmp rdx, 0
        je .zero

        mov rax, rcx ;Store a copy
        mov rbx, 1 ;Counter

        .for_loop:
            imul rcx, rax
            inc rbx
            cmp rbx, rdx
            jl .for_loop
            jmp .end_loop

        .zero:
            mov rax, 1

        .end_loop:
            mov rax, rcx
            xor rcx, rcx
            xor rdx, rdx
            leave
            ret 