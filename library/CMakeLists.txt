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

# 컴파일러 경고 설정
if(MSVC)
    target_compile_options(mylib PRIVATE /W4)
else()
    target_compile_options(mylib PRIVATE -Wall -Wextra -Wpedantic)
endif()

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
    set(INSTALL_GTEST OFF CACHE BOOL "" FORCE)          # don't install gtest alongside this library
    FetchContent_MakeAvailable(googletest)

    enable_testing()
    add_subdirectory(tests)
endif()

# CMakePackageConfigHelpers: find_package() 지원을 위한 config 파일 생성 도우미
include(CMakePackageConfigHelpers)

install(TARGETS mylib
    EXPORT MyLibTargets
    RUNTIME DESTINATION bin   # shared library Windows DLL (.dll)
    ARCHIVE DESTINATION lib   # static library (.lib / .a)
    LIBRARY DESTINATION lib   # shared library (.so / .dylib)
)
# MyLib:: 네임스페이스로 export — 소비자는 target_link_libraries(... MyLib::mylib) 로 사용
install(EXPORT MyLibTargets
    FILE       MyLibTargets.cmake
    NAMESPACE  MyLib::
    DESTINATION lib/cmake/MyLib
)
# find_package(MyLib) 가 동작하도록 MyLibConfig.cmake 생성
configure_package_config_file(
    cmake/MyLibConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake
    INSTALL_DESTINATION lib/cmake/MyLib
)
# find_package(MyLib 1.0) 버전 체크를 위한 파일 생성
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
