setlocal enabledelayedexpansion

set "STDLIB_DIR=%PREFIX%\Lib;%PREFIX%;%LIBRARY_BIN%"
%PYTHON% setup.py install --record=record.txt --skip-verstamp

:: setup.py spawns a background process to run the pywin32_postinstall.py script.
:: This may still be running once we get here.

:: If we immediately attempt to copy DLLs to their final destination, some
:: of them may not be in their expected locations yet, and our copys will fail.
:: This issue is mentioned by conda-forge's pywin32-feedstock maintainers here:
:: https://github.com/conda-forge/pywin32-feedstock/pull/42#discussion_r745326106
:: Ray Donnelly's comment near the bottom of this file indicates he encountered
:: this back in 2017 as well.

:: To address this issue, we will wait for the DLLs to appear before proceeding.

for /f "tokens=1,2 delims=. " %%a in ("%PY_VER%") do (
   set "PY_MAJOR=%%a"
   set "PY_MINOR=%%b"
)

set /a COUNTER=0
:WaitForPyWinTypesDLL
if exist %PREFIX%\Lib\site-packages\pywin32_system32\pywintypes%PY_MAJOR%%PY_MINOR%.dll goto FoundPyWinTypesDLL
echo Waiting for pywintypes DLL
set /a COUNTER=%COUNTER%+1
if %COUNTER%==120 exit 1
timeout /t 1 > NUL
goto WaitForPyWinTypesDLL
:FoundPyWinTypesDLL
echo Found pywintypes DLL

set /a COUNTER=0
:WaitForPythonCOMDLL
if exist %PREFIX%\Lib\site-packages\pywin32_system32\pythoncom%PY_MAJOR%%PY_MINOR%.dll goto FoundPythonCOMDLL
echo Waiting for pythoncom DLL
set /a COUNTER=%COUNTER%+1
if %COUNTER%==120 exit 1
ping 127.0.0.1 -n 1  1>NUL 
goto WaitForPythonCOMDLL
:FoundPythonCOMDLL
echo Found pythoncom DLL

:; The post-install script does other things in addition to copying DLLs.
:: This may not be necessary, but an extra timeout is added here to allow it finish.

ping 127.0.0.1 -n 10  1>NUL 

copy %PREFIX%\Lib\site-packages\pythonwin\*.pyd %PREFIX%\Lib\site-packages\win32
if errorlevel 1 exit /b 1
copy %PREFIX%\Lib\site-packages\pythonwin\*.dll %PREFIX%\Lib\site-packages\win32
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

:: The post install script had code that remove those files. See patch 0004.
copy %PREFIX%\Lib\site-packages\pywin32_system32\*.dll %LIBRARY_BIN%\
if errorlevel 1 exit /b 1

dir %LIBRARY_BIN%\
dir %PREFIX%\Lib\site-packages\win32\py*.dll

exit 0
