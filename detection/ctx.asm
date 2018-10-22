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
      global _get_ctx
      global get_ctx
    %endif
    
    bits   32
get_ctx:
_get_ctx:
    push   ebx           ; save ebx for 32-bit bsd/linux
    push   edi           ; save edi for windows/bsd/linux
    
    push   ecx           ; for windows, put ptr to proc_ctx in edi
    pop    edi
    
    push   esp
    pop    eax
    shr    eax, 24
    jz     is_32         ; we're windows
    
    pop    edi           ; we're linux/bsd/osx
    push   edi    
is_32:
    xor    eax, eax      ; eax=0
    dec    eax           ; ignored if 64-bit
    neg    eax           ; if eax==0 goto x64
    jz     x64
    
    mov    edi, [esp+12] ; get proc_ctx from stack
x64:
    stosd                ; save emu value
    lea    ecx, [eax-1]
    push   esp
    pop    eax
    shr    eax, 24
    setz   al
    stosd                ; save win value
    ; save segment registers
    mov    ax, cs
    stosw
    mov    ax, ds
    stosw
    mov    ax, es
    stosw
    mov    ax, fs
    stosw
    mov    ax, gs
    stosw
    mov    ax, ss
    stosw

    ; get stack pointer
    push   esp
    pop    eax
    stosd
    jecxz  x32_native
    dec    eax
    ror    eax, 32
    stosd            ; only if 64-bit
    push   ecx       ; save ecx since bsd trashes it
    push   edi       ; save edi because we need to use it
    
    push   -1        ; handle
    pop    edi
    push   6         ; 
    pop    eax       ; eax=sys_close
    syscall
    
    pop    edi       ; restore edi
    pop    ecx       ; restore ecx
    
    stosd
    dec    eax
    ror    eax, 32
    stosd
x32_l3:
    pop    edi
    pop    ebx
    push   1
    pop    eax
    ret
x32_native:
    mov    cx, gs    ; win32 native? skip it
    jecxz  x32_l3
    
    push   esp
    pop    eax
    shr    eax, 24
    jz     x32_l3
    
    push   -1
    pop    ebx
    push   6
    pop    eax
    ; required for 32-bit freebsd
    push   ebx
    push   esp
    shr    cx, 8      ; 
    jnz    solaris
    int    0x80
    jmp    pop_reg
solaris:
    int    0x91
pop_reg:
    pop    ecx ; release args for fbsd
    pop    ecx
    stosd
    jmp    x32_l3
    
    
    
