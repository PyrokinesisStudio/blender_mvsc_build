@echo off

setlocal

set LIBDIR=%CD%\..
set LIBNAME=jpeg
set JPEG_VERSION=1.3.0
set "JPEG_SOURCE=http://sourceforge.net/projects/libjpeg-turbo/files/%JPEG_VERSION%/libjpeg-turbo-%JPEG_VERSION%.tar.gz/download"

set BUILD_TYPE=Release

call :CheckOS

call :CheckPath

call :CheckBuildSystem

call :CheckTargetArch

if not exist JPEG_%JPEG_VERSION_NODOTS% (
    echo getting source
    call :PrepareSource
)

call :Build

:: make sure we are in the right spot
cd %LIBDIR%\jpeg

:: FIXME this is result of static library name setting in cmake / scons
copy /y lib\jpeg-static.lib lib\libjpeg.lib

exit /b


:Build
cd libjpeg-turbo-%JPEG_VERSION%

:: create build directory
mkdir build\windows
cd build\windows

cmake -G "NMake Makefiles" ..\..\ ^
 -DCMAKE_INSTALL_PREFIX=%LIBDIR%\jpeg ^
 -DCMAKE_C_FLAGS_DEBUG="/D_DEBUG /MTd /Zi /Ob0 /Od /RTC1" ^
 -DCMAKE_C_FLAGS_MINSIZEREL="/MT /O1 /Ob1 /D NDEBUG" ^
 -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /Ob2 /D NDEBUG" ^
 -DCMAKE_C_FLAGS_RELWITHDEBINFO="/MT /Zi /O2 /Ob1 /D NDEBUG" ^
 -DWITH_JPEG8=ON ^
 -DCMAKE_BUILD_TYPE=Release

 nmake install
 
goto:eof 
 
 
:CheckTargetArch
cl 2>&1 | findstr /c:x64 >nul 2>&1
if errorlevel 1 (
    set targetarch=Win32
    echo target win32
) else (
    set targetarch=x64
    echo target x64
)

goto:eof
 
 
:PrepareSource

if not exist libjpeg-turbo-%JPEG_VERSION%.tar.gz (
    echo Downloading %LIBNAME% %JPEG_VERSION%
    curl -L "%JPEG_SOURCE%" -o libjpeg-turbo-%JPEG_VERSION%.tar.gz
)

if not exist libjpeg-turbo-%JPEG_VERSION% (
    echo Extraction source to libjpeg-turbo-%JPEG_VERSION%
    tar xf libjpeg-turbo-%JPEG_VERSION%.tar.gz
)
goto:eof

:CheckOS
IF EXIST "%PROGRAMFILES(X86)%" (set bit=x64) ELSE (set bit=x86)
goto:eof

:CheckPath
echo Checking for git in the path
diff >nul 2>&1
if errorlevel 9009 (
    echo diff is not in the current path, it needs to be 
    if %bit%==x64 ( set "PATH=%PATH%;%PROGRAMFILES(X86)%\Git\bin"
    ) else ( set "PATH=%PATH%;%PROGRAMFILES%\Git\bin" )
  
    diff >nul 2>&1
    if errorlevel 9009 (
    echo please install msys git
    exit /b
    )
) 
echo We got git/diff/patch etc
goto:eof

:CheckBuildSystem
msbuild >nul 2>&1
if errorlevel 9009 (
    echo "we need msbuild"
    exit /b
) 
goto:eof




