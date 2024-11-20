setlocal enabledelayedexpansion

set "STDLIB_DIR=%PREFIX%\Lib;%PREFIX%;%LIBRARY_BIN%"
%PYTHON% setup.py install --record=record.txt

copy %PREFIX%\Lib\site-packages\pythonwin\*.pyd %PREFIX%\Lib\site-packages\win32
if errorlevel 1 exit /b 1
copy %PREFIX%\Lib\site-packages\pythonwin\*.dll %PREFIX%\Lib\site-packages\win32
if errorlevel 1 exit /b 1
copy %PREFIX%\Lib\site-packages\pythonwin\*.dll %LIBRARY_BIN%\
if errorlevel 1 exit /b 1

mkdir %PREFIX%\Library\bin
copy %PREFIX%\Lib\site-packages\win32\*.dll %PREFIX%\Library\bin\
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

:: The post install script had code that remove those files. See patch 0004.
copy %PREFIX%\Lib\site-packages\pywin32_system32\*.dll %LIBRARY_BIN%\
if errorlevel 1 exit /b 1

dir %LIBRARY_BIN%\
dir %PREFIX%\Lib\site-packages\win32\py*.dll

exit 0