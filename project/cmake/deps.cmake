include(FetchContent)

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
#
find_package(spdlog CONFIG QUIET)
if(NOT spdlog_FOUND)
    FetchContent_Declare(spdlog
        GIT_REPOSITORY https://github.com/gabime/spdlog.git
        GIT_TAG        f355b3d58f7067eee1706ff3c801c2361011f3d5  # v1.15.1
        GIT_SHALLOW    TRUE
        SYSTEM)
    set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(spdlog)
endif()
