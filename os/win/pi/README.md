
## About ##

pi is intended for injecting *Position Independent Code* (PIC) into a Windows process space regardless of it being 32 or 64-bit.

If running in wow64 mode and target process is 64-bit, pi will transition to 64-bit mode in order to a create remote thread.

I wrote this specifically for testing win32 and win64 shellcode because while these codes can run fine by themselves, it's when you inject into another process space that reveals a lot of problems. 

## Building ##

This should compile without error using MSVC or MINGW.

* **MSVC**

	cl pi.c pslist.c

* **Mingw**
	
	gcc pi.c pslist.c -opi

## Usage ##

Currently, you can execute command in context of remote process, load a DLL or just run PIC.

![alt text](https://github.com/odzhan/shellcode/blob/master/win/ss/pi.png)

Simply supply a process name/process id along with PIC/DLL file or command line. Let's say we want to inject code into internet explorer.

## Supported Platforms ##

This has been tested successfully on x86 CPU running Windows NT 4.0 - Windows 10.
