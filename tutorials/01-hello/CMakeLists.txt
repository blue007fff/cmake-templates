# ── tutorial 01: Hello World ──────────────────────────────────
# 가장 단순한 CMake 프로젝트 구조.
# src/main.cpp 하나를 컴파일해 실행 파일을 만드는 최소 구성.

# cmake_minimum_required: 요구 최소 CMake 버전.
# 이 숫자는 "정책(policy) 기준선"이기도 함.
cmake_minimum_required(VERSION 3.25)

# project(): 프로젝트 이름, 버전, 언어 선언.
# LANGUAGES CXX: C++ 컴파일러만 탐색 (C 컴파일러 탐색 생략)
project(Hello VERSION 0.1.0 LANGUAGES CXX)

# C++ 표준 설정
# REQUIRED ON: 표준 미지원 시 조용히 낮은 버전으로 fallback 하지 않고 오류 발생
# EXTENSIONS OFF: -std=c++20 사용 (GNU 확장인 -std=gnu++20 사용 안 함)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# add_executable(): 소스 파일로 실행 파일 타겟 생성.
# 여러 소스 파일이 있으면 공백으로 구분해 나열:
#   add_executable(Hello src/main.cpp src/other.cpp)
add_executable(Hello src/main.cpp)
