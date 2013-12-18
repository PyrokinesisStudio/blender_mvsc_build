@echo off

set LIBDIR=%CD%\..

set BOOST_VERSION=1.55.0
set BOOST_VERSION_NODOTS=1_55_0
set BOOST_SOURCE="http://sourceforge.net/projects/boost/files/boost/%BOOST_VERSION%/boost_%BOOST_VERSION_NODOTS%.tar.bz2/download"

call :CheckOS

call :CheckPath

if not exist boost_%BOOST_VERSION_NODOTS% (
    echo getting source
    call :PrepareSource
)

call :Build

cd %LIBDIR%\boost

exit /b


:Build
cd boost_1_55_0

:: build
call bootstrap.bat
bjam -j4 architecture=x86 ^
 address-model=64 ^
 variant=release ^
 link=static ^
 runtime-link=static ^
 threading=multi ^
 --with-filesystem ^
 --with-locale ^
 --with-thread ^
 --with-regex ^
 --with-system ^
 --with-date_time ^
 --with-wave ^
 --prefix=%LIBDIR%\boost ^
 install
 
goto:eof 
 
:Build_DEBUG
IF DEFINED BUILD_DEBUG {
bjam -j4 architecture=x86 ^
 address-model=64 ^
 variant=debug ^
 link=static ^
 runtime-link=static ^
 threading=multi ^
 --with-filesystem ^
 --with-locale ^
 --with-thread ^
 --with-regex ^
 --with-system ^
 --with-date_time ^
 --with-wave ^
 --prefix=%LIBDIR%\boost ^
 install
)

:: copy files
:: mkdir ..\lib
:: mkdir ..\include\boost
:: xcopy /E /Y stage\lib  ..\lib
:: xcopy /E /Y boost ..\include\boost



:PrepareSource

if not exist boost_%BOOST_VERSION_NODOTS%.tar.bz2 (
    echo Downloading BOOST %BOOST_VERSION%
    curl -L %BOOST_SOURCE% -o boost_%BOOST_VERSION_NODOTS%.tar.bz2
)

if not exist boost_%BOOST_VERSION_NODOTS% (
    echo Extraction source to boost_%BOOST_VERSION_NODOTS%
    tar xf boost_%BOOST_VERSION_NODOTS%.tar.bz2
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