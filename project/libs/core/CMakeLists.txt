# 서브디렉토리 — cmake_minimum_required 와 project() 는 루트에서 상속.
# 이 파일은 add_subdirectory(libs/core) 로 포함되며,
# 여기서 정의한 'core' 타겟은 부모 CMakeLists.txt 에서 참조할 수 있음.

# add_library(STATIC): 정적 라이브러리 생성 (.lib / .a)
# 소비자 실행 파일에 직접 포함되므로 배포 시 별도 파일 불필요.
add_library(core STATIC
    src/core.cpp
)

# PUBLIC: core 자체 + core 를 링크하는 타겟 모두에 헤더 경로 전파.
#   target_link_libraries(MyApp PRIVATE core) 만 해도 MyApp 이 자동으로 include 경로를 가짐.
# $<BUILD_INTERFACE:...>: 빌드 시 사용하는 소스 트리 내 경로
# $<INSTALL_INTERFACE:...>: cmake --install 후 소비자가 사용하는 경로 (상대 경로)
target_include_directories(core PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
