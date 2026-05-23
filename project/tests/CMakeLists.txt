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
# 빌드 후 테스트 실행 파일을 실행해 TEST 목록을 자동 등록 — ctest 와 VS Test Explorer 에서 개별 테스트가 보임
gtest_discover_tests(project_tests)
