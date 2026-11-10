@echo on

set "STDLIB_DIR=%PREFIX%\Lib;%PREFIX%;%LIBRARY_BIN%"
%PYTHON% -m pip install --no-deps --no-build-isolation . -vv
if %ERRORLEVEL% neq 0 exit 1
echo "sleeping for 15"
%PYTHON% -c "import time; time.sleep(15)"
if %ERRORLEVEL% neq 0 exit 1
echo "Copying over stray DLLS"
if %ERRORLEVEL% neq 0 exit 1

:: Locate the installed pythonwin package instead of hardcoding Lib\site-packages:
:: the Python 3.15 package on Windows uses a POSIX-style lib\python\site-packages.
set "SP=%PREFIX%\Lib\site-packages"
if not exist "%SP%\pythonwin" set "SP=%PREFIX%\lib\python\site-packages"
if not exist "%SP%\pythonwin" exit /b 1

:: Copy files from pythonwin to win32 directory
copy %SP%\pythonwin\*.pyd %SP%\win32
if errorlevel 1 exit /b 1
copy %SP%\pythonwin\*.dll %SP%\win32
if errorlevel 1 exit /b 1
copy %SP%\pythonwin\*.dll %LIBRARY_BIN%\
if errorlevel 1 exit /b 1

:: Create Library\bin directory and copy DLLs
mkdir %PREFIX%\Library\bin
copy %SP%\win32\*.dll %PREFIX%\Library\bin\
if errorlevel 1 exit /b 1

dir %SP%\win32\py*.dll
copy %SP%\pywin32_system32\*.dll %SP%\win32\
dir %SP%\win32\py*.dll
if %ERRORLEVEL% neq 0 exit 1

dir %LIBRARY_BIN%\py*.dll
copy %SP%\pywin32_system32\*.dll %LIBRARY_BIN%\
if %ERRORLEVEL% neq 0 exit 1

dir %LIBRARY_BIN%\py*.dll
if %ERRORLEVEL% neq 0 exit 1