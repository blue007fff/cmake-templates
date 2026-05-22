cmake_minimum_required(VERSION 3.25)
project(WithDeps VERSION 0.1.0 LANGUAGES CXX)

# C++20 required — will error instead of silently falling back
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)  # use -std=c++20, not -std=gnu++20

# deps.cmake declares all FetchContent dependencies
include(cmake/deps.cmake)

add_executable(WithDeps src/main.cpp)
# fmt::fmt is the namespaced target exported by fmtlib
target_link_libraries(WithDeps PRIVATE fmt::fmt)
