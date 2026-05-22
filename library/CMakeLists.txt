cmake_minimum_required(VERSION 3.25)
project(MyLib VERSION 0.1.0 LANGUAGES CXX)

# C++20 required — will error instead of silently falling back
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)  # use -std=c++20, not -std=gnu++20

add_library(mylib STATIC
    src/mylib.cpp
)

target_include_directories(mylib PUBLIC
    # BUILD_INTERFACE: path used when building this project
    # INSTALL_INTERFACE: path used by consumers after cmake --install
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

option(BUILD_TESTS "Build tests" ON)
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
    FetchContent_MakeAvailable(googletest)

    enable_testing()
    add_subdirectory(tests)
endif()

include(CMakePackageConfigHelpers)

install(TARGETS mylib
    EXPORT MyLibTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)
install(EXPORT MyLibTargets
    FILE       MyLibTargets.cmake
    NAMESPACE  MyLib::
    DESTINATION lib/cmake/MyLib
)
configure_package_config_file(
    cmake/MyLibConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake
    INSTALL_DESTINATION lib/cmake/MyLib
)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion  # change to SameMinorVersion for pre-1.0 libraries
)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake
    DESTINATION lib/cmake/MyLib
)
install(DIRECTORY include/ DESTINATION include)
