/**
  Copyright © 2019 Odzhan. All Rights Reserved.

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

// https://gnutls.org/manual/html_node/How-to-use-GnuTLS-in-applications.html#How-to-use-GnuTLS-in-applications

#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include <signal.h>
#include <sys/epoll.h>
#include <errno.h>
#include <unistd.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <dirent.h>
#include <glob.h>

#include <link.h>
#include <elf.h>
#include <fcntl.h>
#include <dlfcn.h>
#include <sys/mman.h>

#include <gnutls/gnutls.h>

// system calls required to query base address of host process
long _open(const char *, unsigned long, long);
int _read(long, char *, unsigned long);
int _close(unsigned int);
void *_mmap(void *, unsigned long, unsigned long, unsigned long,  long, unsigned long);
int _munmap(void *, size_t);
int _fstat(long, void *);
long _write(long fd, char *buf, unsigned long len);

typedef pid_t (*fork_t)(void);
typedef int (*dup2_t)(int oldfd, int newfd);
typedef int (*execve_t)(const char *filename, char *const argv[], char *const envp[]);
typedef int (*pipe_t)(int pipefd[2]);
typedef int (*open_t)(const char *pathname, int flags);
typedef ssize_t (*write_t)(int fd, const void *buf, size_t count);
typedef ssize_t (*read_t)(int fd, void *buf, size_t count);
typedef int (*close_t)(int fd);
typedef void *(*malloc_t)(size_t size);
typedef void (*free_t)(void *ptr);
typedef int (*kill_t)(pid_t pid, int sig);

typedef int (*globfunc_t)(const char *pattern, int flags, int (*errfunc) (const char *epath, int eerrno), glob_t *pglob);
typedef void (*globfree_t)(glob_t *pglob);

typedef int (*dlinfo_t)(void *handle, int request, void *info);
typedef void *(*dlopen_t)(const char *filename, int flag);
typedef void *(*dlsym_t)(void *handle, const char *symbol);

typedef int (*connect_t)(int sockfd, const struct sockaddr *addr, socklen_t addrlen);
typedef int (*socket_t)(int domain, int type, int protocol);
typedef in_addr_t (*inet_addr_t)(const char *cp);
typedef uint16_t (*htons_t)(uint16_t hostshort);
typedef ssize_t (*send_t)(int sockfd, const void *buf, size_t len, int flags);
typedef ssize_t (*recv_t)(int sockfd, void *buf, size_t len, int flags);
typedef int (*shutdown_t)(int socket, int how);

typedef int (*epoll_create1_t)(int flags);
typedef int (*epoll_ctl_t)(int epfd, int op, int fd, struct epoll_event *event);
typedef int (*epoll_wait_t)(int epfd, struct epoll_event *events, int maxevents, int timeout);

ssize_t _tls_data_push_cb(gnutls_transport_ptr_t ptr, const void *in, size_t inlen);
ssize_t _tls_data_pull_cb(gnutls_transport_ptr_t ptr, void *out, size_t outlen);

typedef int (*gnutls_certificate_allocate_credentials_t)(gnutls_certificate_credentials_t * res);
typedef int (*gnutls_certificate_set_x509_system_trust_t)(gnutls_certificate_credentials_t cred);
typedef int (*gnutls_init_t)(gnutls_session_t * session, unsigned int flags);
typedef int (*gnutls_set_default_priority_t)(gnutls_session_t session);
typedef int (*gnutls_credentials_set_t)(gnutls_session_t session, gnutls_credentials_type_t type, void * cred);
typedef int (*gnutls_server_name_set_t)(gnutls_session_t session, gnutls_server_name_type_t type, const void * name, size_t name_length);
typedef int (*gnutls_priority_init_t)(gnutls_priority_t * priority_cache, const char * priorities, const char ** err_pos);
typedef int (*gnutls_priority_set_t)(gnutls_session_t session, gnutls_priority_t priority);
typedef ssize_t (*gnutls_record_recv_t)(gnutls_session_t session, void * data, size_t sizeofdata);
typedef ssize_t (*gnutls_record_send_t)(gnutls_session_t session, const void * data, size_t sizeofdata);
typedef int (*gnutls_bye_t)(gnutls_session_t session, gnutls_close_request_t how);
typedef void (*gnutls_deinit_t)(gnutls_session_t session);
typedef void (*gnutls_global_deinit_t)(void);
typedef int (*gnutls_error_is_fatal_t)(int error);
typedef int (*gnutls_handshake_t)(gnutls_session_t session);
typedef int (*gnutls_transport_set_int2_t)(gnutls_session_t session, int recv_fd, int send_fd);
typedef void (*gnutls_transport_set_ptr_t)(gnutls_session_t session, gnutls_transport_ptr_t ptr);
typedef void (*gnutls_transport_set_push_function_t)(gnutls_session_t session, gnutls_push_func push_func);
typedef void (*gnutls_transport_set_pull_function_t)(gnutls_session_t session, gnutls_pull_func pull_func);

typedef struct _data_t {
    int s;                  // socket file descriptor

    union {
      uint64_t hash[64];
      void     *addr[64];
      struct {
        // gnu c library functions
        pipe_t          _pipe;
        fork_t          _fork;
        socket_t        _socket;
        inet_addr_t     _inet_addr;
        htons_t         _htons;
        connect_t       _connect;
        dup2_t          _dup2;
        close_t         _close;
        execve_t        _execve;
        epoll_create1_t _epoll_create1;
        epoll_ctl_t     _epoll_ctl;
        epoll_wait_t    _epoll_wait;
        open_t          _open;
        write_t         _write;
        read_t          _read;
        shutdown_t      _shutdown;
        kill_t          _kill;
        send_t          _send;
        recv_t          _recv;
        globfunc_t      _glob;
        globfree_t      _globfree;
        malloc_t        _malloc;
        free_t          _free;
 
        // gnu dynamic linker functions
        dlsym_t         _dlsym;
        dlopen_t        _dlopen;
        dlinfo_t        _dlinfo;
        
        // gnu tls functions
        gnutls_certificate_allocate_credentials_t  _gnutls_certificate_allocate_credentials;
        gnutls_certificate_set_x509_system_trust_t _gnutls_certificate_set_x509_system_trust;
        gnutls_init_t                              _gnutls_init;
        gnutls_set_default_priority_t              _gnutls_set_default_priority;
        gnutls_credentials_set_t                   _gnutls_credentials_set;
        gnutls_server_name_set_t                   _gnutls_server_name_set;
        gnutls_priority_init_t                     _gnutls_priority_init;
        gnutls_priority_set_t                      _gnutls_priority_set;
        gnutls_record_recv_t                       _gnutls_record_recv;
        gnutls_record_send_t                       _gnutls_record_send;
        gnutls_bye_t                               _gnutls_bye;
        gnutls_deinit_t                            _gnutls_deinit;
        gnutls_global_deinit_t                     _gnutls_global_deinit;
        gnutls_error_is_fatal_t                    _gnutls_error_is_fatal;
        gnutls_handshake_t                         _gnutls_handshake;
        gnutls_transport_set_ptr_t                 _gnutls_transport_set_ptr;
        gnutls_transport_set_push_function_t       _gnutls_transport_set_push_function;
        gnutls_transport_set_pull_function_t       _gnutls_transport_set_pull_function;
        gnutls_transport_set_int2_t                _gnutls_transport_set_int2;
      };
    } api;
} data_t;
 
void *get_proc_address(void *module, const char *name);

void *get_proc_address2(void *module, uint32_t hash);      // using base address
void *get_proc_address3(const char *path, uint32_t hash);  // using file path

void *get_module_handle(const char *module);
void *get_module_handle1(const char *module);
void *get_module_handle2(const char *module);
void *get_base(void);

Elf64_Phdr *elf_get_phdr(void *base, int type);
Elf64_Dyn *elf_get_dyn(void *base, int tag);

uint32_t gnu_hash(const uint8_t *name);
