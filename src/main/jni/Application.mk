APP_STL := c++_shared
APP_CPPFLAGS += -fexceptions

#For ANativeWindow support
APP_PLATFORM = android-14

# Support for 16KB page size devices
APP_CPPFLAGS += -DSUPPORT_16KB_PAGES

APP_ABI :=  arm64-v8a \
            armeabi-v7a \
            x86 \
            x86_64