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
# vcpkg 있는 환경  → find_package 성공 → FetchContent 건너뜀
# vcpkg 없는 환경  → find_package 실패 → FetchContent로 소스 빌드 (이중 모드)
find_package(spdlog CONFIG QUIET)
if(NOT spdlog_FOUND)
    FetchContent_Declare(spdlog
        GIT_REPOSITORY https://github.com/gabime/spdlog.git
        GIT_TAG        f355b3d58f7067eee1706ff3c801c2361011f3d5  # v1.15.1
        GIT_SHALLOW    TRUE
        SYSTEM)
    set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
    # fmt를 별도로 FetchContent 추가할 경우 아래 설정 필요.
    # 없으면 spdlog 내장 fmt와 충돌해 ODR 위반 발생.
    # set(SPDLOG_FMT_EXTERNAL ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(spdlog)
endif()
