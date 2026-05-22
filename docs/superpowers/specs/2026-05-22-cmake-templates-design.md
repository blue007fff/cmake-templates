# CMake Templates 설계 문서

**날짜:** 2026-05-22  
**상태:** 승인됨  
**기반:** 2026-05-19 설계 (opengl 제외, 3개 수정사항 반영)

---

## 개요

Visual Studio CMake Open Folder 모드와 연동 가능한 C++ CMake 빌드 템플릿 3종.  
각 템플릿은 독립적으로 복사해 즉시 사용 가능하도록 설계.

- **minimal** — 단일 실행파일, 외부 의존성 없음
- **standard** — 내 라이브러리 + 실행파일, FetchContent로 fmt 연동
- **full** — 멀티 라이브러리 + 테스트 + vcpkg 우선 / FetchContent fallback

---

## 이전 스펙 대비 변경사항

| # | 변경 | 적용 범위 |
|---|---|---|
| 1 | `CMAKE_EXPORT_COMPILE_COMMANDS: ON` 추가 (clangd/LSP 지원) | 전체 base preset |
| 2 | CPack + NSIS 제거, `install()` 규칙만 유지 | full |
| 3 | `deps.cmake`에 fmt를 실제 동작하는 FetchContent 예시로 포함 | standard |

---

## 공통 스펙

| 항목 | 값 |
|---|---|
| C++ 표준 | C++20 (`CMAKE_CXX_STANDARD_REQUIRED ON`) |
| CMake 최소 버전 | 3.25 |
| VS 연동 방식 | CMakePresets.json (Open Folder 모드) |
| 빌드 generator | Ninja |
| 빌드 출력 경로 | `build/{presetName}/` |
| compile_commands | ON (clangd/LSP 지원) |

---

## CMakePresets.json 공통 설계

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

---

## .gitignore (공통)

```
build/
.vs/
CMakeUserPresets.json
*.user
out/
```

---

## 1. minimal

### 목적
가장 단순한 시작점. 외부 의존성 없이 실행파일 하나만 빌드.

### 디렉토리 구조
```
minimal/
├── CMakeLists.txt
├── CMakePresets.json
├── src/
│   └── main.cpp
└── .gitignore
```

### CMakeLists.txt
```cmake
cmake_minimum_required(VERSION 3.25)
project(MyApp VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(MyApp src/main.cpp)
```

### 의존성
없음.

---

## 2. standard

### 목적
내가 만든 라이브러리와 실행파일을 분리. fmt를 FetchContent로 가져오는 실제 동작 예시 포함.

### 디렉토리 구조
```
standard/
├── CMakeLists.txt
├── CMakePresets.json
├── cmake/
│   └── deps.cmake          ← fmt FetchContent (실제 동작)
├── src/
│   └── main.cpp            ← fmt::print 사용
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

### CMakeLists.txt 구조
```cmake
root CMakeLists.txt
  ├── include(cmake/deps.cmake)
  ├── add_subdirectory(libs/mylib)
  └── add_executable(MyApp ...) + target_link_libraries(MyApp PRIVATE mylib fmt::fmt)
```

### 의존성
- fmt 10.2.1 (FetchContent 자동 취득)

---

## 3. full

### 목적
GitHub에 올릴 수 있는 완성형 프로젝트 구조.  
멀티 라이브러리, GoogleTest, vcpkg 우선 + FetchContent fallback.

### 디렉토리 구조
```
full/
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
│   │   ├── include/core/
│   │   └── src/
│   └── utils/
│       ├── CMakeLists.txt
│       ├── include/utils/
│       └── src/
├── external/
│   └── .gitkeep
├── tests/
│   ├── CMakeLists.txt
│   └── test_main.cpp
└── .gitignore
```

### vcpkg 연동 방식
`cmake/deps.cmake`에서 처리:
```cmake
if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
  set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake" CACHE STRING "")
endif()
```
- `VCPKG_ROOT` 환경변수가 있으면 vcpkg 사용
- 없으면 FetchContent로 자동 fallback

### vcpkg.json
fmt, spdlog를 예시 패키지로 포함 (사용자가 교체/추가).

### 테스트 (GoogleTest)
- GoogleTest v1.14.0을 FetchContent로 가져옴
- `BUILD_TESTS` 옵션으로 on/off 제어
- `gtest_discover_tests()`로 VS Test Explorer 자동 연동

### CMakePresets.json
공통 설계에 testPreset 추가:
```json
"testPresets": [
  { "name": "debug", "configurePreset": "x64-debug", "output": { "verbosity": "verbose" } }
]
```

### install 규칙
```cmake
install(TARGETS MyApp RUNTIME DESTINATION bin)
install(TARGETS core utils
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)
install(DIRECTORY libs/core/include/  DESTINATION include)
install(DIRECTORY libs/utils/include/ DESTINATION include)
```

CPack / NSIS — **포함하지 않음** (필요 시 나중에 추가).

### 의존성
- vcpkg (선택, 없으면 FetchContent fallback)
- GoogleTest v1.14.0 (FetchContent 자동 취득)

---

## 구현 범위 외

- Linux / macOS 전용 설정
- CI/CD (GitHub Actions workflow)
- CPack / NSIS 패키징
