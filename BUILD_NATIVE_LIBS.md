# Building Native Libraries with 16KB Page Size Support

This guide explains how to rebuild the PDFium native libraries with 16KB page size alignment to resolve Android 14+ compatibility issues.

## Prerequisites

1. **Android NDK 26.2.11379242 or later**
   - Download from: https://developer.android.com/ndk/downloads
   - Extract to a directory (e.g., `C:\android-ndk` or `/opt/android-ndk`)

2. **Set Environment Variables**
   - **Windows**: Set `ANDROID_NDK_HOME` or `NDK_HOME`
     ```cmd
     set ANDROID_NDK_HOME=C:\path\to\android-ndk
     ```
   - **Linux/Mac**: Set `ANDROID_NDK_HOME` or `NDK_HOME`
     ```bash
     export ANDROID_NDK_HOME=/path/to/android-ndk
     ```

## Quick Build (Recommended)

### Windows
```cmd
build_native_libs.bat
```

### Linux/Mac
```bash
chmod +x build_native_libs.sh
./build_native_libs.sh
```

## Manual Build Process

If the automated scripts don't work, you can build manually:

### 1. Clean Previous Builds
```bash
# Remove old libraries
rm -rf src/main/jni/lib/arm64-v8a/*.so
rm -rf src/main/jni/lib/armeabi-v7a/*.so
```

### 2. Build for Each Architecture

#### For arm64-v8a:
```bash
cd build_native
$ANDROID_NDK_HOME/ndk-build \
    -C ../src/main/jni \
    NDK_PROJECT_PATH=. \
    NDK_APPLICATION_MK=../src/main/jni/Application.mk \
    APP_BUILD_SCRIPT=../src/main/jni/Android.mk \
    APP_ABI=arm64-v8a \
    APP_PLATFORM=android-35 \
    V=1
```

#### For armeabi-v7a:
```bash
$ANDROID_NDK_HOME/ndk-build \
    -C ../src/main/jni \
    NDK_PROJECT_PATH=. \
    NDK_APPLICATION_MK=../src/main/jni/Application.mk \
    APP_BUILD_SCRIPT=../src/main/jni/Android.mk \
    APP_ABI=armeabi-v7a \
    APP_PLATFORM=android-35 \
    V=1
```

### 3. Copy Built Libraries
```bash
# Copy arm64-v8a libraries
cp libs/arm64-v8a/*.so ../src/main/jni/lib/arm64-v8a/

# Copy armeabi-v7a libraries  
cp libs/armeabi-v7a/*.so ../src/main/jni/lib/armeabi-v7a/
```

## Verification

After building, verify the libraries are 16KB aligned:

```bash
# Check alignment (requires readelf)
readelf -l src/main/jni/lib/arm64-v8a/libmodpdfium.so | grep LOAD
```

Look for `0x4000` in the output, which indicates 16KB alignment.

## Troubleshooting

### Common Issues

1. **NDK not found**
   - Ensure `ANDROID_NDK_HOME` is set correctly
   - Verify the NDK path exists

2. **Build fails with "page size" error**
   - Ensure you're using NDK 26.2.11379242 or later
   - Check that `Application.mk` has the correct flags

3. **Libraries still not 16KB aligned**
   - Verify the linker flags in `Application.mk`
   - Ensure you're building with the correct NDK version

### Build Flags Explanation

The key flags in `Application.mk` for 16KB alignment:

- `APP_PLATFORM = android-35` - Target Android API 35
- `APP_LDFLAGS += -Wl,-z,page-size=16384` - Set 16KB page size
- `APP_CFLAGS += -DSUPPORT_16KB_PAGES` - Enable 16KB page support
- `APP_ABI := arm64-v8a armeabi-v7a` - Only build modern architectures

## After Building

1. **Test your app** to ensure the new libraries work correctly
2. **Check lint warnings** - The 16KB alignment warning should be resolved
3. **Commit the changes** - Include the updated `.so` files in your repository

## Notes

- Only `arm64-v8a` and `armeabi-v7a` are built (modern architectures)
- `x86` and `x86_64` are excluded as they're not commonly used in production
- The build process may take several minutes depending on your system
- Ensure you have sufficient disk space for the build process

## Support

If you encounter issues:
1. Check the build logs for specific error messages
2. Verify your NDK installation and environment variables
3. Ensure you have the latest NDK version
4. Check that all source files are present in `src/main/jni/`
