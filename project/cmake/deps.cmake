include(FetchContent)

# vcpkg integration: if VCPKG_ROOT is set, activate the vcpkg toolchain.
# Without vcpkg, all dependencies fall back to FetchContent automatically.
if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
        CACHE STRING "Vcpkg toolchain file")
endif()

# vcpkg / FetchContent dual-mode example (uncomment to use):
# vcpkg.json lists the package names; this block wires them into the CMake build.
# With vcpkg: find_package() picks up the pre-built package from the vcpkg tree.
# Without vcpkg: FetchContent builds it from source automatically.
#
# find_package(fmt CONFIG QUIET)
# if(NOT fmt_FOUND)
#     FetchContent_Declare(fmt
#         GIT_REPOSITORY https://github.com/fmtlib/fmt.git
#         GIT_TAG        e69e5f977d458f2650bb346dadf2ad30c5320281  # 10.2.1
#         GIT_SHALLOW    TRUE
#         SYSTEM)
#     set(FMT_TEST OFF CACHE BOOL "" FORCE)
#     FetchContent_MakeAvailable(fmt)
# endif()
