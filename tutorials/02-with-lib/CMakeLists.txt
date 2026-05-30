# ── tutorial 02: 내부 라이브러리 사용 ────────────────────────
# 프로젝트를 실행 파일(AppWithLib)과 라이브러리(mylib)로 분리하는 구조.
# 코드를 라이브러리로 분리하면:
#   - 테스트 작성이 용이 (라이브러리만 독립적으로 테스트 가능)
#   - 여러 실행 파일이 같은 라이브러리를 공유 가능
cmake_minimum_required(VERSION 3.25)
project(AppWithLib VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# add_subdirectory(): libs/mylib/CMakeLists.txt 를 읽어 mylib 타겟 생성.
# mylib 타겟은 이 파일에서도 참조 가능.
add_subdirectory(libs/mylib)

add_executable(AppWithLib src/main.cpp)

# target_link_libraries(): 실행 파일에 라이브러리 연결.
# PRIVATE: AppWithLib 빌드에만 필요. 소비자에게 전파 안 함.
# mylib 의 PUBLIC include 경로가 자동으로 AppWithLib 에도 전파됨.
target_link_libraries(AppWithLib PRIVATE mylib)
