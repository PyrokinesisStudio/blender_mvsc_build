@echo off

setlocal

set LIBDIR=%CD%\..

set SDL_VERSION=1.2.15
set "SDL_SOURCE=http://www.libSDL.org/release/SDL-%SDL_VERSION%.zip"

set BUILD_TYPE=Release

call :CheckOS

call :CheckPath

call :CheckBuildSystem

call :CheckTargetArch

if not exist SDL_%SDL_VERSION_NODOTS% (
    echo getting source
    call :PrepareSource
)

call :Build

:: make sure we are in the right spot
cd %LIBDIR%\sdl

:: copy include in place
mkdir include
xcopy /y SDL-%SDL_VERSION%\include\* include\

:: copy libs in place
mkdir lib
xcopy /y SDL-%SDL_VERSION%\VisualC\SDL\Release\SDL.dll lib\
if %targetarch%==x64 (
xcopy /y SDL-%SDL_VERSION%\VisualC\SDL\%targetarch%\Release\SDL.lib lib\
xcopy /y SDL-%SDL_VERSION%\VisualC\SDL\%targetarch%\Release\SDL.exp lib\
) else (
xcopy /y SDL-%SDL_VERSION%\VisualC\SDL\Release\SDL.lib lib
xcopy /y SDL-%SDL_VERSION%\VisualC\SDL\Release\SDL.exp lib
)




exit /b


:Build
cd SDL-%SDL_VERSION%

if not exist VisualC\SDL\SDL.vcxproj (
vcupgrade VisualC\SDL\SDL.vcproj
)

if not exist VisualC\SDLmain\SDLmain.vcxproj (
vcupgrade VisualC\SDLmain\SDLmain.vcproj
)

sed -i 's/MultiThreadedDLL/MultiThreaded/g' VisualC\SDL\SDL.vcxproj
sed -i 's/MultiThreadedDLL/MultiThreaded/g' VisualC\SDLmain\SDLmain.vcxproj

sed -i 's/DynamicLibrary/StaticLibrary/g' VisualC\SDL\SDL.vcxproj
sed -i 's/DynamicLibrary/StaticLibrary/g' VisualC\SDLmain\SDLmain.vcxproj

sed -i '/windx5/d' VisualC\SDL\SDL.vcxproj
sed -i '/Windx5/d' VisualC\SDL\SDL.vcxproj

sed -i '/SDL_AUDIO_DRIVER_DSOUND/d' include/SDL_config_win32.h
sed -i '/SDL_VIDEO_DRIVER_DDRAW/d' include/SDL_config_win32.h

msbuild VisualC\SDL\SDL.vcxproj /p:Configuration=Release /p:Platform=%targetarch% /t:rebuild
msbuild VisualC\SDLmain\SDLmain.vcxproj /p:Configuration=Release /p:Platform=%targetarch% /t:rebuild

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

if not exist SDL-%SDL_VERSION%.zip (
    echo Downloading SDL %SDL_VERSION%
    curl -L "%SDL_SOURCE%" -o SDL-%SDL_VERSION%.zip
)

if not exist SDL-%SDL_VERSION% (
    echo Extraction source to SDL-%SDL_VERSION%
    unzip SDL-%SDL_VERSION%.zip
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