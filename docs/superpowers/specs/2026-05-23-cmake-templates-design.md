# CMake Templates 설계 문서

**날짜:** 2026-05-23  
**상태:** 승인됨

---

## 최종 디렉토리 구조

```
cmake-templates/
├── project/          ← 외부 의존성 + 테스트 + CI 갖춘 완성형 앱
├── library/          ← find_package() 지원 배포용 라이브러리
├── scratch/          ← 각 .cpp → 별도 exe (실험/연습용)
└── tutorials/        ← CMake 개념을 단계별로 학습
    ├── 01-hello/     ← CMake 기본 구조
    ├── 02-with-lib/  ← 내부 라이브러리 분리
    └── 03-with-deps/ ← 외부 의존성 (FetchContent)
```

- **project / library / scratch** — 실제 프로젝트에 복사해서 쓰는 템플릿
- **tutorials/** — 개념을 순서대로 학습하는 자료

---

## 공통 스펙

| 항목 | 값 |
|---|---|
| C++ 표준 | C++20 |
| CMake 최소 버전 | 3.25 |
| VS 연동 방식 | CMakePresets.json (Open Folder 모드) |
| 빌드 generator | Ninja |
| 빌드 출력 경로 | `build/{presetName}/` |
| compile_commands | ON (clangd/LSP 지원) |

### CMakePresets.json base (공통)

```json
{
  "version": 3,
  "configurePresets": [
    {
      "name": "base",
      "hidden": true,
      "generator": "Ninja",
      "binaryDir": "${sourceDir}/build/${presetName}",
      "cacheVariables": {
        "CMAKE_CXX_STANDARD": "20",
        "CMAKE_CXX_STANDARD_REQUIRED": "ON",
        "CMAKE_EXPORT_COMPILE_COMMANDS": "ON"
      }
    },
    {
      "name": "x64-debug",
      "displayName": "x64 Debug",
      "inherits": "base",
      "cacheVariables": { "CMAKE_BUILD_TYPE": "Debug" }
    },
    {
      "name": "x64-release",
      "displayName": "x64 Release",
      "inherits": "base",
      "cacheVariables": { "CMAKE_BUILD_TYPE": "Release" }
    },
    {
      "name": "x64-relwithdebinfo",
      "displayName": "x64 RelWithDebInfo",
      "inherits": "base",
      "cacheVariables": { "CMAKE_BUILD_TYPE": "RelWithDebInfo" }
    }
  ],
  "buildPresets": [
    { "name": "debug",          "configurePreset": "x64-debug" },
    { "name": "release",        "configurePreset": "x64-release" },
    { "name": "relwithdebinfo", "configurePreset": "x64-relwithdebinfo" }
  ]
}
```

### .gitignore (공통)

```
build/
.vs/
CMakeUserPresets.json
*.user
out/
```

---

## tutorials/01-hello

### 목적
CMake 가장 기본 구조. 실행파일 하나, 외부 의존성 없음.

### 가르치는 개념
- `cmake_minimum_required`, `project`, `add_executable`
- CMakePresets.json 기반 VS Open Folder 연동
- Debug / Release / RelWithDebInfo 프리셋

### 디렉토리 구조
```
01-hello/
├── CMakeLists.txt
├── CMakePresets.json
├── src/
│   └── main.cpp
└── .gitignore
```

### CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.25)
project(Hello VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(Hello src/main.cpp)
```

---

## tutorials/02-with-lib

### 목적
코드를 내부 라이브러리와 실행파일로 분리하는 구조.

### 가르치는 개념
- `add_library`, `target_include_directories`, `target_link_libraries`
- `add_subdirectory`로 라이브러리 구성
- `BUILD_INTERFACE` / `INSTALL_INTERFACE` generator expression

### 디렉토리 구조
```
02-with-lib/
├── CMakeLists.txt
├── CMakePresets.json
├── src/
│   └── main.cpp
├── libs/
│   └── mylib/
│       ├── CMakeLists.txt
│       ├── include/
│       │   └── mylib/
│       │       └── mylib.h
│       └── src/
│           └── mylib.cpp
└── .gitignore
```

### 의존성
없음 (CMake 내장 기능만 사용).

---

## tutorials/03-with-deps

### 목적
FetchContent로 외부 라이브러리를 가져오는 방법.

### 가르치는 개념
- `FetchContent_Declare` / `FetchContent_MakeAvailable`
- `cmake/deps.cmake`로 의존성 선언 분리
- `target_link_libraries`로 외부 타깃 연결

### 디렉토리 구조
```
03-with-deps/
├── CMakeLists.txt
├── CMakePresets.json
├── cmake/
│   └── deps.cmake          ← fmt FetchContent
├── src/
│   └── main.cpp            ← fmt::print 사용
└── .gitignore
```

### cmake/deps.cmake
```cmake
include(FetchContent)

FetchContent_Declare(
    fmt
    GIT_REPOSITORY https://github.com/fmtlib/fmt.git
    GIT_TAG        10.2.1
)
FetchContent_MakeAvailable(fmt)

# 추가 라이브러리 예시 (주석 해제 후 사용):
#
# FetchContent_Declare(
#   spdlog
#   GIT_REPOSITORY https://github.com/gabime/spdlog.git
#   GIT_TAG        v1.13.0
# )
# FetchContent_MakeAvailable(spdlog)
```

### 의존성
- fmt 10.2.1 (FetchContent 자동 취득)

---

## scratch

### 목적
같은 폴더의 각 .cpp 파일이 별도 실행파일로 빌드됨. 알고리즘 연습, 기능 실험용.

### 가르치는 개념
- `file(GLOB ...)` + `foreach`로 자동 타깃 생성

### 디렉토리 구조
```
scratch/
├── CMakeLists.txt
├── CMakePresets.json
├── example1.cpp
├── example2.cpp
└── .gitignore
```

### CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.25)
project(Scratch LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

file(GLOB SOURCES "*.cpp")
foreach(SOURCE ${SOURCES})
    get_filename_component(TARGET_NAME ${SOURCE} NAME_WE)
    add_executable(${TARGET_NAME} ${SOURCE})
endforeach()
```

---

## library

### 목적
다른 CMake 프로젝트가 `find_package(MyLib)`로 가져다 쓸 수 있는 배포용 라이브러리.

### 가르치는 개념
- `install(EXPORT ...)` + `MyLibConfig.cmake.in`
- `configure_package_config_file` / `write_basic_package_version_file`
- 네임스페이스 타깃 (`MyLib::mylib`)
- GoogleTest로 라이브러리 자체 테스트
- GitHub Actions CI

### 디렉토리 구조
```
library/
├── CMakeLists.txt
├── CMakePresets.json
├── cmake/
│   └── MyLibConfig.cmake.in
├── include/
│   └── mylib/
│       └── mylib.h
├── src/
│   └── mylib.cpp
├── tests/
│   ├── CMakeLists.txt
│   └── test_mylib.cpp
├── .github/
│   └── workflows/
│       └── ci.yml
└── .gitignore
```

### install / export 구조
```cmake
install(TARGETS mylib
    EXPORT MyLibTargets
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)
install(EXPORT MyLibTargets
    FILE       MyLibTargets.cmake
    NAMESPACE  MyLib::
    DESTINATION lib/cmake/MyLib
)
configure_package_config_file(
    cmake/MyLibConfig.cmake.in
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake
    INSTALL_DESTINATION lib/cmake/MyLib
)
write_basic_package_version_file(
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake
    VERSION ${PROJECT_VERSION}
    COMPATIBILITY SameMajorVersion
)
install(FILES
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfig.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/MyLibConfigVersion.cmake
    DESTINATION lib/cmake/MyLib
)
install(DIRECTORY include/ DESTINATION include)
```

### MyLibConfig.cmake.in
```cmake
@PACKAGE_INIT@

include("${CMAKE_CURRENT_LIST_DIR}/MyLibTargets.cmake")
check_required_components(MyLib)
```

### 소비자 프로젝트에서의 사용 예시
```cmake
find_package(MyLib REQUIRED)
target_link_libraries(MyApp PRIVATE MyLib::mylib)
```

### 테스트
- GoogleTest v1.14.0 (FetchContent)
- `BUILD_TESTS` 옵션으로 on/off

### GitHub Actions CI
- ubuntu-latest, linux-debug 프리셋 사용

### 의존성
- GoogleTest v1.14.0 (FetchContent, 테스트 빌드 시만)

---

## project

### 목적
외부 의존성 + 테스트 + CI를 갖춘 완성형 애플리케이션 프로젝트.

### 디렉토리 구조
```
project/
├── CMakeLists.txt
├── CMakePresets.json
├── vcpkg.json
├── cmake/
│   └── deps.cmake          ← vcpkg 확인 → FetchContent fallback + GoogleTest
├── src/
│   └── main.cpp
├── libs/
│   ├── core/
│   │   ├── CMakeLists.txt
│   │   ├── include/core/core.h
│   │   └── src/core.cpp
│   └── utils/
│       ├── CMakeLists.txt
│       ├── include/utils/utils.h
│       └── src/utils.cpp
├── external/
│   └── .gitkeep
├── tests/
│   ├── CMakeLists.txt
│   └── test_main.cpp
├── .github/
│   └── workflows/
│       └── ci.yml
└── .gitignore
```

### vcpkg 연동
```cmake
if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
        CACHE STRING "Vcpkg toolchain file")
endif()
```

### 테스트 (GoogleTest v1.14.0)
- `BUILD_TESTS` 옵션으로 on/off
- `gtest_discover_tests()`로 VS Test Explorer 자동 연동

### install 규칙
```cmake
install(TARGETS MyApp RUNTIME DESTINATION bin)
install(TARGETS core utils ARCHIVE DESTINATION lib LIBRARY DESTINATION lib)
install(DIRECTORY libs/core/include/  DESTINATION include)
install(DIRECTORY libs/utils/include/ DESTINATION include)
```

### GitHub Actions CI
- ubuntu-latest, linux-debug 프리셋 사용
- CMakePresets.json에 `linux-debug` 프리셋 포함 (condition: Linux only)

### 의존성
- vcpkg (선택, 없으면 FetchContent fallback)
- GoogleTest v1.14.0 (FetchContent 자동 취득)

---

## 구현 범위 외

- CPack / NSIS 패키징
- clang-tidy, CPM.cmake
- Linux / macOS 전용 로컬 설정 (CI용 linux-debug 프리셋은 포함)
