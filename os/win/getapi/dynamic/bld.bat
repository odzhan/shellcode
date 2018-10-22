@echo off
echo:
if '%1'=='' goto usage
if NOT '%1'=='win32' ( if NOT '%1'=='win64' goto usage )
yasm -f%1 x84.asm -ox84.obj
cl /nologo /DTEST /DASM getapi.c x84.obj
del *.obj
goto end
:usage
echo Usage: BLD [architecture]
echo        The architecture can be win32 or win64
echo:
echo Example: BLD win32         (create win32 binary)
echo          BLD win64         (create win64 binary)

:end
echo: