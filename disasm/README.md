## About ##

**disasm** is a simple tool for creating C strings from shellcodes stored in binary format. It uses the [Capstone disassembler engine](http://www.capstone-engine.org/) which supports up to 8 CPU architectures.

Although Capstone supports multiple CPU architectures, only **SPARC**, **MIPS**, **ARM**, **POWERPC** and **X86** have been tested.

## Installing capstone ##

Unless already installed, you'll first need to clone capstone, build and install.
disasm uses the latest source from repository so if you've installed using a package manager or from ports, it may be outdated. 

	git clone https://github.com/aquynh/capstone

**32-bit MSVC**

    cd capstone
    cd msvc
    msbuild /p:Configuration=Release

There's already prebuilt library in **disasm\capstone** folder

**NIX**
 
    ./make.sh
    ./make.sh install

## Compiling ##

**MSVC**

    cl disasm.c -I.
    
## usage ##

![alt text](https://github.com/odzhan/shellcode/blob/master/disasm/img/disasm.png)
    
## Examples ##

**PowerPC 32-bit Big Endian**

    disasm bin\sc_2.bin -appc -ebe

![alt text](https://github.com/odzhan/shellcode/blob/master/disasm/img/ppc32_be.png)

**MIPS 32-bit Little Endian**

	disasm bin\sc_4.bin -amips -ele

![alt text](https://github.com/odzhan/shellcode/blob/master/disasm/img/mips32_le.png)

**X86 32-bit** 

	disasm bin\w32.bin

![alt text](https://github.com/odzhan/shellcode/blob/master/disasm/img/x86_32.png)

**X86 64-bit using AT&T Syntax**

	disasm bin\w64.bin -satt

![alt text](https://github.com/odzhan/shellcode/blob/master/disasm/img/x86_64_att.png)

**SPARC**

	disasm bin\sc_9 -asparc

![alt text](https://github.com/odzhan/shellcode/blob/master/disasm/img/sparc.png)
