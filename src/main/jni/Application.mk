APP_STL := c++_shared
APP_CPPFLAGS += -fexceptions

#For ANativeWindow support - updated for API 35
APP_PLATFORM = android-35

# Support for 16KB page size devices
APP_CPPFLAGS += -DSUPPORT_16KB_PAGES

# 16KB page size alignment flags
APP_CFLAGS += -DSUPPORT_16KB_PAGES
APP_CPPFLAGS += -DSUPPORT_16KB_PAGES

# Enable 16KB page size support
APP_CFLAGS += -D__ANDROID_API__=35
APP_CPPFLAGS += -D__ANDROID_API__=35

# Linker flags for 16KB alignment
APP_LDFLAGS += -Wl,-z,page-size=16384

# Target only modern architectures for 16KB support
APP_ABI := arm64-v8a armeabi-v7a

# Enable position independent code
APP_CFLAGS += -fPIC
APP_CPPFLAGS += -fPIC

# Optimization flags
APP_CFLAGS += -O2 -DNDEBUG
APP_CPPFLAGS += -O2 -DNDEBUG