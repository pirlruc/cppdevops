# libc++ triplet for the ci-cpp images. Library CI compiles with
# -stdlib=libc++, so every vcpkg port must use the same standard library.
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

set(VCPKG_CMAKE_SYSTEM_NAME Linux)

set(VCPKG_C_COMPILER clang)
set(VCPKG_CXX_COMPILER clang++)
# vcpkg rejects CXX flags unless C flags are set as well.
set(VCPKG_C_FLAGS "-pipe")
set(VCPKG_CXX_FLAGS "-stdlib=libc++ -pipe")
set(VCPKG_LINKER_FLAGS "-stdlib=libc++")
