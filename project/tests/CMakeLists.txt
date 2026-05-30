# 서브디렉토리 — cmake_minimum_required 와 project() 는 루트에서 상속.
# googletest 는 루트 CMakeLists.txt 의 FetchContent_MakeAvailable(googletest) 로 이미 준비됨.

# 테스트 실행 파일 생성. 여러 테스트 파일이 있으면 모두 나열.
add_executable(project_tests
    test_main.cpp
)

# GTest::gtest_main: main() 함수를 자동 제공하는 googletest 타겟.
#   직접 main() 을 작성하려면 GTest::gtest 를 사용.
# core, utils: 테스트 대상 라이브러리 — 헤더 경로와 링크가 자동 전파됨.
target_link_libraries(project_tests PRIVATE
    GTest::gtest_main
    core
    utils
)

# include(GoogleTest): gtest_discover_tests() 함수를 제공하는 CMake 내장 모듈.
include(GoogleTest)

# gtest_discover_tests(): 빌드 후 실행 파일을 실행해 TEST() 목록을 자동 등록.
#   → ctest, VS Test Explorer, CLion 등에서 테스트가 개별 항목으로 보임.
#   gtest_add_tests() 보다 권장: 실제 실행 결과 기반이라 더 정확함.
gtest_discover_tests(project_tests)
