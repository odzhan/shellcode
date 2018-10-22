/**
  Copyright © 2015 Odzhan. All Rights Reserved.

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

#ifndef PI_H
#define PI_H

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <stddef.h>

#include <windows.h>
#include <psapi.h>
#include <winnt.h>
#include <Tlhelp32.h>

#if !defined (__GNUC__)
#include <Winternl.h>
#endif

#if defined (__GNUC__)
typedef unsigned long NTSTATUS;
#endif

#include "loadlib.h"
#include "winexec.h"
#include "createthread.h"

#ifdef __cplusplus
extern "C" {
#endif

typedef VOID (*pCreateRemoteThread64) (HANDLE hProcess, 
    LPSECURITY_ATTRIBUTES lpThreadAttributes, SIZE_T dwStackSize,
    LPTHREAD_START_ROUTINE lpStartAddress, LPVOID lpParameter,
    DWORD dwCreationFlags, LPDWORD lpThreadId, LPHANDLE hThread);
  
#ifdef __cplusplus
}
#endif

#if defined (__GNUC__)
typedef enum _SYSTEM_INFORMATION_CLASS {
    SystemBasicInformation                = 0,
    SystemPerformanceInformation          = 2,
    SystemTimeOfDayInformation            = 3,
    SystemProcessInformation              = 5,
    SystemProcessorPerformanceInformation = 8,
    SystemInterruptInformation            = 23,
    SystemExceptionInformation            = 33,
    SystemRegistryQuotaInformation        = 37,
    SystemLookasideInformation            = 45
} SYSTEM_INFORMATION_CLASS;
#endif

typedef BOOL (WINAPI *pIsWow64Process) (HANDLE, PBOOL);
typedef NTSTATUS (WINAPI *pNtQuerySystemInformation) (
    SYSTEM_INFORMATION_CLASS SystemInformationClass,
    PVOID                    SystemInformation,
    ULONG                    SystemInformationLength,
    PULONG                   ReturnLength);
    
// determine the application mode
#define X86_MODE   1  // 32-bit app on 32-bit OS
#define WOW64_MODE 2  // 32-bit app on 64-bit OS
#define X64_MODE   3  // 64-bit app on 64-bit OS
  
typedef struct _PROCENTRY_T {
  DWORD id;
  WCHAR name[MAX_PATH];
} PROCENTRY, *PPROCENTRY;

PPROCENTRY GetProcessList(VOID);
  
#endif