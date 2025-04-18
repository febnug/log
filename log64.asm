section .data
    dev_null    db "/dev/null", 0        ; Path ke /dev/null
    log_file    db "backup.log", 0       ; Nama file log
    log_msg     db "Backup berhasil", 10 ; Pesan untuk ditulis ke file log
    log_len     equ $ - log_msg          ; Panjang pesan

section .text
    global _start

_start:
    ; === Buka /dev/null (untuk stdout) ===
    mov rax, 2              ; syscall: sys_open
    mov rdi, dev_null       ; filename
    mov rsi, 2              ; O_RDWR (baca dan tulis)
    xor rdx, rdx            ; mode = 0
    syscall
    mov r12, rax            ; simpan fd /dev/null (untuk stdout)

    ; === Alihkan stdout ke /dev/null (dup2) ===
    mov rdi, r12            ; oldfd = fd dari /dev/null
    mov rsi, 1              ; newfd = 1 (stdout)
    mov rax, 33             ; syscall: sys_dup2
    syscall

    ; === Alihkan stderr ke /dev/null (dup2) ===
    mov rdi, r12            ; oldfd = fd dari /dev/null
    mov rsi, 2              ; newfd = 2 (stderr)
    mov rax, 33             ; syscall: sys_dup2
    syscall

    ; === Buka file log (backup.log) ===
    mov rax, 2              ; syscall: sys_open
    mov rdi, log_file       ; nama file
    mov rsi, 0x241          ; O_WRONLY | O_CREAT | O_TRUNC
    mov rdx, 0o644          ; permission = 0664
    syscall
    mov r13, rax            ; simpan fd log

    ; === Tulis ke file log ===
    mov rax, 1              ; syscall: sys_write
    mov rdi, r13            ; fd file log
    mov rsi, log_msg        ; buffer
    mov rdx, log_len        ; panjang pesan
    syscall

    ; === Tutup file log ===
    mov rax, 3              ; syscall: sys_close
    mov rdi, r13            ; fd log
    syscall

    ; === Keluar dengan exit(0) ===
    mov rax, 60             ; syscall: sys_exit
    xor rdi, rdi            ; exit code = 0
    syscall
