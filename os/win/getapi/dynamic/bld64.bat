@echo off
yasm -fwin64 x64.asm -ox64.obj
cl /DTEST /DASM getapi.c x64.obj
del *.obj