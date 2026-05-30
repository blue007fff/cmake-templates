# ── 의존성 관리 방식 선택 ────────────────────────────────────
#
# [A] vcpkg 전용 (권장, 단순)
#   vcpkg.json 에 패키지를 선언하면 vcpkg 가 자동 설치.
#   이 파일에서는 find_package() 만 호출하면 됨:
#
#     find_package(spdlog CONFIG REQUIRED)
#
#   vcpkg 없는 환경에서는 오류 발생 (의도적).
#
# [B] vcpkg + FetchContent 이중 모드 (현재 방식)
#   vcpkg 있는 환경  → find_package 성공 → FetchContent 건너뜀
#   vcpkg 없는 환경  → find_package 실패 → FetchContent 로 소스 빌드
#   장점: vcpkg 없는 CI / Linux / macOS 에서도 동작
#   단점: FetchContent 경로와 vcpkg 경로 두 벌을 관리해야 함
# ─────────────────────────────────────────────────────────────

include(FetchContent)

# ── fmt (주석 처리된 이중 모드 예시) ──────────────────────────
# vcpkg.json 에 "fmt" 를 추가한 뒤 아래 블록을 활성화하면
# vcpkg 없는 환경에서도 자동으로 소스 빌드됨.
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
# ※ fmt 와 spdlog 를 함께 FetchContent 할 경우 아래 설정 필요:
#     set(SPDLOG_FMT_EXTERNAL ON CACHE BOOL "" FORCE)
#   없으면 spdlog 내장 fmt 와 중복 빌드되어 ODR(One Definition Rule) 위반 발생.

# ── spdlog (이중 모드) ────────────────────────────────────────
# QUIET: 패키지를 못 찾아도 오류 없이 진행 → 아래 if 블록에서 FetchContent 로 대체
# GIT_TAG: commit SHA 로 고정 → 태그 force-push 에도 재현 가능한 빌드 보장
# GIT_SHALLOW TRUE: 전체 git 히스토리 불필요 → 다운로드 속도 향상
# SYSTEM: 이 라이브러리 헤더의 컴파일러 경고 억제 (CMake 3.25+)
find_package(spdlog CONFIG QUIET)
if(NOT spdlog_FOUND)
    FetchContent_Declare(spdlog
        GIT_REPOSITORY https://github.com/gabime/spdlog.git
        GIT_TAG        f355b3d58f7067eee1706ff3c801c2361011f3d5  # v1.15.1
        GIT_SHALLOW    TRUE
        SYSTEM)
    set(SPDLOG_BUILD_TESTS OFF CACHE BOOL "" FORCE)  # spdlog 자체 테스트 빌드 생략
    FetchContent_MakeAvailable(spdlog)
endif()
