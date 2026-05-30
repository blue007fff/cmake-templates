cmake_minimum_required(VERSION 3.25)
project(Scratch LANGUAGES CXX)

# C++20 required — will error instead of silently falling back
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)  # use -std=c++20, not -std=gnu++20

# Each .cpp file in this directory becomes its own executable.
# CONFIGURE_DEPENDS: re-run cmake automatically when a .cpp file is added or removed.
file(GLOB SOURCES CONFIGURE_DEPENDS "*.cpp")
foreach(SOURCE IN LISTS SOURCES)
    get_filename_component(TARGET_NAME "${SOURCE}" NAME_WE)
    add_executable("${TARGET_NAME}" "${SOURCE}")
endforeach()
