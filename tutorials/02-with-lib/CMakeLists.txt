cmake_minimum_required(VERSION 3.25)
project(AppWithLib VERSION 0.1.0 LANGUAGES CXX)

# C++20 required — will error instead of silently falling back
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(libs/mylib)

add_executable(AppWithLib src/main.cpp)
target_link_libraries(AppWithLib PRIVATE mylib)
