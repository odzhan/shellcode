;
;  Copyright © 2016 Odzhan. All Rights Reserved.
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
    
    %ifndef BIN
      global get_verinfo
      global _get_verinfo
    %endif
    
    bits 32
; windows only function 
; returns major, minor and build version of windows
; from the PEB
; for 32 and 64-bit Windows
; Works from Windows NT4 up to Windows 10
get_verinfo:
_get_verinfo:
    push   edi
    push   esi
    xor    eax, eax
    dec    eax
    jz     gv_x64
    inc    eax
    mov    edi, [esp+12]  ; get ptr to os_ver structure
    mov    eax, [fs:eax+30h]  ; get peb
    lea    esi, [eax+164] ; offset to OS version info
    jmp    gv_l1
gv_x64:
    push   ecx
    pop    edi
    bits   64
    mov    rax, [gs:rax+60h]  ; peb on 64-bit systems
    lea    rsi, [rax+280] ; OS version info
    bits   32
gv_l1:
    movsd                 ; 32-bit major
    movsd                 ; 32-bit minor
    movsw                 ; 16-bit build
    pop    esi
    pop    edi
    ret
    