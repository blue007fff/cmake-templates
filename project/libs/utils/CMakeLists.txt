# Subdirectory — inherits cmake_minimum_required and project from the root.
add_library(utils STATIC
    src/utils.cpp
)

target_include_directories(utils PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
