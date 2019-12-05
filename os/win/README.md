
## About ##

These are a collection of *Position-Independent Code* (PIC) that were tested on Windows NT released in 1996 up to Windows 10 released in 2015.

## Multimode codes ##

* **bind**

Bind to network address and port using **bind()** API. Upon incoming connection, spawn cmd prompt for remote user to interact with. 

* **connect**

Connect to a remote network address and port using **connect()** API. Upon connection, spawn cmd prompt for remote user to interact with.

# Files

* **getapi.c**

Obtains a list of DLLs (Dynamic Link Library) from the Process Environment Block (PEB) and attempts to search either the export or import directories for API based on hash.

* **x86.asm**

x86 assembly code to search PEB, import and export directories for API to link with getapi.c

* **x64.asm**

x64 assembly code to search PEB, import and export directories for API to link with getapi.c

* **x84.asm**

Multimode assembly which can run in either x86 or x64 mode to search PEB and export directories for API to link with getapi.c 

Currently, searching import directory is not implemented. 

* **reverse.asm**

Demonstrates multimode assembly to perform an outbound connection to remote host before executing cmd.exe for user interaction.

* **bind.asm**

Demonstrates multimode assembly to accept an inbound connection from remote host before executing cmd.exe for user interaction.

## Building ##

In the getapi folder is source code in C containing functions to search the import and export directories of a Portable Executable to resolve API addresses.

By default, getapi.c will search the export table but if you compile with IMPORT defined, getapi will search import tables instead.

To test out out, compile getapi.c using mingw or msvc

	gcc -DTEST getapi.c -ogetapi
    cl /DTEST getapi.c
 	
To use the multimode assembly that will run with either x86 or x86-64 mode, use YASM or NASM.
	
* **32-bit PE**

	<pre>yasm -fwin32 x84.asm -ox84.obj 
	cl /DTEST /DASM getapi.c x84.obj</pre> 

* **64-bit PE+**
 
	<pre>yasm -fwin64 x84.asm -ox84.obj
	cl /DTEST /DASM getapi.c x84.obj</pre>

## Testing getapi ##

After you've compiled EXE, simply provide the name of a DLL which exports API you need address for and the API name itself. 

getapi function will attempt to find the address of API based on CRC-32C hash.

	usage: getapi <DLL> <API>

The following screenshots are the bind shell running inside notepad launched from pi (Process Injector)

## Testing bind ##

For this, you need to use the process injector included or some other tool capable of the same.

For example, the following will inject bind.bin into 64-bit process of Internet Explorer.

	pi -fbind.bin iexplore.exe -x32

If successfully executed, cmd.exe will execute once you connect to the host on port 1234 using netcat, ncat or something similar.

	ncat -v4 localhost 1234

The following are screenshots of some legacy systems running the bind assembly code. 

## Windows NT ##

![alt text](https://github.com/odzhan/shellcode/blob/master/win/ss/winnt.png)

## Windows 2000 ##

![alt text](https://github.com/odzhan/shellcode/blob/master/win/ss/win2k.png)

## Windows XP ##

![alt text](https://github.com/odzhan/shellcode/blob/master/win/ss/winxp.png)
