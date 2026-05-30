# library/ 템플릿: 외부 소비자가 find_package() 로 찾을 수 있는 C++ 라이브러리.
# cmake --install 후 아래처럼 사용 가능:
#   find_package(MyLib REQUIRED)
#   target_link_libraries(myapp PRIVATE MyLib::mylib)
cmake_minimum_required(VERSION 3.25)
project(MyLib VERSION 0.1.0 LANGUAGES CXX)

# C++ 표준 설정
# CMAKE_CXX_STANDARD_REQUIRED ON: 표준 미지원 시 오류 (조용한 fallback 방지)
# CMAKE_CXX_EXTENSIONS OFF: GNU 확장 사용 안 함 → 이식성 향상
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# add_library(): 라이브러리 타겟 생성.
# STATIC : 컴파일 결과를 실행 파일에 직접 포함. 배포 시 별도 파일 불필요. (.lib / .a)
# SHARED : 런타임에 로드되는 별도 파일. 여러 프로세스가 공유 가능. (.dll / .so)
# 명시하지 않으면 BUILD_SHARED_LIBS 변수를 따름 (기본값 OFF = STATIC)
add_library(mylib STATIC
    src/mylib.cpp
)

# target_include_directories(): 헤더 파일 탐색 경로 지정.
# PUBLIC: mylib 자체 + 소비자 타겟 모두에 전파
#   → target_link_libraries(app PRIVATE mylib) 하면 app 도 자동으로 이 경로를 가짐.
# $<BUILD_INTERFACE:...>: 빌드 시 사용하는 경로 (소스 트리 내부)
# $<INSTALL_INTERFACE:...>: cmake --install 후 소비자가 find_package() 로 찾을 때 사용하는 경로
#   설치 후에는 CMAKE_INSTALL_PREFIX/include 아래에 위치하므로 상대 경로 사용
target_include_directories(mylib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

# 컴파일러 경고 설정
# MSVC : /W4  (0~4 단계 중 권장 수준)
# GCC/Clang : -Wall (기본) -Wextra (추가) -Wpedantic (표준 준수)
# PRIVATE: 이 타겟 빌드에만 적용, 소비자에게 전파 안 함
if(MSVC)
    target_compile_options(mylib PRIVATE /W4)
else()
    target_compile_options(mylib PRIVATE -Wall -Wextra -Wpedantic)
endif()

option(BUILD_TESTS "Build tests" ON)
if(BUILD_TESTS)
    include(FetchContent)
    # GIT_TAG: commit SHA 로 고정 → 재현 가능한 빌드
    # SYSTEM: 이 의존성 헤더의 컴파일러 경고 억제 (CMake 3.25+)
    FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG        f8d7d77c06936315286eb55f8de22cd23c188571  # v1.14.0
        GIT_SHALLOW    TRUE
        SYSTEM
    )
    # gtest_force_shared_crt ON: MSVC 에서 /MD 사용 강제 (CRT 불일치 방지)
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    # INSTALL_GTEST OFF: cmake --install 시 googletest 파일 설치 제외
    set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)

    enable_testing()
    add_subdirectory(tests)
endif()

# ── 패키지 설치 설정 ──────────────────────────────────────────
# 목표: cmake --install 후 소비자가 find_package(MyLib) 로 이 라이브러리를 찾을 수 있게 함.
# 생성되는 파일 3가지:
#   MyLibTargets.cmake      — import target 정의 (헤더 경로, 링크 설정 포함)
#   MyLibConfig.cmake       — find_package() 가 로드하는 진입점
#   MyLibConfigVersion.cmake — 버전 호환성 체크
include(CMakePackageConfigHelpers)

# EXPORT MyLibTargets: 이 타겟을 export 집합에 등록.
# RUNTIME DESTINATION bin: Windows DLL (.dll)
# ARCHIVE DESTINATION lib: 정적 라이브러리 (.lib/.a), Windows import lib
# LIBRARY DESTINATION lib: Unix 공유 라이브러리 (.so/.dylib)
# 세 가지 모두 명시: STATIC→SHARED 변경 시에도 install 규칙 수정 불필요.
install(TARGETS mylib
    EXPORT MyLibTargets
    RUNTIME DESTINATION bin
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)

# install(EXPORT): export 집합을 MyLibTargets.cmake 파일로 내보냄.
# NAMESPACE MyLib::: 소비자는 MyLib::mylib 으로 사용
#   이중 콜론(::)은 imported target 임을 CMake 에 알려줌.
#   find_package() 없이 MyLib::mylib 을 쓰면 오류 → 실수 방지.
install(EXPORT MyLibTargets
    FILE       MyLibTargets.cmake
    NAMESPACE  MyLib::
    DESTINATION lib/cmake/MyLib
)

# configure_package_config_file(): .cmake.in 템플릿으로 MyLibConfig.cmake 생성.
# @PACKAGE_INIT@ 이 set_and_check(), check_required_components() 헬퍼로 치환됨.
# INSTALL_DESTINATION: find_package() 가 이 파일을 탐색하는 경로
configure_package_config_file(
    cmake/MyLibConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake
    INSTALL_DESTINATION lib/cmake/MyLib
)

# write_basic_package_version_file(): 버전 호환성 체크 파일 생성.
# find_package(MyLib 1.0 REQUIRED) 처럼 버전을 지정하면 이 파일이 검사함.
# COMPATIBILITY 옵션:
#   AnyNewerVersion  — 요청 버전 이상이면 호환 (가장 느슨)
#   SameMajorVersion — 동일 Major 버전이면 호환 (semver 관례: 1.x → 1.y 가능)
#   SameMinorVersion — 동일 Major+Minor 버전이면 호환 (1.2.x → 1.2.y 가능)
#   ExactVersion     — 정확히 일치해야 호환 (가장 엄격)
# 권장: 1.0 이상 안정 버전 → SameMajorVersion / 0.x pre-release → ExactVersion
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake
    DESTINATION lib/cmake/MyLib
)

# 공개 헤더 설치: include/ 내용을 설치 경로의 include/ 아래에 복사.
# 후행 슬래시(include/): 디렉토리 자체가 아닌 내용만 복사 (cp -r include/ 동작)
install(DIRECTORY include/ DESTINATION include)
