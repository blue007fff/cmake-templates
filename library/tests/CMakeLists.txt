# Subdirectory — inherits cmake_minimum_required and project from the root.
add_executable(mylib_tests
    test_mylib.cpp
)

target_link_libraries(mylib_tests PRIVATE
    GTest::gtest_main
    mylib
)

include(GoogleTest)
gtest_discover_tests(mylib_tests)
