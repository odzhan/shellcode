@echo off
yasm -fwin32 x86.asm -ox86.obj
cl /DTEST /DASM getapi.c x86.obj
del *.obj