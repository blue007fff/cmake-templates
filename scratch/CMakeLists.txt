# scratch/ : 빠른 코드 실험용 샌드박스.
# 이 디렉토리의 .cpp 파일 하나가 독립 실행 파일 하나가 됨.
# 예: hello.cpp → ./build/x64-debug/hello.exe
cmake_minimum_required(VERSION 3.25)
project(Scratch LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# file(GLOB ... CONFIGURE_DEPENDS): 패턴에 맞는 파일 목록을 변수에 저장.
# CONFIGURE_DEPENDS: 파일이 추가/삭제되면 다음 빌드 시 CMake 자동 재구성.
#   (CMake 3.12+. 모든 빌드 툴에서 완벽하게 감지하지는 않을 수 있음)
# 일반적으로 file(GLOB) 은 권장하지 않지만,
# 파일이 계속 바뀌는 sandbox 에서는 예외적으로 편의성을 위해 사용.
file(GLOB SOURCES CONFIGURE_DEPENDS "*.cpp")

# IN LISTS: 리스트 변수를 명시적으로 순회 (CMake 권장 방식)
foreach(SOURCE IN LISTS SOURCES)
    # NAME_WE: Name Without Extension — 확장자 제거한 파일명
    # 예: /path/to/hello.cpp → TARGET_NAME = hello
    get_filename_component(TARGET_NAME "${SOURCE}" NAME_WE)
    # 따옴표: 파일 경로에 공백이 있어도 단일 인자로 처리
    add_executable("${TARGET_NAME}" "${SOURCE}")
endforeach()
