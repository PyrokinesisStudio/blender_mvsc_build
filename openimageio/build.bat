@Echo off
setlocal

set LIBDIR=%CD%\..
set LIBNAME=OpenImageIO
set OIIO_VERSION=1.3.9
set "OIIO_SOURCE=https://github.com/OpenImageIO/oiio/archive/Release-%OIIO_VERSION%.zip"

:: create build directory
echo Libdir set to: %LIBDIR%

set BUILD_TYPE=Release

call :CheckOS

call :CheckPath

call :CheckBuildSystem

call :CheckTargetArch

if not exist oiio-Release-%OIIO_VERSION% (
    echo getting source
    call :PrepareSource
)

call :Build

exit /b

:Build
cd %LIBDIR%\openimageio\oiio-Release-1.3.9
mkdir build\windows
cd build\windows

cmake -G "NMake Makefiles" ..\.. ^
 -DCMAKE_INSTALL_PREFIX=%LIBDIR%\openimageio ^
 -DCMAKE_CXX_FLAGS_DEBUG="/D_DEBUG /MTd /Zi /Ob0 /Od /RTC1" ^
 -DCMAKE_CXX_FLAGS_MINSIZEREL="/MT /O1 /Ob1 /D NDEBUG" ^
 -DCMAKE_CXX_FLAGS_RELEASE="/MT /O2 /Ob2 /D NDEBUG" ^
 -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="/MT /Zi /O2 /Ob1 /D NDEBUG" ^
 -DCMAKE_CXX_STANDARD_LIBRARIES:STRING="kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib psapi.lib" ^
 -DBUILDSTATIC=ON ^
 -DLINKSTATIC=ON ^
 -DBoost_COMPILER:STRING="-vc120" ^
 -DBoost_USE_MULTITHREADED=ON ^
 -DBoost_USE_STATIC_LIBS=ON ^
 -DBoost_USE_STATIC_RUNTIME=ON ^
 -DBOOST_ROOT=%LIBDIR%\boost ^
 -DILMBASE_INCLUDE_DIR=%LIBDIR%\openexr\include ^
 -DILMBASE_HALF_LIBRARIES=%LIBDIR%\openexr\lib\Half.lib ^
 -DILMBASE_IMATH_LIBRARIES=%LIBDIR%\openexr\lib\Imath-2_1.lib ^
 -DILMBASE_ILMTHREAD_LIBRARIES=%LIBDIR%\openexr\lib\IlmThread-2_1.lib ^
 -DILMBASE_IEX_LIBRARIES=%LIBDIR%\openexr\lib\Iex-2_1.lib ^
 -DOPENEXR_INCLUDE_DIR=%LIBDIR%\openexr\include ^
 -DOPENEXR_ILMIMF_LIBRARIES=%LIBDIR%\openexr\lib\IlmImf-2_1.lib ^
 -DZLIB_LIBRARY=%LIBDIR%\zlib\lib\libz_st.lib ^
 -DZLIB_INCLUDE_DIR=%LIBDIR%\zlib\include ^
 -DPNG_LIBRARY=%LIBDIR%\png\lib\libpng16.lib ^
 -DPNG_PNG_INCLUDE_DIR=%LIBDIR%\png\include ^
 -DOIIO_LIBRARY=%LIBDIR%\oiio\lib\liboiio.lib ^
 -DOIIO_INCLUDE_DIR=%LIBDIR%\oiio\include ^
 -DTIFF_LIBRARY=%LIBDIR%\tiff\lib\libtiff.lib ^
 -DTIFF_INCLUDE_DIR=%LIBDIR%\tiff\include ^
 -DJPEG_LIBRARY=%LIBDIR%\jpeg\lib\libjpeg.lib ^
 -DJPEG_INCLUDE_DIR=%LIBDIR%\jpeg\include ^
 -DOCIO_PATH=%LIBDIR%\opencolorio ^
 -DUSE_OPENGL=OFF ^
 -DUSE_TBB=OFF ^
 -DUSE_FIELD3D=OFF ^
 -DUSE_QT=OFF ^
 -DUSE_PYTHON=OFF ^
 -DOIIO_BUILD_TOOLS=OFF ^
 -DOIIO_BUILD_TESTS=OFF ^
 -DCMAKE_BUILD_TYPE=Release

nmake
nmake install

cd %RET_DIR%
exit /b

cd ../..

GOTO End_Debug



mkdir build/windows-dbg
cd build/windows-dbg

cmake -G "NMake Makefiles" ..\.. ^
 -DCMAKE_INSTALL_PREFIX=%LIBDIR%\openimageio ^
 -DCMAKE_CXX_FLAGS_DEBUG="/D_DEBUG /MTd /Zi /Ob0 /Od /RTC1" ^
 -DCMAKE_CXX_FLAGS_MINSIZEREL="/MT /O1 /Ob1 /D NDEBUG" ^
 -DCMAKE_CXX_FLAGS_RELEASE="/MT /O2 /Ob2 /D NDEBUG" ^
 -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="/MT /Zi /O2 /Ob1 /D NDEBUG" ^
 -DCMAKE_CXX_STANDARD_LIBRARIES:STRING="kernel32.lib user32.lib gdi32.lib winspool.lib shell32.lib ole32.lib oleaut32.lib uuid.lib comdlg32.lib advapi32.lib psapi.lib" ^
 -DBUILDSTATIC=ON ^
 -DLINKSTATIC=ON ^
 -DBoost_COMPILER:STRING="-vc" ^
 -DBoost_USE_MULTITHREADED=ON ^
 -DBoost_USE_STATIC_LIBS=ON ^
 -DBoost_USE_STATIC_RUNTIME=ON ^
 -DBOOST_ROOT=%LIBDIR%\boost ^
 -DILMBASE_INCLUDE_DIR=%LIBDIR%\openexr\include ^
 -DILMBASE_HALF_LIBRARIES=%LIBDIR%\openexr\lib\Half.lib ^
 -DILMBASE_IMATH_LIBRARIES=%LIBDIR%\openexr\lib\Imath-2_1.lib ^
 -DILMBASE_ILMTHREAD_LIBRARIES=%LIBDIR%\openexr\lib\IlmThread-2_1.lib ^
 -DILMBASE_IEX_LIBRARIES=%LIBDIR%\openexr\lib\Iex-2_1.lib ^
 -DOPENEXR_INCLUDE_DIR=%LIBDIR%\openexr\include ^
 -DOPENEXR_ILMIMF_LIBRARIES=%LIBDIR%\openexr\lib\IlmImf-2_1.lib ^
 -DZLIB_LIBRARY=%LIBDIR%\zlib\lib\libz_st.lib ^
 -DZLIB_INCLUDE_DIR=%LIBDIR%\zlib\include ^
 -DPNG_LIBRARY=%LIBDIR%\png\lib\libpng16.lib ^
 -DPNG_PNG_INCLUDE_DIR=%LIBDIR%\png\include ^
 -DOIIO_LIBRARY=%LIBDIR%\oiio\lib\liboiio.lib ^
 -DOIIO_INCLUDE_DIR=%LIBDIR%\oiio\include ^
 -DTIFF_LIBRARY=%LIBDIR%\tiff\lib\libtiff.lib ^
 -DTIFF_INCLUDE_DIR=%LIBDIR%\tiff\include ^
 -DJPEG_LIBRARY=%LIBDIR%\jpeg\lib\libjpeg.lib ^
 -DJPEG_INCLUDE_DIR=%LIBDIR%\jpeg\include ^
 -DUSE_OPENGL=OFF ^
 -DUSE_TBB=OFF ^
 -DUSE_FIELD3D=OFF ^
 -DUSE_QT=OFF ^
 -DUSE_PYTHON=OFF ^
 -DOIIO_BUILD_TOOLS=OFF ^
 -DOIIO_BUILD_TESTS=OFF ^
 -DCMAKE_DEBUG_POSTFIX:STRING="_d" ^
 -DCMAKE_BUILD_TYPE=Debug

nmake
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

if not exist oiio-Release-%OIIO_VERSION%.zip (
    echo Downloading %LIBNAME% %OIIO_VERSION%
    curl -L "%OIIO_SOURCE%" -o oiio-Release-%OIIO_VERSION%.zip
)

if not exist oiio-Release-%OIIO_VERSION% (
    echo Extraction source %LIBNAME% %OIIO_VERSION%
    unzip oiio-Release-%OIIO_VERSION%.zip
)

if not exitst oiio-Release-%OIIO_VERSION%\.patch_done (
    patch -i msvc_2013.patch
    echo 1 > oiio-Release-%OIIO_VERSION%\.patch_done
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

