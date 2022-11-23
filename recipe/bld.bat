setlocal enabledelayedexpansion

set "STDLIB_DIR=%PREFIX%\Lib;%PREFIX%;%LIBRARY_BIN%"
%PYTHON% setup.py install --record=record.txt --skip-verstamp

:: setup.py spawns a background process to run a post-install script
:: (pywin32_postinstall.py). This may still be running once we get here.
:: Adding a timeout to wait for it to complete seems to be the only way
:: to semi-reliably get this to build.

:: If we proceed immediately without waiting, some DLLs may not be in
:: their expected locations yet, and the copys below will fail.
:: This issue is mentioned by conda-forge's pywin32-feedstock maintainers here:
:: https://github.com/conda-forge/pywin32-feedstock/pull/42#discussion_r745326106
:: Ray Donnelly's comment near the bottom of this file indicates he encountered
:: this back in 2017 as well.

:: Adding a timeout to wait for something that takes an indeterminate amount of
:: time to complete is not a good solution, but it will have to do for now.

timeout 15 > NUL

copy %PREFIX%\Lib\site-packages\pythonwin\*.pyd %PREFIX%\Lib\site-packages\win32
if errorlevel 1 exit /b 1
copy %PREFIX%\Lib\site-packages\pythonwin\*.dll %PREFIX%\Lib\site-packages\win32
if errorlevel 1 exit /b 1
copy %PREFIX%\Lib\site-packages\pythonwin\*.pyd %LIBRARY_BIN%\
if errorlevel 1 exit /b 1
copy %PREFIX%\Lib\site-packages\pythonwin\*.dll %LIBRARY_BIN%\
if errorlevel 1 exit /b 1

:: Fix for https://sourceforge.net/p/pywin32/mailman/message/29498528/
:: although on that bug report Glenn Linderman claims this fix does
:: not work, it seems to work fine. I attempted a fix in the source
:: code (and the upstream developers have clearly thought about it)
:: but the fact is win32api auto-imports pywintypes??.dll as can be
:: seen from:
:: ntldd.exe /c/aroot/stage/Lib/site-packages/win32/win32api.pyd
::         pywintypes36.dll => not found
:: due to: win32/src/PyWinTypes.h:
:: define PYWINTYPES_EXPORT __declspec(dllimport)
:: .. and ..
:: pragma comment(lib,"pywintypes.lib")
::  .. and then (at least): win32/src/win32apimodule.cpp
:: PYWINTYPES_EXPORT PyObject *PyWin_NewUnicode(PyObject *self, PyObject *args);
:: therefore copying is the only recourse. At first glance, it may
:: seem that moving these DLLs would work, but _win32sysloader.cpp
:: expects to find two DLLs in site-packages/pywin32_system32
:: My attempted fix is in import-pywintypes-from-win32api.patch
:: An actual fix would be to make win32api a Python module that
:: first imports pywintypes and after that imports _win32api.
copy %PREFIX%\Lib\site-packages\pywin32_system32\*.dll %PREFIX%\Lib\site-packages\win32\
if errorlevel 1 exit /b 1

:: I have no idea why sometimes, at random, these do not get copied. They are neccesary!
copy %PREFIX%\Lib\site-packages\pywin32_system32\*.dll %LIBRARY_BIN%\
if errorlevel 1 exit /b 1

copy %PREFIX%\Lib\site-packages\win32comext\axscript\axscript.pyd %LIBRARY_BIN%\
if errorlevel 1 exit /b 1

dir %LIBRARY_BIN%\
dir %PREFIX%\Lib\site-packages\win32\py*.dll

exit 0
