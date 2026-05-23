# Subdirectory — inherits cmake_minimum_required and project from the root.

# STATIC  : 컴파일 결과를 실행 파일에 직접 포함. 배포 시 별도 파일 불필요. (mylib.lib / libmylib.a)
# SHARED  : 런타임에 로드되는 별도 파일. 여러 프로세스가 공유하거나 플러그인 구조에 사용. (mylib.dll / libmylib.so)
# 명시하지 않으면 BUILD_SHARED_LIBS 변수를 따름 (기본값 OFF = STATIC)
#
# BUILD_SHARED_LIBS 설정 방법:
#   1) 커맨드라인 : cmake --preset x64-debug -DBUILD_SHARED_LIBS=ON
#   2) CMakeLists.txt 상단에 기본값 지정:
#        set(BUILD_SHARED_LIBS OFF)  # 또는 ON
#   3) CMakePresets.json cacheVariables:
#        "BUILD_SHARED_LIBS": "ON"
add_library(mylib STATIC
    src/mylib.cpp
)

target_include_directories(mylib PUBLIC
    # BUILD_INTERFACE: path used when building this project
    # INSTALL_INTERFACE: path used after install() — see the library/ template for install rules
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
