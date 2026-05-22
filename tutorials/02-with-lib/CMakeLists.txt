cmake_minimum_required(VERSION 3.25)
project(AppWithLib VERSION 0.1.0 LANGUAGES CXX)

# C++20 required — will error instead of silently falling back
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)  # use -std=c++20, not -std=gnu++20

add_subdirectory(libs/mylib)

add_executable(AppWithLib src/main.cpp)
target_link_libraries(AppWithLib PRIVATE mylib)
