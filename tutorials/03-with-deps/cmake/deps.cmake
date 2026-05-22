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
# Suppress fmt's own test targets from appearing in this project's build.
set(FMT_TEST OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(fmt)

# Add more libraries here using the same pattern:
#
# FetchContent_Declare(
#   spdlog
#   GIT_REPOSITORY https://github.com/gabime/spdlog.git
#   GIT_TAG        SHA_FOR_v1.13.0  # v1.13.0
#   GIT_SHALLOW    TRUE
#   SYSTEM
# )
# set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
# FetchContent_MakeAvailable(spdlog)
