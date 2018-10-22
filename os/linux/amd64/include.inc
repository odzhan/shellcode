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

%ifndef INCLUDE_INC
%define INCLUDE_INC

    %define STDIN_FILENO    0
    %define STDOUT_FILENO   1
    %define STDERR_FILENO   2

    %define AF_INET         2
    %define SOCK_STREAM     1

    %define EPOLLIN     0x001

    %define EPOLL_CTL_ADD 1
    %define EPOLL_CTL_DEL 2
    %define EPOLL_CTL_MOD 3

%define EPERM            1      ; Operation not permitted 
%define ENOENT           2      ; No such file or directory 
%define ESRCH            3      ; No such process 
%define EINTR            4      ; Interrupted system call 
%define EIO              5      ; I/O error 
%define ENXIO            6      ; No such device or address 
%define E2BIG            7      ; Argument list too long 
%define ENOEXEC          8      ; Exec format error 
%define EBADF            9      ; Bad file number 
%define ECHILD          10      ; No child processes 
%define EAGAIN          11      ; Try again 
%define ENOMEM          12      ; Out of memory 
%define EACCES          13      ; Permission denied 
%define EFAULT          14      ; Bad address 
%define ENOTBLK         15      ; Block device required 
%define EBUSY           16      ; Device or resource busy 
%define EEXIST          17      ; File exists 
%define EXDEV           18      ; Cross-device link 
%define ENODEV          19      ; No such device 
%define ENOTDIR         20      ; Not a directory 
%define EISDIR          21      ; Is a directory 
%define EINVAL          22      ; Invalid argument 
%define ENFILE          23      ; File table overflow 
%define EMFILE          24      ; Too many open files 
%define ENOTTY          25      ; Not a typewriter 
%define ETXTBSY         26      ; Text file busy 
%define EFBIG           27      ; File too large 
%define ENOSPC          28      ; No space left on device 
%define ESPIPE          29      ; Illegal seek 
%define EROFS           30      ; Read-only file system 
%define EMLINK          31      ; Too many links 
%define EPIPE           32      ; Broken pipe 
%define EDOM            33      ; Math argument out of domain of func 
%define ERANGE          34      ; Math result not representable 

%define ESTRPIPE        86      ; Streams pipe error 
%define EUSERS          87      ; Too many users 
%define ENOTSOCK        88      ; Socket operation on non-socket 
%define EDESTADDRREQ    89      ; Destination address required 
%define EMSGSIZE        90      ; Message too long 
%define EPROTOTYPE      91      ; Protocol wrong type for socket 
%define ENOPROTOOPT     92      ; Protocol not available 
%define EPROTONOSUPPORT 93      ; Protocol not supported 
%define ESOCKTNOSUPPORT 94      ; Socket type not supported 
%define EOPNOTSUPP      95      ; Operation not supported on transport endpoint 
%define EPFNOSUPPORT    96      ; Protocol family not supported 
%define EAFNOSUPPORT    97      ; Address family not supported by protocol 
%define EADDRINUSE      98      ; Address already in use 
%define EADDRNOTAVAIL   99      ; Cannot assign requested address 
%define ENETDOWN        100     ; Network is down 
%define ENETUNREACH     101     ; Network is unreachable 
%define ENETRESET       102     ; Network dropped connection because of reset 
%define ECONNABORTED    103     ; Software caused connection abort 
%define ECONNRESET      104     ; Connection reset by peer 
%define ENOBUFS         105     ; No buffer space available 
%define EISCONN         106     ; Transport endpoint is already connected 
%define ENOTCONN        107     ; Transport endpoint is not connected 
%define ESHUTDOWN       108     ; Cannot send after transport endpoint shutdown 
%define ETOOMANYREFS    109     ; Too many references: cannot splice 
%define ETIMEDOUT       110     ; Connection timed out 
%define ECONNREFUSED    111     ; Connection refused 
%define EHOSTDOWN       112     ; Host is down 
%define EHOSTUNREACH    113     ; No route to host 
%define EALREADY        114     ; Operation already in progress 
%define EINPROGRESS     115     ; Operation now in progress 
%define ESTALE          116     ; Stale NFS file handle 
%define EUCLEAN         117     ; Structure needs cleaning 
%define ENOTNAM         118     ; Not a XENIX named type file 
%define ENAVAIL         119     ; No XENIX semaphores available 
%define EISNAM          120     ; Is a named type file 
%define EREMOTEIO       121     ; Remote I/O error 
%define EDQUOT          122     ; Quota exceeded 

%ifndef AMD64
    bits 32
    
    %define SYS_exit           0x001
    %define SYS_fork           0x002
    %define SYS_read           0x003
    %define SYS_write          0x004
    %define SYS_open           0x005
    %define SYS_close          0x006
    %define SYS_execve         0x00B
    %define SYS_access         0x021
    %define SYS_kill           0x025
    %define SYS_pipe           0x02A
    %define SYS_dup2           0x03f
    %define SYS_socketcall     0x066
    %define SYS_epoll_ctl      0x0FF
    %define SYS_epoll_wait     0x100
    %define SYS_epoll_create1  0x149
    %define SYS_shutdown       0x175

    %define SYS_SOCKET      1
    %define SYS_BIND        2
    %define SYS_CONNECT     3
    %define SYS_LISTEN      4
    %define SYS_ACCEPT      5
    %define SYS_GETSOCKNAME 6
    %define SYS_GETPEERNAME 7
    %define SYS_SOCKETPAIR  8
    %define SYS_SEND        9
    %define SYS_RECV       10
    %define SYS_SENDTO     11
    %define SYS_RECVFROM   12
    %define SYS_SHUTDOWN   13
    %define SYS_SETSOCKOPT 14
    %define SYS_GETSOCKOPT 15
    %define SYS_SENDMSG    16
    %define SYS_RECVMSG    17
    %define SYS_ACCEPT4    18
    %define SYS_RECVMMSG   19
    %define SYS_SENDMMSG   20

struc pushad_t
  _edi resd 1
  _esi resd 1
  _ebp resd 1
  _esp resd 1
  _ebx resd 1
  _edx resd 1
  _ecx resd 1
  _eax resd 1
  .size:
endstruc

%else
    bits 64
    
    %define SYS_read             0
    %define SYS_write            1
    %define SYS_open             2
    %define SYS_close            3
    %define SYS_mmap             9
    %define SYS_mprotect        10
    %define SYS_access          21
    %define SYS_pipe            22
    %define SYS_select          23
    %define SYS_dup2            33
    %define SYS_socket          41
    %define SYS_connect         42
    %define SYS_accept          43
    %define SYS_shutdown        48
    %define SYS_bind            49
    %define SYS_listen          50
    %define SYS_clone           56
    %define SYS_fork            57
    %define SYS_execve          59
    %define SYS_exit            60
    %define SYS_kill            62
    %define SYS_reboot         169
    %define SYS_epoll_wait     232
    %define SYS_epoll_ctl      233
    %define SYS_pselect6       270
    %define SYS_epoll_pwait    281
    %define SYS_epoll_create1  291
    %define SYS_dup3           292
    %define SYS_pipe2          293
    %define SYS_memfd_create   319
%endif

%define O_RDONLY             00
%define O_WRONLY             01
%define O_RDWR               02

%define EINTR                 4

%define SIGCHLD 20
%define BUFSIZ  64

%define SHUT_RDWR     1

struc epoll_event
  events resd 1
  data   resq 1
endstruc

struc ds_tbl
  @p_in  resd 2     ; pipe for stdin of shell
  @in0   equ  @p_in
  @in1   equ  @p_in+4

  @p_out resd 2     ; pipe for stdout/stderr of shell
  @out0  equ  @p_out
  @out1  equ  @p_out+4

  @pid   resd 1     ; process id for shell
  @s     resd 1     ; socket handle
%ifdef BIND
  @s2    resd 1     ; socket for bind
%endif
  @efd   resd 1     ; event handle
  @evts  resb epoll_event_size
  @buf   resb BUFSIZ
endstruc

%define htons(x) (((x >> 8) & 0xFF) | ((x & 0xFF) << 8))

%endif
