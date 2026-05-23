# Subdirectory — inherits cmake_minimum_required and project from the root.
add_executable(mylib_tests
    test_mylib.cpp
)

target_link_libraries(mylib_tests PRIVATE
    GTest::gtest_main
    mylib
)

include(GoogleTest)
# 빌드 후 테스트 실행 파일을 실행해 TEST 목록을 자동 등록 — ctest 와 VS Test Explorer 에서 개별 테스트가 보임
gtest_discover_tests(mylib_tests)
