@echo off
yasm -fbin -DBIN asm\ExecPIC.asm -o ExecPIC.bin
yasm -fbin -DBIN asm\LoadDLLPIC.asm -o LoadDLLPIC.bin
yasm -fbin -DBIN asm\CreateThreadPIC.asm -o CreateThreadPIC.bin
dist -b64 -fc ExecPIC.bin >winexec.h
dist -b64 -fc LoadDLLPIC.bin >loadlib.h
dist -b64 -fc CreateThreadPIC.bin >createthread.h
cl /nologo /c pi.c pslist.c
link /nologo /subsystem:console pi.obj pslist.obj /out:pi32.exe
del *.obj