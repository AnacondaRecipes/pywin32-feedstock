setlocal enabledelayedexpansion

:: Create version file in the expected location
echo %VERSION% > "%TEMP%\pywin32.version.txt"

set "STDLIB_DIR=%PREFIX%\Lib;%PREFIX%;%LIBRARY_BIN%"
%PYTHON% setup.py install --record=record.txt

:: Create necessary directories first
mkdir %PREFIX%\Lib\site-packages\win32 2>nul
mkdir %PREFIX%\Library\bin 2>nul

:: Copy files with error checking
if exist %PREFIX%\Lib\site-packages\pythonwin\*.pyd (
    copy %PREFIX%\Lib\site-packages\pythonwin\*.pyd %PREFIX%\Lib\site-packages\win32
    if errorlevel 1 exit /b 1
)

if exist %PREFIX%\Lib\site-packages\pythonwin\*.dll (
    copy %PREFIX%\Lib\site-packages\pythonwin\*.dll %PREFIX%\Lib\site-packages\win32
    if errorlevel 1 exit /b 1
    copy %PREFIX%\Lib\site-packages\pythonwin\*.dll %LIBRARY_BIN%\
    if errorlevel 1 exit /b 1
)

if exist %PREFIX%\Lib\site-packages\win32\*.dll (
    copy %PREFIX%\Lib\site-packages\win32\*.dll %PREFIX%\Library\bin\
    if errorlevel 1 exit /b 1
)

:: Copy system DLLs with error checking
if exist %PREFIX%\Lib\site-packages\pywin32_system32\*.dll (
    copy %PREFIX%\Lib\site-packages\pywin32_system32\*.dll %PREFIX%\Lib\site-packages\win32\
    if errorlevel 1 exit /b 1
    copy %PREFIX%\Lib\site-packages\pywin32_system32\*.dll %LIBRARY_BIN%\
    if errorlevel 1 exit /b 1
)

echo "Contents of Library\bin:"
dir /b %PREFIX%\Library\bin\*.dll 2>nul
echo "Contents of site-packages\win32:"
dir /b %PREFIX%\Lib\site-packages\win32\*.dll 2>nul

exit /b 0