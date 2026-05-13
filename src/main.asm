BITS 64
default rel

global _start

section .data

;----------------------[ERR MSG]--------------------------------------
err_socket db "fatal: socket failed", 10
err_socket_len equ $ - err_socket

err_setsockopt db "fatal: setsockopt failed", 10
err_setsockopt_len equ $ - err_setsockopt

err_bind db "fatal: bind failed", 10
err_bind_len equ $ - err_bind

err_listen db "fatal: listen failed", 10
err_listen_len equ $ - err_listen
;----------------------[ERR MSG]--------------------------------------


response:
    db "HTTP/1.1 200 OK", 0xD, 0xA
    db "Content-Type: text/plain", 0xD, 0xA
    db "Content-Length: 14", 0xD, 0xA
    db 0xD, 0xA
    db "Hello, Sailor!", 0xD, 0xA
response_len equ $ - response

not_found:
    db "HTTP/1.1 404 Not Found", 0xD, 0xA
    db 0xD, 0xA
not_found_len equ $ - not_found

; struct sockaddr_in
; sin_family = AF_INET (2)
; sin_port   = htons(4221) = 0x107D, stored in memory as 10 7D
; sin_addr   = INADDR_ANY = 0
; sin_zero   = 8 zero bytes
sockaddr_in:
    dw 2                  ; AF_INET
    db 0x10, 0x7D         ; port 4221 in network byte order
    dd 0                  ; INADDR_ANY
    dq 0                  ; padding

reuse_opt       dd 1

;----------------------[ Reserved Storage ]--------------------------------------
section .bss
client_addr     resb 16
client_addr_len resd 1

req_buf         resb 1024
req_buf_len     resd 1

resp_buf        resb 1024
resp_buf_len    resd 1
;----------------------[ Reserved Storage ]--------------------------------------


section .text
_start:
    ; socket(AF_INET, SOCK_STREAM, 0)
    mov eax, 41           ; sys_socket
    mov edi, 2            ; AF_INET
    mov esi, 1            ; SOCK_STREAM
    xor edx, edx          ; protocol = 0
    syscall
    test eax, eax
    js .fail_socket
    mov r12d, eax         ; listen fd

    ; setsockopt(server_fd, SOL_SOCKET, SO_REUSEADDR, &reuse, sizeof(reuse))
    mov eax, 54                 ; sys_setsockopt
    mov edi, r12d               ; server_fd
    mov esi, 1                  ; SOL_SOCKET
    mov edx, 2                  ; SO_REUSEADDR
    lea r10, [rel reuse_opt]    ; &reuse_opt
    mov r8d, 4                  ; sizeof(int)
    syscall
    test eax, eax
    js .fail_setsockopt

    ; bind(listen_fd, &sockaddr_in, 16)
    mov eax, 49           ; sys_bind
    mov edi, r12d
    lea rsi, [rel sockaddr_in]
    mov edx, 16
    syscall
    test eax, eax
    js .fail_bind

    ; listen(listen_fd, 10)
    mov eax, 50           ; sys_listen
    mov edi, r12d
    mov esi, 10
    syscall
    test eax, eax
    js .fail_listen

.accept_loop:
    ; socklen_t len = 16
    mov dword [rel client_addr_len], 16

    ; accept(listen_fd, &client_addr, &len)
    mov eax, 43           ; sys_accept
    mov edi, r12d
    lea rsi, [rel client_addr]
    lea rdx, [rel client_addr_len]
    syscall
    test eax, eax
    js .accept_loop
    mov edi, eax         ; client fd
    call handle_client


    jmp .accept_loop

.fail_socket:
    lea rsi, [rel err_socket]
    mov edx, err_socket_len
    jmp .report_and_exit

.fail_setsockopt:
    lea rsi, [rel err_setsockopt]
    mov edx, err_setsockopt_len
    jmp .report_and_exit

.fail_bind:
    lea rsi, [rel err_bind]
    mov edx, err_bind_len
    jmp .report_and_exit

.fail_listen:
    lea rsi, [rel err_listen]
    mov edx, err_listen_len
    jmp .report_and_exit

.report_and_exit:
    mov eax, 1          ; sys_write
    mov edi, 2          ; stderr
    syscall

    test r12d, r12d
    jle .do_exit
    mov eax, 3
    mov edi, r12d
    syscall

.do_exit:
    mov eax, 60
    mov edi, 1
    syscall

handle_client:

  ; read data from client socket
    mov eax, 0
    lea rsi, [rel req_buf]
    mov edx, req_buf_len
    syscall

    ; cmp byte [rsi + 5], ' '

    
  ; write(client_fd, response, response_len)
    mov eax, 1            ; sys_write
    lea rsi, [rel response]
    mov edx, response_len
    syscall

    ; close(client_fd)
    mov eax, 3            ; sys_close
    syscall
    ret
