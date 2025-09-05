@echo off
REM Build script for rebuilding native libraries with 16KB alignment
REM This script rebuilds the PDFium native libraries with proper 16KB page size support

echo === Building PDFium Android with 16KB Page Size Support ===

REM Check if NDK is available
if "%ANDROID_NDK_HOME%"=="" if "%NDK_HOME%"=="" (
    echo Error: ANDROID_NDK_HOME or NDK_HOME environment variable not set
    echo Please set one of these to your Android NDK installation path
    echo Example: set ANDROID_NDK_HOME=C:\path\to\android-ndk
    pause
    exit /b 1
)

REM Use ANDROID_NDK_HOME if available, otherwise NDK_HOME
if not "%ANDROID_NDK_HOME%"=="" (
    set NDK_PATH=%ANDROID_NDK_HOME%
) else (
    set NDK_PATH=%NDK_HOME%
)

echo Using NDK at: %NDK_PATH%

REM Check if NDK exists
if not exist "%NDK_PATH%" (
    echo Error: NDK directory not found at %NDK_PATH%
    pause
    exit /b 1
)

REM Set up paths
set PROJECT_ROOT=%CD%
set JNI_DIR=%PROJECT_ROOT%\src\main\jni
set BUILD_DIR=%PROJECT_ROOT%\build_native
set OUTPUT_DIR=%JNI_DIR%\lib

echo Project root: %PROJECT_ROOT%
echo JNI directory: %JNI_DIR%
echo Build directory: %BUILD_DIR%
echo Output directory: %OUTPUT_DIR%

REM Create build directory
if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
cd /d "%BUILD_DIR%"

REM Clean previous builds
echo Cleaning previous builds...
if exist "libs" rmdir /s /q "libs"
if exist "obj" rmdir /s /q "obj"

REM Build for each architecture
echo.
echo === Building for arm64-v8a ===
cd /d "%JNI_DIR%"
"%NDK_PATH%\ndk-build.cmd" NDK_PROJECT_PATH="%BUILD_DIR%" NDK_APPLICATION_MK="Application.mk" APP_BUILD_SCRIPT="Android.mk" APP_ABI="arm64-v8a" APP_PLATFORM=android-35 V=1

if %ERRORLEVEL% neq 0 (
    echo Build failed for arm64-v8a
    pause
    exit /b 1
)

echo Build successful for arm64-v8a
if not exist "%OUTPUT_DIR%\arm64-v8a" mkdir "%OUTPUT_DIR%\arm64-v8a"
copy "%BUILD_DIR%\libs\arm64-v8a\*.so" "%OUTPUT_DIR%\arm64-v8a\"
echo Copied libraries to %OUTPUT_DIR%\arm64-v8a\

echo.
echo === Building for armeabi-v7a ===
"%NDK_PATH%\ndk-build.cmd" NDK_PROJECT_PATH="%BUILD_DIR%" NDK_APPLICATION_MK="Application.mk" APP_BUILD_SCRIPT="Android.mk" APP_ABI="armeabi-v7a" APP_PLATFORM=android-35 V=1

if %ERRORLEVEL% neq 0 (
    echo Build failed for armeabi-v7a
    pause
    exit /b 1
)

echo Build successful for armeabi-v7a
if not exist "%OUTPUT_DIR%\armeabi-v7a" mkdir "%OUTPUT_DIR%\armeabi-v7a"
copy "%BUILD_DIR%\libs\armeabi-v7a\*.so" "%OUTPUT_DIR%\armeabi-v7a\"
echo Copied libraries to %OUTPUT_DIR%\armeabi-v7a\

echo.
echo === Build Complete ===
echo Native libraries have been rebuilt with 16KB page size support
echo Output directory: %OUTPUT_DIR%
echo.
echo Next steps:
echo 1. Test your app to ensure the new libraries work correctly
echo 2. The 16KB alignment lint warning should now be resolved
echo 3. Commit the updated .so files to your repository
pause
