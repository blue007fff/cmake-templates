# cmake_minimum_required: 이 프로젝트가 요구하는 최소 CMake 버전.
# 지정 버전 미만이면 configure 단계에서 즉시 오류 발생.
# 버전 숫자는 "정책(policy) 기준선"이기도 함 — 이 버전까지의 동작 변경을 모두 수용.
# 3.25 이상: FetchContent_Declare()의 SYSTEM 키워드 지원
cmake_minimum_required(VERSION 3.25)

# vcpkg 툴체인 설정 — 반드시 project() 이전에 위치해야 함.
# 이유: CMake는 project() 호출 시 컴파일러를 탐색하는데,
#   CMAKE_TOOLCHAIN_FILE 이 그 탐색 과정 전체에 개입하기 때문.
#   project() 이후에 설정하면 이미 탐색이 끝난 후라 무시됨.
#
# DEFINED ENV{VCPKG_ROOT}         → 환경변수 VCPKG_ROOT 가 설정된 경우에만
# NOT DEFINED CMAKE_TOOLCHAIN_FILE → 사용자가 직접 지정하지 않은 경우에만
# CACHE STRING: 캐시에 저장 → cmake-gui 나 -D 플래그로 덮어쓸 수 있음
if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
        CACHE STRING "Vcpkg toolchain file")
endif()

# project(): 프로젝트 이름, 버전, 사용 언어 선언.
# VERSION 설정 시 아래 변수가 자동으로 채워짐:
#   PROJECT_VERSION       = "0.1.0"
#   PROJECT_VERSION_MAJOR = 0  /  MINOR = 1  /  PATCH = 0
# LANGUAGES CXX: C++ 컴파일러만 탐색 (C 컴파일러 탐색 생략 → configure 속도 향상)
project(MyApp VERSION 0.1.0 LANGUAGES CXX)

# C++ 표준 설정
# CMAKE_CXX_STANDARD_REQUIRED ON: 표준 미지원 시 오류 (조용한 fallback 방지)
# CMAKE_CXX_EXTENSIONS OFF: GNU 확장 사용 안 함 (-std=c++20, not -std=gnu++20)
#   → MSVC / GCC / Clang 간 이식성 향상
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# option(): 사용자가 ON/OFF 로 제어할 수 있는 캐시 변수.
# 커맨드라인: cmake --preset x64-debug -DBUILD_TESTS=OFF
# 주의: 캐시에 이미 값이 있으면 기본값을 덮어쓰지 않음.
# 위치: 의존성 선언보다 앞에 두어야 부모 프로젝트가 값을 미리 지정할 수 있음.
option(BUILD_TESTS "Build tests" ON)

# cmake/deps.cmake: 외부 의존성 선언을 별도 파일로 분리.
# vcpkg 전용 또는 vcpkg + FetchContent 이중 모드로 동작 (파일 내 주석 참고).
include(cmake/deps.cmake)

# add_subdirectory(): 해당 디렉토리의 CMakeLists.txt 를 읽어 처리.
# 각 디렉토리는 자체 스코프를 갖지만, 정의한 타겟은 부모에서 참조 가능.
# libs/core → core 타겟 / libs/utils → utils 타겟 정의
add_subdirectory(libs/core)
add_subdirectory(libs/utils)

# 실행 파일 타겟 생성 및 라이브러리 연결.
# target_link_libraries() 가시성 키워드:
#   PRIVATE   — 이 타겟 빌드에만 필요. 소비자에게 전파 안 함.
#   PUBLIC    — 이 타겟 + 소비자 모두에게 전파 (헤더에 노출되는 타입 등).
#   INTERFACE — 이 타겟 빌드엔 불필요, 소비자에게만 전파 (헤더 전용 라이브러리).
# spdlog::spdlog: 이중 콜론(::)은 imported/alias target. 헤더 경로와 링크 설정이 자동 전파됨.
add_executable(MyApp src/main.cpp)
target_link_libraries(MyApp PRIVATE core utils spdlog::spdlog)

# 컴파일러 경고 설정 — 이 프로젝트의 모든 타겟에 적용
# MSVC : /W4  (0~4 단계, W4가 권장 수준. /Wall은 표준 라이브러리 경고까지 포함해 너무 많음)
# GCC/Clang : -Wall (기본 경고) -Wextra (추가 경고) -Wpedantic (표준 준수 검사)
# PRIVATE: 이 타겟 빌드에만 적용, 소비자에게 전파 안 함
foreach(target IN ITEMS MyApp core utils)
    if(MSVC)
        target_compile_options(${target} PRIVATE /W4)
    else()
        target_compile_options(${target} PRIVATE -Wall -Wextra -Wpedantic)
    endif()
endforeach()

# 테스트 빌드 — BUILD_TESTS=OFF 로 비활성화 가능
if(BUILD_TESTS)
    include(FetchContent)

    # GIT_TAG: commit SHA 로 고정 → 태그 force-push 에도 재현 가능한 빌드 보장
    # GIT_SHALLOW TRUE: --depth 1 clone, 전체 히스토리 불필요 → 속도 향상
    # SYSTEM: 이 의존성 헤더의 컴파일러 경고를 억제 (CMake 3.25+)
    FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG        f8d7d77c06936315286eb55f8de22cd23c188571  # v1.14.0
        GIT_SHALLOW    TRUE
        SYSTEM
    )
    # gtest_force_shared_crt ON: MSVC 에서 /MD(동적 CRT) 사용 강제.
    #   기본값 /MT(정적 CRT) 사용 시 프로젝트와 CRT 불일치 링크 오류 발생.
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    # INSTALL_GTEST OFF: cmake --install 시 googletest 파일 설치 제외.
    set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)

    # enable_testing(): CTest 활성화. add_subdirectory(tests) 이전에 호출 필요.
    enable_testing()
    add_subdirectory(tests)
endif()

# ── install 규칙 ─────────────────────────────────────────────
# cmake --install <build_dir> [--prefix <경로>] 실행 시 파일을 지정 경로에 복사.
# 기본 설치 경로: Linux /usr/local, Windows C:/Program Files/<ProjectName>
# 프리셋의 installDir 또는 --prefix 로 경로 변경 가능.
#
# DESTINATION 키워드별 역할:
#   RUNTIME → 실행 파일(.exe), Windows DLL(.dll)
#   ARCHIVE → 정적 라이브러리(.lib/.a), Windows import lib
#   LIBRARY → Unix 공유 라이브러리(.so/.dylib)
install(TARGETS MyApp RUNTIME DESTINATION bin)

# vcpkg DLL 복사 (Windows + vcpkg 환경에서만)
# vcpkg는 Debug/Release DLL 을 별도 경로에 분리 배치:
#   Debug   → vcpkg_installed/<triplet>/debug/bin/*.dll
#   Release → vcpkg_installed/<triplet>/bin/*.dll
# CONFIGURATIONS: cmake --install --config 값에 따라 경로 분기
if(WIN32 AND DEFINED VCPKG_TARGET_TRIPLET)
    install(DIRECTORY "${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}/debug/bin/"
        DESTINATION bin
        CONFIGURATIONS Debug
        FILES_MATCHING PATTERN "*.dll"
    )
    install(DIRECTORY "${CMAKE_BINARY_DIR}/vcpkg_installed/${VCPKG_TARGET_TRIPLET}/bin/"
        DESTINATION bin
        CONFIGURATIONS Release RelWithDebInfo MinSizeRel
        FILES_MATCHING PATTERN "*.dll"
    )
endif()

# core, utils 는 이 프로젝트 내부 라이브러리 — EXPORT 없이 설치.
# 외부 find_package() 지원이 필요하면 library/ 템플릿처럼
#   EXPORT + install(EXPORT) + configure_package_config_file() 추가.
# RUNTIME 도 명시: 나중에 SHARED 로 변경해도 DLL 이 자동으로 설치됨.
install(TARGETS core utils
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)
install(DIRECTORY libs/core/include/  DESTINATION include)
install(DIRECTORY libs/utils/include/ DESTINATION include)
