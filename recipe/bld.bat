@echo on

set "STDLIB_DIR=%PREFIX%\Lib;%PREFIX%;%LIBRARY_BIN%"
%PYTHON% -m pip install --no-deps --no-build-isolation . -vv
if %ERRORLEVEL% neq 0 exit 1
echo "sleeping for 15"
%PYTHON% -c "import time; time.sleep(15)"
if %ERRORLEVEL% neq 0 exit 1
echo "Copying over stray DLLS"
if %ERRORLEVEL% neq 0 exit 1

:: Copy files from pythonwin to win32 directory
copy %PREFIX%\Lib\site-packages\pythonwin\*.pyd %PREFIX%\Lib\site-packages\win32
if errorlevel 1 exit /b 1
copy %PREFIX%\Lib\site-packages\pythonwin\*.dll %PREFIX%\Lib\site-packages\win32
if errorlevel 1 exit /b 1
copy %PREFIX%\Lib\site-packages\pythonwin\*.dll %LIBRARY_BIN%\
if errorlevel 1 exit /b 1

:: Create Library\bin directory and copy DLLs
mkdir %PREFIX%\Library\bin
copy %PREFIX%\Lib\site-packages\win32\*.dll %PREFIX%\Library\bin\
if errorlevel 1 exit /b 1

dir %PREFIX%\Lib\site-packages\win32\py*.dll
copy %PREFIX%\Lib\site-packages\pywin32_system32\*.dll %PREFIX%\Lib\site-packages\win32\
dir %PREFIX%\Lib\site-packages\win32\py*.dll
if %ERRORLEVEL% neq 0 exit 1

dir %LIBRARY_BIN%\py*.dll
copy %PREFIX%\Lib\site-packages\pywin32_system32\*.dll %LIBRARY_BIN%\
if %ERRORLEVEL% neq 0 exit 1

dir %LIBRARY_BIN%\py*.dll
if %ERRORLEVEL% neq 0 exit 1