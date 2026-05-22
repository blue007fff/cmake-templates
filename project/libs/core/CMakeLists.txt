# Subdirectory — inherits cmake_minimum_required and project from the root.
add_library(core STATIC
    src/core.cpp
)

target_include_directories(core PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
