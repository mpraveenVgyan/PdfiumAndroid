#!/bin/bash

# Build script for rebuilding native libraries with 16KB alignment
# This script rebuilds the PDFium native libraries with proper 16KB page size support

set -e  # Exit on any error

echo "=== Building PDFium Android with 16KB Page Size Support ==="

# Check if NDK is available
if [ -z "$ANDROID_NDK_HOME" ] && [ -z "$NDK_HOME" ]; then
    echo "Error: ANDROID_NDK_HOME or NDK_HOME environment variable not set"
    echo "Please set one of these to your Android NDK installation path"
    echo "Example: export ANDROID_NDK_HOME=/path/to/android-ndk"
    exit 1
fi

# Use ANDROID_NDK_HOME if available, otherwise NDK_HOME
NDK_PATH=${ANDROID_NDK_HOME:-$NDK_HOME}
echo "Using NDK at: $NDK_PATH"

# Check if NDK exists
if [ ! -d "$NDK_PATH" ]; then
    echo "Error: NDK directory not found at $NDK_PATH"
    exit 1
fi

# Set up paths
PROJECT_ROOT=$(pwd)
JNI_DIR="$PROJECT_ROOT/src/main/jni"
BUILD_DIR="$PROJECT_ROOT/build_native"
OUTPUT_DIR="$JNI_DIR/lib"

echo "Project root: $PROJECT_ROOT"
echo "JNI directory: $JNI_DIR"
echo "Build directory: $BUILD_DIR"
echo "Output directory: $OUTPUT_DIR"

# Create build directory
mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf libs obj

# Build for each architecture
ARCHITECTURES=("arm64-v8a" "armeabi-v7a")

for ARCH in "${ARCHITECTURES[@]}"; do
    echo ""
    echo "=== Building for $ARCH ==="
    
    # Run ndk-build
    "$NDK_PATH/ndk-build" \
        -C "$JNI_DIR" \
        NDK_PROJECT_PATH="$BUILD_DIR" \
        NDK_APPLICATION_MK="$JNI_DIR/Application.mk" \
        APP_BUILD_SCRIPT="$JNI_DIR/Android.mk" \
        APP_ABI="$ARCH" \
        APP_PLATFORM=android-35 \
        V=1
    
    # Check if build was successful
    if [ $? -eq 0 ]; then
        echo "Build successful for $ARCH"
        
        # Copy the built libraries to the output directory
        mkdir -p "$OUTPUT_DIR/$ARCH"
        cp -f "$BUILD_DIR/libs/$ARCH"/*.so "$OUTPUT_DIR/$ARCH/"
        echo "Copied libraries to $OUTPUT_DIR/$ARCH/"
        
        # Verify 16KB alignment
        echo "Verifying 16KB alignment for $ARCH:"
        for so_file in "$OUTPUT_DIR/$ARCH"/*.so; do
            if [ -f "$so_file" ]; then
                filename=$(basename "$so_file")
                # Check if the file is 16KB aligned
                if command -v readelf >/dev/null 2>&1; then
                    page_size=$(readelf -l "$so_file" | grep LOAD | head -1 | awk '{print $6}')
                    if [ "$page_size" = "0x4000" ]; then
                        echo "  ✓ $filename is 16KB aligned"
                    else
                        echo "  ✗ $filename is NOT 16KB aligned (page size: $page_size)"
                    fi
                else
                    echo "  ? $filename (readelf not available for verification)"
                fi
            fi
        done
    else
        echo "Build failed for $ARCH"
        exit 1
    fi
done

echo ""
echo "=== Build Complete ==="
echo "Native libraries have been rebuilt with 16KB page size support"
echo "Output directory: $OUTPUT_DIR"
echo ""
echo "Next steps:"
echo "1. Test your app to ensure the new libraries work correctly"
echo "2. The 16KB alignment lint warning should now be resolved"
echo "3. Commit the updated .so files to your repository"
