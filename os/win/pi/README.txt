

                pi (Process Injector) v0.2
                ==========================

[ intro

  pi is another process injection tool for windows operating systems. 
  It's intended for injecting PIC (Position Independent Code) into 
  any process regardless of it being 32 or 64-bit.

  If running in wow64 mode and target process is 64-bit, pi will 
  transition to 64-bit mode in order to create remote thread.

  I wrote this specifically for testing win32 and win64 shellcode because 
  while these codes can run fine by themselves, it's when you inject
  into another process space that reveals lots of problems. 

[ usage

  Currently, you can execute command in context of remote process, load
  a DLL or just run PIC (Position Independent Code).

  *********************************************************
  [ PIC/DLL injector v0.2
  [ Copyright (c) 2014-2017 Odzhan

  [ no target process specified

  usage: pi [options] <proc name | proc id>

       -d          Wait after memory allocation before running thread
       -e <cmd>    Execute command in context of remote process (shows window)
       -f <file>   Load a PIC file into remote process
       -l <dll>    Load a DLL file into remote process
       -p          List available processes on system
       -x <cpu>    Exclude process running in cpu mode, 32 or 64

 examples:

    pi -e "cmd /c echo this is a test > test.txt & notepad test.txt" -x32 iexplore.exe
    pi -l ws2_32.dll notepad.exe
    pi -f reverse_shell.bin chrome.exe
    
  *********************************************************
  Simply supply a process name/process id along with PIC/DLL file 
  or command line. Let's say we want to inject code into internet 
  explorer.

  You can pass iexplore.exe with a PIC file "exports.bin"
  
  *********************************************************
  [ PIC/DLL injector v0.2
  [ Copyright (c) 2014-2017 Odzhan
  
  [ warning: process requires admin privileges for some process

  [ opening exports.bin
  [ getting size
  [ allocating 221 bytes of memory for file
  [ reading
  [ opening process id 1696
  [ allocating 221 bytes of RW memory in process
  [ writing 221 bytes of code to 0x03C90000
  [ changing memory attributes to RX
  [ remote process is 64-bit
  [ attach debugger now or set breakpoint on 03C90000
  [ press any key to continue . . .
  
  *********************************************************
  Since testing code can corrupt a process, I normally attach debugger 
  here before continuing but it would be nice to have some kind of
  debugger support.

  pi will wait for thread to terminate but if for any reason the 
  remote process causes exception and dies, pi has no idea what 
  happened.


[ compiling

  You don't need to assemble the asmcodes unless you've made changes 
  yourself. If that's the case, yasm is required but not included.
  
  To assemble files, have a look at b32.bat
  
    yasm -fbin -DBIN <asmfile>.asm -o <asmfile>.bin
    
  Microsoft Visual Studio
    
    cl pi.c
    
[ wow64

  Various ways to detect Wow64 mode have surfaced over the years and most 
  simple ones exploit REX prefixes. Many 32-bit op-codes with REX prefixes 
  can either increment or decrement a register. So for example, I'm 
  setting eax register to zero and decreasing by 1. This will execute if 
  32-bit mode but on 64-bit will be ignored. The negate operation will 
  change -1 to 1 or leave 0 as is. TRUE or FALSE.


  ; returns TRUE or FALSE
isWow64:
_isWow64:
    bits   32
    xor    eax, eax
    dec    eax
    neg    eax
    ret
    
    
[ Switching to x64 mode

  We can switch code selectors in order to jump into 64-bit mode.
  This happens in Wow64 applications already when emulator
  needs to execute some 64-bit code.

  bits 32
  ; switch to x64 mode
sw64:
    call   isWow64
    jz     ext64                 ; we're already x64
    pop    eax                   ; get return address
    push   33h                   ; x64 selector
    push   eax                   ; return address
    retf                         ; go to x64 mode
ext64:
    ret
    
    
[ Switching back to x86 mode

Again, we're simply emulating the existing code inside wow64
host process.

  ; switch to x86 mode
sw32:
    call   isWow64
    jnz    ext32                 ; we're already x86
    pop    eax
    sub    esp, 8
    mov    dword[esp], eax
    mov    dword[esp+4], 23h     ; x86 selector
    retf
ext32:
    ret
    
[ Further reading

Some of you may be looking for a library to perform all this.
I would suggest ReWolfs library as best solution.

https://github.com/rwfpl/rewolf-wow64ext

[ ref

[1] A small, null-free Windows shellcode that executes calc.exe (x86/x64, all OS/SPs) 
  https://github.com/peterferrie/win-exec-calc-shellcode
