cmake_minimum_required(VERSION 3.25)
project(MyApp VERSION 0.1.0 LANGUAGES CXX)

# C++20 required — will error instead of silently falling back
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)  # use -std=c++20, not -std=gnu++20

include(cmake/deps.cmake)

add_subdirectory(libs/core)
add_subdirectory(libs/utils)

add_executable(MyApp src/main.cpp)
target_link_libraries(MyApp PRIVATE core utils)

option(BUILD_TESTS "Build tests" ON)
if(BUILD_TESTS)
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

install(TARGETS MyApp RUNTIME DESTINATION bin)
install(TARGETS core utils
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)
install(DIRECTORY libs/core/include/  DESTINATION include)
install(DIRECTORY libs/utils/include/ DESTINATION include)
