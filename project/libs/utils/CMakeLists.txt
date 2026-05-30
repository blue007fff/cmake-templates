# 서브디렉토리 — cmake_minimum_required 와 project() 는 루트에서 상속.
# 이 파일은 add_subdirectory(libs/utils) 로 포함되며,
# 여기서 정의한 'utils' 타겟은 부모 CMakeLists.txt 에서 참조할 수 있음.

add_library(utils STATIC
    src/utils.cpp
)

# PUBLIC: utils 자체 + utils 를 링크하는 타겟 모두에 헤더 경로 전파.
# $<BUILD_INTERFACE:...>: 빌드 시 사용하는 소스 트리 내 경로
# $<INSTALL_INTERFACE:...>: cmake --install 후 소비자가 사용하는 경로 (상대 경로)
target_include_directories(utils PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
