cmake_minimum_required(VERSION 3.25)

# CMAKE_TOOLCHAIN_FILE must be set before project() — vcpkg toolchain is loaded at that point.
if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
        CACHE STRING "Vcpkg toolchain file")
endif()

project(MyApp VERSION 0.1.0 LANGUAGES CXX)

# C++20 required — will error instead of silently falling back
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)  # use -std=c++20, not -std=gnu++20

option(BUILD_TESTS "Build tests" ON)

include(cmake/deps.cmake)

add_subdirectory(libs/core)
add_subdirectory(libs/utils)

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

if(BUILD_TESTS)
    include(FetchContent)
    FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG        f8d7d77c06936315286eb55f8de22cd23c188571  # v1.14.0
        GIT_SHALLOW    TRUE
        SYSTEM
    )
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)  # prevents MSVC CRT mismatch on Windows
    set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)          # don't install gtest alongside this app
    FetchContent_MakeAvailable(googletest)
    enable_testing()
    add_subdirectory(tests)
endif()

install(TARGETS MyApp RUNTIME DESTINATION bin)
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
install(TARGETS core utils
    RUNTIME DESTINATION bin   # shared library Windows DLL (.dll)
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)
install(DIRECTORY libs/core/include/  DESTINATION include)
install(DIRECTORY libs/utils/include/ DESTINATION include)
