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

        // symbolic constants for Linux/AArch32
        .equ BUFSIZ,             64
        .equ NULL,                0
        .equ SIGCHLD,            20
        .equ SHUT_RDWR,           1

        .equ STDIN_FILENO,        0
        .equ STDOUT_FILENO,       1
        .equ STDERR_FILENO,       2

        .equ AF_INET,             2
        .equ SOCK_STREAM,         1
        .equ IPPROTO_IP,          0

        .equ EPOLLIN,             1

        .equ EPOLL_CTL_ADD,       1
        .equ EPOLL_CTL_DEL,       2
        .equ EPOLL_CTL_MOD,       3

        // system calls
        .equ SYS_exit,            1
        .equ SYS_fork,            2
        .equ SYS_read,            3
        .equ SYS_write,           4
        .equ SYS_close,           6
        .equ SYS_execve,         11
        .equ SYS_kill,           37
        .equ SYS_pipe,           42
        .equ SYS_dup2,           63
        .equ SYS_epoll_ctl,     251
        .equ SYS_epoll_wait,    252
        .equ SYS_socket,        281
        .equ SYS_bind,          282
        .equ SYS_connect,       283
        .equ SYS_listen,        284
        .equ SYS_accept,        285
        .equ SYS_shutdown,      293
        .equ SYS_epoll_create1, 357

.macro movl Wn, imm
    movw    \Wn, \imm & 0xFFFF
    movt    \Wn, (\imm >> 16) & 0xFFFF
.endm
