set(CMAKE_SYSTEM_NAME "Linux")
set(CMAKE_SYSTEM_PROCESSOR "aarch64")

set(TOOLCHAIN_PREFIX "aarch64-linux-gnu")

set(CMAKE_C_COMPILER "aarch64-linux-gnu-gcc")
set(CMAKE_CXX_COMPILER "aarch64-linux-gnu-g++")

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CMAKE_C_FLAGS "-march=armv8-a")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -fpermissive")

set(CMAKE_PREFIX_PATH "/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/deps/build/destdir/usr/local")

# # Explicitly set paths for ZLIB
# set(ZLIB_LIBRARY /usr/aarch64-linux-gnu/lib/libz.so)
# set(ZLIB_INCLUDE_DIR /usr/aarch64-linux-gnu/include)

# # Set explicit paths for PNG
set(PNG_LIBRARY "/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/deps/build/destdir/usr/local/lib/libpng.a")
set(PNG_PNG_INCLUDE_DIR "/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/deps/build/destdir/usr/local/include")

set(PKG_CONFIG_PATH "/usr/lib/aarch64-linux-gnu/pkgconfig" $ENV{PKG_CONFIG_PATH})


# # Explicitly set paths for JPEG
# set(JPEG_LIBRARY /usr/aarch64-linux-gnu/lib/libjpeg.so)
# set(JPEG_INCLUDE_DIR /usr/aarch64-linux-gnu/include)

# # Explicitly set paths for EXPAT
# set(EXPAT_DIR /usr/aarch64-linux-gnu)
# set(EXPAT_LIBRARY /usr/aarch64-linux-gnu/lib/libexpat.so)
# set(EXPAT_INCLUDE_DIR /usr/aarch64-linux-gnu/include)

# /mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer
# -DCMAKE_TOOLCHAIN_FILE=/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/toolchain-arm64.cmake