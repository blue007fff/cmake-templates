# FetchContent: CMake 내장 모듈. 외부 소스를 configure 시점에 다운로드해 빌드.
# 동작 순서:
#   1. FetchContent_Declare(): 어디서 받을지 선언 (실제 다운로드 X)
#   2. FetchContent_MakeAvailable(): 다운로드 + add_subdirectory() 자동 수행
include(FetchContent)

# ── fmt ───────────────────────────────────────────────────────
# GIT_TAG: 태그 이름 대신 commit SHA 사용 → 태그 force-push 에도 재현 가능한 빌드 보장
# GIT_SHALLOW TRUE: --depth 1 clone, 전체 히스토리 불필요 → 다운로드 속도 향상
# SYSTEM: 이 라이브러리 헤더의 컴파일러 경고를 -isystem 으로 억제 (CMake 3.25+)
FetchContent_Declare(
    fmt
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git
    GIT_TAG        e69e5f977d458f2650bb346dadf2ad30c5320281  # 10.2.1
    GIT_SHALLOW    TRUE
    SYSTEM
)
# fmt 자체 테스트 빌드 비활성화 — 이 프로젝트와 무관한 테스트까지 빌드하지 않도록.
set(FMT_TEST OFF CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(fmt)

# ── spdlog ────────────────────────────────────────────────────
FetchContent_Declare(
    spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog.git
    GIT_TAG        f355b3d58f7067eee1706ff3c801c2361011f3d5  # v1.15.1
    GIT_SHALLOW    TRUE
    SYSTEM
)
set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)
# SPDLOG_FMT_EXTERNAL ON: 위에서 받은 fmt 를 spdlog 가 재사용하도록 설정.
#   OFF(기본값)이면 spdlog 가 자체 내장 fmt 를 따로 컴파일 → fmt 두 벌 존재
#   → ODR(One Definition Rule) 위반, 링크 오류 또는 런타임 오동작 가능.
set(SPDLOG_FMT_EXTERNAL ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(spdlog)
