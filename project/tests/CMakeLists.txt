# Subdirectory — inherits cmake_minimum_required and project from the root.
add_executable(project_tests
    test_main.cpp
)

target_link_libraries(project_tests PRIVATE
    GTest::gtest_main
    core
    utils
)

include(GoogleTest)
gtest_discover_tests(project_tests)
