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
  
#define UNICODE
  
#include <windows.h>
#include <stdio.h>
#include <TlHelp32.h>

LPVOID xmalloc (SIZE_T dwSize);
LPVOID xrealloc (LPVOID lpMem, SIZE_T dwSize);
VOID xfree (LPVOID lpMem);

#define STATUS_INFO_LEN_MISMATCH 0xC0000004

#if defined (__GNUC__)
typedef unsigned long NTSTATUS;
#endif

typedef struct _LSA_UNICODE_STRING {
  USHORT Length;
  USHORT MaximumLength;
  PWSTR  Buffer;
} LSA_UNICODE_STRING, *PLSA_UNICODE_STRING, UNICODE_STRING, *PUNICODE_STRING;

typedef enum _SYSTEM_INFORMATION_CLASS {
    SystemBasicInformation = 0,
    SystemPerformanceInformation = 2,
    SystemTimeOfDayInformation = 3,
    SystemProcessInformation = 5,
    SystemProcessorPerformanceInformation = 8,
    SystemInterruptInformation = 23,
    SystemExceptionInformation = 33,
    SystemRegistryQuotaInformation = 37,
    SystemLookasideInformation = 45
} SYSTEM_INFORMATION_CLASS;

typedef LONG KPRIORITY;

typedef struct _VM_COUNTERS {
	ULONG  PeakVirtualSize;
	ULONG  VirtualSize;
	ULONG  PageFaultCount;
	ULONG  PeakWorkingSetSize;
	ULONG  WorkingSetSize;
	ULONG  QuotaPeakPagedPoolUsage;
	ULONG  QuotaPagedPoolUsage;
	ULONG  QuotaPeakNonPagedPoolUsage;
	ULONG  QuotaNonPagedPoolUsage;
	ULONG  PagefileUsage;
	ULONG  PeakPagefileUsage;
} VM_COUNTERS;

typedef enum _THREAD_STATE {
	StateInitialized,
	StateReady,
	StateRunning,
	StateStandby,
	StateTerminated,
	StateWait,
	StateTransition,
	StateUnknown
} THREAD_STATE;

typedef enum _KWAIT_REASON
{
  Executive = 0,
  FreePage = 1,
  PageIn = 2,
  PoolAllocation = 3,
  DelayExecution = 4,
  Suspended = 5,
  UserRequest = 6,
  WrExecutive = 7,
  WrFreePage = 8,
  WrPageIn = 9,
  WrPoolAllocation = 10,
  WrDelayExecution = 11,
  WrSuspended = 12,
  WrUserRequest = 13,
  WrEventPair = 14,
  WrQueue = 15,
  WrLpcReceive = 16,
  WrLpcReply = 17,
  WrVirtualMemory = 18,
  WrPageOut = 19,
  WrRendezvous = 20,
  Spare2 = 21,
  Spare3 = 22,
  Spare4 = 23,
  Spare5 = 24,
  WrCalloutStack = 25,
  WrKernel = 26,
  WrResource = 27,
  WrPushLock = 28,
  WrMutex = 29,
  WrQuantumEnd = 30,
  WrDispatchInt = 31,
  WrPreempted = 32,
  WrYieldExecution = 33,
  WrFastMutex = 34,
  WrGuardedMutex = 35,
  WrRundown = 36,
  MaximumWaitReason = 37
} KWAIT_REASON;

typedef struct _CLIENT_ID {
   HANDLE UniqueProcess;
   HANDLE UniqueThread;
 } CLIENT_ID;
 
typedef struct _SYSTEM_THREADS {
	LARGE_INTEGER  KernelTime;
	LARGE_INTEGER  UserTime;
	LARGE_INTEGER  CreateTime;
	ULONG  WaitTime;
	PVOID  StartAddress;
	CLIENT_ID  ClientId;
	KPRIORITY  Priority;
	KPRIORITY  BasePriority;
	ULONG  ContextSwitchCount;
	THREAD_STATE  State;
	KWAIT_REASON  WaitReason;
} SYSTEM_THREADS, *PSYSTEM_THREADS;

typedef struct _SYSTEM_PROCESS_INFORMATION {
	ULONG  NextEntryDelta;
	ULONG  ThreadCount;
	ULONG  Reserved1[6];
	LARGE_INTEGER  CreateTime;
	LARGE_INTEGER  UserTime;
	LARGE_INTEGER  KernelTime;
	UNICODE_STRING  ProcessName;
	KPRIORITY  BasePriority;
	ULONG  ProcessId;
	ULONG  InheritedFromProcessId;
	ULONG  HandleCount;
	ULONG  Reserved2[2];
	VM_COUNTERS  VmCounters;
	IO_COUNTERS  IoCounters;
	SYSTEM_THREADS  Threads[1];
} SYSTEM_PROCESS_INFORMATION, *PSYSTEM_PROCESS_INFORMATION;

typedef NTSTATUS (WINAPI *pNtQuerySystemInformation) (
    SYSTEM_INFORMATION_CLASS SystemInformationClass,
    PVOID                    SystemInformation,
    ULONG                    SystemInformationLength,
    PULONG                   ReturnLength);
    
typedef LONG (WINAPI *pRtlCompareUnicodeString)(
    PUNICODE_STRING  String1,
    PUNICODE_STRING  String2,
    BOOLEAN          CaseInSensitive);
 
typedef struct _PROCENTRY_T {
  DWORD id;
  WCHAR name[MAX_PATH];
} PROCENTRY, *PPROCENTRY;
  
#ifndef _WIN64  
/**
 *
 * Obtain list of process names and their corresponding id's
 * across all 32-bit systems, including Wow64
 *
 */    
PPROCENTRY GetProcessList(VOID)
{
  pNtQuerySystemInformation   NtQuerySystemInformation;
  ULONG                       len=0, total=0, pe_size=0;
  NTSTATUS                    status;
  LPVOID                      list=NULL;
  PSYSTEM_PROCESS_INFORMATION p;
  PPROCENTRY                  pe;
  DWORD                       i;
  
  NtQuerySystemInformation = 
      (pNtQuerySystemInformation)GetProcAddress(
      GetModuleHandle(L"ntdll"), "NtQuerySystemInformation");
      
  if (!NtQuerySystemInformation) {
    // we couldn't resolve API address
    return NULL;
  }
  
  list = xmalloc(2048);
  
  do {
    len += 2048;
    list = xrealloc (list, len);
    
    if (list==NULL) {
      // we couldn't reallocate memory
      break;
    }
    status = NtQuerySystemInformation(SystemProcessInformation, list, len, &total);
  } while (status == STATUS_INFO_LEN_MISMATCH);
  
  if (status < 0) {
    // we were unable to obtain list of process
    xfree(list);
    return NULL;
  }
  
  p       = (PSYSTEM_PROCESS_INFORMATION)list;
  pe_size = sizeof(PROCENTRY);
  pe      = xmalloc(pe_size);
  
  for (i=0;;) 
  {
    if (p->ProcessName.Buffer != 0)
    {
      // copy process id and module name
      pe[i].id = p->ProcessId; 
      lstrcpy(pe[i].name, p->ProcessName.Buffer);
      
      pe_size += sizeof(PROCENTRY);
      pe = xrealloc(pe, pe_size);
      i++;
      if (pe==NULL) {
        break;
      }        
    }
    // no more entries? break
    if (p->NextEntryDelta==0) break;
    
    // advance to next entry
    p = (PSYSTEM_PROCESS_INFORMATION)(((char *)p) + p->NextEntryDelta);
  }
  
  xfree(list);
  return pe;
}
#else
/**
 *
 * Since NtQuerySystemInformation doesn't work on 64-bit, we
 * use the snapshot method
 *
 */    
PPROCENTRY GetProcessList(VOID)
{
  HANDLE         hSnap;
  PROCESSENTRY32 pe32;
  PPROCENTRY     pe=NULL;
  DWORD          i=0, pe_size;
  
  hSnap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if (hSnap != INVALID_HANDLE_VALUE)
  {
    pe32.dwSize = sizeof(PROCESSENTRY32);

    if (Process32First(hSnap, &pe32))
    {
      i       = 0;
      pe_size = sizeof(PROCENTRY);
      pe      = xmalloc(pe_size);
  
      do {
        if (pe32.th32ProcessID==0) continue;
        
        pe[i].id = pe32.th32ProcessID; 
        lstrcpy(pe[i].name, pe32.szExeFile);
        
        pe_size += sizeof(PROCENTRY);
        pe = xrealloc(pe, pe_size);
        i++;
        if (pe==NULL) {
          break;
        }            
      } while (Process32Next(hSnap, &pe32));
    }
    CloseHandle(hSnap);
  }
  return pe;
}
#endif
  
#ifdef TEST
// allocate memory
LPVOID xmalloc (SIZE_T dwSize) {
  return HeapAlloc (GetProcessHeap(), HEAP_ZERO_MEMORY, dwSize);
}

// re-allocate memory
LPVOID xrealloc (LPVOID lpMem, SIZE_T dwSize) {
  return HeapReAlloc (GetProcessHeap(), HEAP_ZERO_MEMORY, lpMem, dwSize);
}

// free memory
void xfree (LPVOID lpMem) {
  HeapFree (GetProcessHeap(), 0, lpMem);
}

wchar_t tolower_W(wchar_t c) {
  if (c >= L'A' && c <= L'Z') return c + L' ';
  return c;
}

// generate hash using prng
// flag indicates if converted to lowercase before 
// patentimages.storage.googleapis.com/pdfs/US8812570.pdf 
// https://www.virusbulletin.com/virusbulletin/2013/04/pushdo-s-new-second-generation

// Numerical Recipes: The Art of Scientific Computing
// published in 2007
/*
chapter 7

Knuth suggests a=1664525 as a suitable multiplier for this value of m. 
1,664,525 is an odd composite number composed of three prime numbers multiplied together.

(5 × 5 × 139 × 479) 
 
H.W. Lewis has conducted extensive tests of this value of a with c=1013904223
, which is a prime close to (√5−2)m
.  The resulting in-line generator (we will call it
ranqd1
) is simply
idum=1664525*idum+1013904223
This is about as good as any 32-bit linear congruential generator, entirely adequate for many
uses.   And, with only a single multiply and add, it is
very
fast.

knuth lewis rng
*/
DWORD fb_hash(PWCHAR str, int lwr)
{
  DWORD hash=0;
  WORD  c;
  int   i;
  
  if (str != NULL) {
    for (i=0; str[i] != 0; i++) {
      c = str[i];
      if (lwr) {
        c = tolower_W(c);
      }
      hash = 0x19660D * hash + 0x3C6EF35F + c;
    }
  }
  return hash;
}

int main(void)
{
  PPROCENTRY pe;  
  PPROCENTRY list = GetProcessList();
  
  //wprintf(L" %p ", fb_hash(L"iexplore.exe", TRUE));
  
  if (list==NULL) {
    wprintf (L"\nUnable to retrieve list of process");
    return 0;
  }
  wprintf (L"\nList of processes");
  wprintf (L"\n=================");
  for (pe=list; pe->id; pe++) {
    wprintf (L"\n%-30s - %i - %p", pe->name, pe->id, fb_hash(pe->name, TRUE));
  }
  xfree(list);  
  return 0;
}
#endif  