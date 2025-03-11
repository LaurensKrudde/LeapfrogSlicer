# Cross compilation

We aim to build for Raspberry PI 5, which has a CPU architecture: aarch64 / arm64 / ARMv8 (64 bits).

The used laptop is an x86_64 / AMD64 CPU. By default, things will be compiled for this architecture.

We use WSL2 with Ubuntu 24.

Check the CPU architecture using `uname -m` in bash or get more info with `uname -a`.


## 1. Create toolchain file

We need to specify some parameters for cross-compilation which is done in a `toolchain-arm64.cmake` file in the root directory

```
set(CMAKE_SYSTEM_NAME Linux)
set(CMAKE_SYSTEM_PROCESSOR aarch64)

set(TOOLCHAIN_PREFIX aarch64-linux-gnu)

set(CMAKE_C_COMPILER aarch64-linux-gnu-gcc)
set(CMAKE_CXX_COMPILER aarch64-linux-gnu-g++)

set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

set(CMAKE_C_FLAGS "-march=armv8-a")
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -fpermissive")

set(CMAKE_PREFIX_PATH "/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/deps/build/destdir/usr/local")
set(CMAKE_SYSTEM_PREFIX_PATH "/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/deps/build/destdir/usr/local")

# Set explicit paths for PNG
set(PNG_LIBRARY "/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/deps/build/destdir/usr/local/lib/libpng.a")
set(PNG_PNG_INCLUDE_DIR "/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/deps/build/destdir/usr/local/include")
```


## 2. Download arm64 version of packages

Before building the dependencies, some packages need to be installed (as mentioned in docs). We need to make sure we get the versions for arm64. By default, the amd64 versions will get installed.

First, we need to tell WSL where it can find the arm64 version. Modify the ubuntu sources using nano:

```
sudo nano /etc/apt/sources.list.d/ubuntu.sources
```

Change to:

```
Types: deb
URIs: http://archive.ubuntu.com/ubuntu/
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
Architectures: amd64

## Ubuntu security updates. Aside from URIs and Suites,
## this should mirror your choices in the previous section.
Types: deb
URIs: http://security.ubuntu.com/ubuntu/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
Architectures: amd64

# Added for cross-compiling
Types: deb
URIs: http://ports.ubuntu.com/ubuntu-ports/
Suites: noble noble-updates noble-backports
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
Architectures: arm64

Types: deb
URIs: http://ports.ubuntu.com/ubuntu-ports/
Suites: noble-security
Components: main restricted universe multiverse
Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
Architectures: arm64
```

The first two are present by default. `Architectures: amd64` is added such that these are only used for amd64. The last two are added locations for arm64 versions.

Now we can add the arm64 version of the packages:

```
sudo dpkg --add-architecture arm64
```

```
sudo apt update
```

```
sudo apt install -y \
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    libglu1-mesa-dev:arm64 \
    libgtk-3-dev:arm64 \
    libdbus-1-dev:arm64 \
    libwebkit2gtk-4.1-dev:arm64 \
    texinfo
```

### arm64 packages error: conflict for libpango1.0

A conflict arose for a package called libpango1.0. It seemed that the amd64 and arm64 versions were conflicting as they both used the same file/folder. This was resolved by running

```
sudo dpkg -i --force-overwrite /var/cache/apt/archives/libpango1.0-dev_1.52.1+ds-1build1_arm64.deb
```

Then, to resolve the missing dependencies and complete the configuration of libpango1.0-dev:arm64
```
sudo apt-get -f install
```

When trying again to install the packages, it was recommended to autoremove some unused packages using
```
sudo apt autoremove
```


## 3. Building the dependencies

The dependencies can now be built using the commands from the docs with the additional arguments:

```
cd deps
mkdir build
cd build
cmake .. \
-DDEP_WX_GTK3=ON \
-DCMAKE_TOOLCHAIN_FILE=/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/toolchain-arm64.cmake \
-DZLIB_LIBRARY=/usr/lib/aarch64-linux-gnu/libz.so \
-DZLIB_INCLUDE_DIR=/usr/include
make
```

### Errors resolved

#### ZLIB not found

The errors of ZLIB not being found were resolved by adding the arguments to cmake commands:

```
-DZLIB_LIBRARY=/usr/lib/aarch64-linux-gnu/libz.so \
-DZLIB_INCLUDE_DIR=/usr/include
```

#### Other dependencies not found (EXPAT, PNG, NANOSVG, ...)

More dependencies were not found during the build of wxWidgets, even though they had been previously built. Adding the destdir to the toolchain seemed to solve this...

```
set(CMAKE_PREFIX_PATH "/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/deps/build/destdir/usr/local")
set(CMAKE_SYSTEM_PREFIX_PATH "/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/deps/build/destdir/usr/local")
```

#### PNG not found

Even though PNG should be found in the same place as all other dependencies as we specified above, it was necessary to explicitely tell where PNG is found...

```
set(PNG_LIBRARY "/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/deps/build/destdir/usr/local/lib/libpng.a")
set(PNG_PNG_INCLUDE_DIR "/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/deps/build/destdir/usr/local/include")
```

#### wxWidgets not supporting 64-bit?

Got a lot of errors about type casting between `void*` or `const char*` and `sptr_t`, which is defined as `int`. Something about the pointers being 64 bit and the int being 32 bit.

A newer wxWidgets version could maybe solve this, but we simply ignored this using the compiler flag `-fpermissive` in the toolchain.

```
set(CMAKE_CXX_FLAGS "${CMAKE_C_FLAGS} -fpermissive")
```


## 4. Building PrusaSlicer

PrusaSlicer can now be built using:

```
cmake .. \
    -DSLIC3R_STATIC=1 \
    -DSLIC3R_GTK=3 \
    -DSLIC3R_PCH=OFF \
    -DCMAKE_PREFIX_PATH=$(pwd)/../deps/build/destdir/usr/local \
    -DCMAKE_TOOLCHAIN_FILE=/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/toolchain-arm64.cmake \
    -DDBus1_DIR="/usr/lib/aarch64-linux-gnu/cmake/DBus1" \
    -DDBus1_LIBRARY="/usr/lib/aarch64-linux-gnu/libdbus-1.a" \
    -DDBus1_INCLUDE_DIR="/usr/include/dbus-1.0" \
    -DDBus1_ARCH_INCLUDE_DIR="/usr/lib/aarch64-linux-gnu/dbus-1.0/include" \
    -DOPENGL_opengl_LIBRARY="/usr/lib/aarch64-linux-gnu/libGL.so" \
    -DOPENGL_glx_LIBRARY="/usr/lib/aarch64-linux-gnu/libGLU.so" \
    -DOPENGL_INCLUDE_DIR="/usr/include/GL" \
    -DwxWidgets_CONFIG_EXECUTABLE=/usr/local/bin/wx-config \
    -DwxWidgets_INCLUDE_DIRS="$(wx-config --cxxflags)" \
    -DwxWidgets_LIBRARIES="$(wx-config --libs)" 
```


### Errors resolved


#### DBus not found

Explicitely added them to cmake command

```
-DDBus1_DIR="/usr/lib/aarch64-linux-gnu/cmake/DBus1" \
-DDBus1_LIBRARY="/usr/lib/aarch64-linux-gnu/libdbus-1.a" \
-DDBus1_INCLUDE_DIR="/usr/include/dbus-1.0" \
-DDBus1_ARCH_INCLUDE_DIR="/usr/lib/aarch64-linux-gnu/dbus-1.0/include" \
```

#### OpenGL not found

Explicitely added them to cmake command

```
-DOPENGL_opengl_LIBRARY="/usr/lib/aarch64-linux-gnu/libGL.so" \
-DOPENGL_glx_LIBRARY="/usr/lib/aarch64-linux-gnu/libGLU.so" \
-DOPENGL_INCLUDE_DIR="/usr/include/GL" \
```

#### wxWidgets not found

This problem might have been caused by the fact that no wx-config file seemed to be present at:

```
deps/build/destdir/usr/local/bin/wx-config
```

Why it wasn't there is not clear. However, a script serving the same purpose was found at

```
deps/build/destdir/usr/locallib/wx/config/gtk3-unicode-static-3.2
```

Hacky solution incoming... The script was linked to the destination where wx-config would normally be found

```
sudo ln -s /mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/deps/build/destdir/usr/local/lib/wx/config/gtk3-unicode-static-3.2 /usr/local/bin/wx-config
```

And added to path

```
export PATH=/mnt/c/Users/laure/Documents/AVFlexologic/RPI/LeapfrogSlicer/deps/build/destdir/usr/local/lib/wx/config:$PATH
```

Such that wx-config command was available
```
wx-config --version
```

This command was used to specify the correct folders to cmake using the commands
```
-DwxWidgets_CONFIG_EXECUTABLE=/usr/local/bin/wx-config \
-DwxWidgets_INCLUDE_DIRS="$(wx-config --cxxflags)" \
-DwxWidgets_LIBRARIES="$(wx-config --libs)" 
```

#### webkit not found

pkg could not locate webkit eventhough it was installed. As a fix, I set the PKG config path

```
export PKG_CONFIG_PATH=/usr/lib/aarch64-linux-gnu/pkgconfig/webkit2gtk-4.1.pc:$PKG_CONFIG_PATH
```
and added the following line to the toolchain (not sure which of the two did the trick)
```
set(PKG_CONFIG_PATH "/usr/lib/aarch64-linux-gnu/pkgconfig" $ENV{PKG_CONFIG_PATH})
```

#### OpenGL link error

Changed `OpenGL::GL` to `OpenGL::OpenGL` in `src/slic3r/CMakeLists.txt` line 447.




## 5. Confirm succesful cross-compilation

Check the architecture that prusa-slicer is build for:

    file ./prusa-slicer

This should state: 

    prusa-slicer: ELF 64-bit LSB executable, ARM aarch64, ...

If it is x86-64 then we did not cross-compile.

Note: it is possible to run x86-64 binary on ARM, but then you need an emulator. This significantly reduces speed and is not what we want.