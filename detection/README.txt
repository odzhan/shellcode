

                          CPU signatures for OS identification
                          ------------------------------------
                          
[ intro

  A function like this could be useful for many purposes but admittedly, 
  the motivation for me was in writing a piece of code that could execute 
  a command across many different operating systems running on x86 CPUs. 

  Initially, the checks were based on differences in stack pointer, 
  segment registers, REX prefixes (to identify CPU mode) and system calls. 

  After testing many systems, there were too many variables involved to 
  accurately identify OS based on IF/ELSE statements so a CRC32 hash
  of the context returned is generated and this forms the basis of 
  identification.

  Since most 32-bit based systems for Windows all seem to use the same
  values for segment registers (with exception to Windows 2000/NT) we
  pull version information from the process environment block.

  Although the version info isn't used in generation of signatures, it
  might be useful for others to know where it resides, see rewolf.pl [1]


[ example output

  OS       : Windows 7 64-bit PE32 (CRC32 : 0x53BD86D5)
  Win Ver  : 6.1.7601

  Binary   : 32-bit
  Segments : cs=0x23 ds=0x2B es=0x2B
  Segments : fs=0x53 gs=0x2B ss=0x2B

  Stack Ptr: 0x0028FEB4
  Syscall E: 0x00000000
  Segments : 0x01999998

I wasn't aware that Windows NT4 had a PEB, but the code executes fine
while obtaining the operating system version info. The problem is compiling
an executable. You require an older compiler pre-2003 or a version of mingw.

  OS       : Windows NT/2000 (CRC32 : 0x1CC39FA2)
  Win Ver  : 4.0.1381

  Binary   : 32-bit
  Segments : cs=0x1B ds=0x23 es=0x23
  Segments : fs=0x38 gs=0x00 ss=0x23

  Stack Ptr: 0x0022FEE4
  Syscall E: 0x00000000
  Segments : 0x01999818
  
  
[ ref

[1] Evolution of Process Environment Block (PEB)
  http://blog.rewolf.pl/blog/?p=573

  
[ credits/thanks

Thanks to 0x4d for testing and providing results of some other OS
