# 서브디렉토리 — cmake_minimum_required 와 project() 는 루트에서 상속.

# add_library() 타입 선택:
# STATIC : 컴파일 결과를 실행 파일에 직접 포함. 배포 시 별도 파일 불필요. (.lib / .a)
# SHARED : 런타임에 로드되는 별도 파일. 여러 프로세스가 공유하거나 플러그인 구조에 사용. (.dll / .so)
# 명시하지 않으면 BUILD_SHARED_LIBS 변수를 따름 (기본값 OFF = STATIC)
#
# BUILD_SHARED_LIBS 설정 방법:
#   1) 커맨드라인:         cmake --preset x64-debug -DBUILD_SHARED_LIBS=ON
#   2) CMakeLists.txt:    set(BUILD_SHARED_LIBS ON)
#   3) CMakePresets.json: "BUILD_SHARED_LIBS": "ON"
add_library(mylib STATIC
    src/mylib.cpp
)

# PUBLIC: mylib 자체 + mylib 을 링크하는 타겟 모두에 헤더 경로 전파.
#   target_link_libraries(AppWithLib PRIVATE mylib) 만 해도
#   AppWithLib 이 자동으로 mylib 의 include 경로를 가짐.
# $<BUILD_INTERFACE:...>: 빌드 시 사용하는 소스 트리 내 경로
# $<INSTALL_INTERFACE:...>: cmake --install 후 소비자가 사용하는 경로
target_include_directories(mylib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
