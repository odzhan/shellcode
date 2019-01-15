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
; SIMECK64/128 Block Cipher in x86 assembly
;
; size: 97 bytes
;
; global calls use cdecl convention
;
; -----------------------------------------------
    bits 32

    %ifndef BIN
      global _simeck
    %endif

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

%define w0 ebx
%define w1 eax

%define k0 ecx
%define k1 edx
%define k2 edi
%define k3 ebp

%define t0 esi
%define s0 dword[esp+_edi+4]
%define s1 dword[esp+_esi+4]

_simeck:
    pushad
    mov    edi, 0xBCA3083F
    mov    esi, 0x938
    pushad
    mov    esi, [esp+64+4] ; esi=mk
    lodsd
    xchg   eax, k0
    lodsd
    xchg   eax, k1
    lodsd
    xchg   eax, k2
    lodsd
    xchg   eax, k3
    mov    esi, [esp+64+8] ; esi=x
    push   esi
    lodsd
    xchg   eax, w0
    lodsd
sm_l0:
    xor    w0, k0  ; x[0]^=k[0];
    mov    t0, w1  ; x[0]^=R(x[1],1);
    rol    t0, 1   ;
    xor    w0, t0  ;
    rol    t0, 4   ; x[0]^=(R(x[1],5)&x[1]);
    and    t0, w1  ;
    xor    w0, t0  ;

    xchg   w0, w1  ; X(x[0],x[1]);

    ; t0 = (s & 1) - 4;
    xor    t0, t0
    shr    s1, 1
    rcr    s0, 1
    adc    t0, -4

    xor    k0, t0  ; k[0]^=t0;
    mov    t0, k1  ; k[0]^=R(k[1],1);
    rol    t0, 1   ;
    xor    k0, t0  ;
    rol    t0, 4   ; k[0]^=(R(k[1],5)&k[1]);
    and    t0, k1  ;
    xor    k0, t0  ;

    xchg   k0, k1  ; X(k[0],k[1]);
    xchg   k1, k2  ; X(k[1],k[2]);
    xchg   k2, k3  ; X(x[0],k[0]);

    cmp    s0, 0
    jnz    sm_l0

    pop    edi
    xchg   eax, w0
    stosd          ; x[0]=w0;
    xchg   eax, w0
    stosd          ; x[1]=w1;

    popad
    popad
    ret
