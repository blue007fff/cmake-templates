# ── tutorial 03: 외부 의존성 사용 (FetchContent) ─────────────
# CMake 내장 FetchContent 모듈로 외부 라이브러리(fmt, spdlog)를 자동 다운로드.
# vcpkg 없이도 동작하며, 처음 빌드 시 GitHub 에서 소스를 받아 함께 빌드함.
cmake_minimum_required(VERSION 3.25)
project(WithDeps VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# cmake/deps.cmake: 외부 의존성 선언 분리.
# FetchContent_Declare / FetchContent_MakeAvailable 호출이 여기에 있음.
include(cmake/deps.cmake)

add_executable(WithDeps src/main.cpp)

# fmt::fmt, spdlog::spdlog:
#   이중 콜론(::)은 CMake imported/alias target 을 의미.
#   FetchContent 또는 find_package 가 제공한 타겟으로,
#   헤더 경로와 링크 설정이 자동으로 전파됨.
target_link_libraries(WithDeps PRIVATE fmt::fmt spdlog::spdlog)
