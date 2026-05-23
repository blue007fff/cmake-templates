include(FetchContent)

# FetchContent downloads and builds dependencies at configure time.
# GIT_TAG pins to a full commit SHA for reproducible builds — tags can be force-pushed.
# GIT_SHALLOW TRUE avoids downloading the full git history (much faster).
# SYSTEM suppresses compiler warnings from the dependency's own headers (CMake 3.25+).
FetchContent_Declare(
    fmt
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git
    GIT_TAG        e69e5f977d458f2650bb346dadf2ad30c5320281  # 10.2.1
    GIT_SHALLOW    TRUE
    SYSTEM
)
set(FMT_TEST OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(fmt)

FetchContent_Declare(
    spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog.git
    GIT_TAG        f355b3d58f7067eee1706ff3c801c2361011f3d5  # v1.15.1
    GIT_SHALLOW    TRUE
    SYSTEM
)
set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
# Use the fmt we already fetched instead of spdlog's bundled copy
set(SPDLOG_FMT_EXTERNAL ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(spdlog)
