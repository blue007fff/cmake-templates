# CMake Templates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Visual Studio CMake Open Folder 모드와 연동되는 C++ CMake 빌드 템플릿 3종(minimal / standard / full)을 작성한다.

**Architecture:** 각 템플릿은 `templates/<name>/` 하위에 완전 독립적으로 위치하며, 복사하면 즉시 빌드 가능하다. `CMakePresets.json`이 VS Open Folder 연동의 진입점이다. full 템플릿만 GoogleTest, install 규칙, vcpkg+FetchContent fallback, GitHub Actions CI를 포함한다.

**Tech Stack:** CMake 3.25+, C++20, Ninja, fmt 10.2.1, GoogleTest v1.14.0, GitHub Actions

---

## Prerequisites

- CMake 3.25+: `cmake --version`으로 확인
- Ninja: VS 2022 설치 시 포함, 또는 `winget install Ninja-build.Ninja`
- Visual Studio 2022 — "Desktop development with C++" 워크로드 필요

---

## 파일 맵

```
templates/
├── minimal/
│   ├── CMakeLists.txt
│   ├── CMakePresets.json
│   ├── src/main.cpp
│   └── .gitignore
├── standard/
│   ├── CMakeLists.txt
│   ├── CMakePresets.json
│   ├── cmake/deps.cmake
│   ├── src/main.cpp
│   ├── libs/mylib/CMakeLists.txt
│   ├── libs/mylib/include/mylib/mylib.h
│   ├── libs/mylib/src/mylib.cpp
│   └── .gitignore
└── full/
    ├── CMakeLists.txt
    ├── CMakePresets.json
    ├── vcpkg.json
    ├── cmake/deps.cmake
    ├── src/main.cpp
    ├── libs/core/CMakeLists.txt
    ├── libs/core/include/core/core.h
    ├── libs/core/src/core.cpp
    ├── libs/utils/CMakeLists.txt
    ├── libs/utils/include/utils/utils.h
    ├── libs/utils/src/utils.cpp
    ├── external/.gitkeep
    ├── tests/CMakeLists.txt
    ├── tests/test_main.cpp
    ├── .gitignore
    └── .github/workflows/ci.yml
```

---

## Task 1: minimal 템플릿

**Files:**
- Create: `templates/minimal/CMakeLists.txt`
- Create: `templates/minimal/CMakePresets.json`
- Create: `templates/minimal/src/main.cpp`
- Create: `templates/minimal/.gitignore`

- [ ] **Step 1: 디렉토리 생성**

```powershell
New-Item -ItemType Directory -Force templates/minimal/src
```

- [ ] **Step 2: CMakeLists.txt 작성**

`templates/minimal/CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.25)
project(MyApp VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(MyApp src/main.cpp)
```

- [ ] **Step 3: CMakePresets.json 작성**

`templates/minimal/CMakePresets.json`:
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

- [ ] **Step 4: src/main.cpp 작성**

`templates/minimal/src/main.cpp`:
```cpp
#include <iostream>

int main() {
    std::cout << "Hello, World!\n";
    return 0;
}
```

- [ ] **Step 5: .gitignore 작성**

`templates/minimal/.gitignore`:
```
build/
.vs/
CMakeUserPresets.json
*.user
out/
```

- [ ] **Step 6: 빌드 검증**

```powershell
Push-Location templates/minimal
cmake --preset x64-debug
cmake --build --preset debug
.\build\x64-debug\MyApp.exe
Pop-Location
```

기대 출력:
```
Hello, World!
```

- [ ] **Step 7: 커밋**

```powershell
git add templates/minimal
git commit -m "feat: add minimal cmake template"
```

---

## Task 2: standard 템플릿 — mylib 라이브러리

**Files:**
- Create: `templates/standard/libs/mylib/CMakeLists.txt`
- Create: `templates/standard/libs/mylib/include/mylib/mylib.h`
- Create: `templates/standard/libs/mylib/src/mylib.cpp`

- [ ] **Step 1: 디렉토리 생성**

```powershell
New-Item -ItemType Directory -Force templates/standard/libs/mylib/include/mylib
New-Item -ItemType Directory -Force templates/standard/libs/mylib/src
New-Item -ItemType Directory -Force templates/standard/cmake
New-Item -ItemType Directory -Force templates/standard/src
```

- [ ] **Step 2: mylib.h 작성**

`templates/standard/libs/mylib/include/mylib/mylib.h`:
```cpp
#pragma once

#include <string>

namespace mylib {
    std::string greet(const std::string& name);
}
```

- [ ] **Step 3: mylib.cpp 작성**

`templates/standard/libs/mylib/src/mylib.cpp`:
```cpp
#include "mylib/mylib.h"

namespace mylib {
    std::string greet(const std::string& name) {
        return "Hello, " + name + "!";
    }
}
```

- [ ] **Step 4: mylib CMakeLists.txt 작성**

`templates/standard/libs/mylib/CMakeLists.txt`:
```cmake
add_library(mylib STATIC
    src/mylib.cpp
)

target_include_directories(mylib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
```

---

## Task 3: standard 템플릿 — 루트 + 검증

**Files:**
- Create: `templates/standard/cmake/deps.cmake`
- Create: `templates/standard/CMakeLists.txt`
- Create: `templates/standard/CMakePresets.json`
- Create: `templates/standard/src/main.cpp`
- Create: `templates/standard/.gitignore`

- [ ] **Step 1: cmake/deps.cmake 작성**

`templates/standard/cmake/deps.cmake`:
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

- [ ] **Step 2: 루트 CMakeLists.txt 작성**

`templates/standard/CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.25)
project(MyApp VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(cmake/deps.cmake)

add_subdirectory(libs/mylib)

add_executable(MyApp src/main.cpp)
target_link_libraries(MyApp PRIVATE mylib fmt::fmt)
```

- [ ] **Step 3: CMakePresets.json 작성**

`templates/standard/CMakePresets.json`:
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

- [ ] **Step 4: src/main.cpp 작성**

`templates/standard/src/main.cpp`:
```cpp
#include <fmt/core.h>
#include "mylib/mylib.h"

int main() {
    fmt::print("{}\n", mylib::greet("World"));
    return 0;
}
```

- [ ] **Step 5: .gitignore 작성**

`templates/standard/.gitignore`:
```
build/
.vs/
CMakeUserPresets.json
*.user
out/
```

- [ ] **Step 6: 빌드 검증**

```powershell
Push-Location templates/standard
cmake --preset x64-debug
cmake --build --preset debug
.\build\x64-debug\MyApp.exe
Pop-Location
```

기대 출력:
```
Hello, World!
```

- [ ] **Step 7: 커밋**

```powershell
git add templates/standard
git commit -m "feat: add standard cmake template with mylib and fmt"
```

---

## Task 4: full 템플릿 — cmake 인프라 + 라이브러리 stub

**Files:**
- Create: `templates/full/cmake/deps.cmake`
- Create: `templates/full/libs/core/CMakeLists.txt`
- Create: `templates/full/libs/core/include/core/core.h`
- Create: `templates/full/libs/core/src/core.cpp`
- Create: `templates/full/libs/utils/CMakeLists.txt`
- Create: `templates/full/libs/utils/include/utils/utils.h`
- Create: `templates/full/libs/utils/src/utils.cpp`

- [ ] **Step 1: 디렉토리 생성**

```powershell
New-Item -ItemType Directory -Force templates/full/cmake
New-Item -ItemType Directory -Force templates/full/libs/core/include/core
New-Item -ItemType Directory -Force templates/full/libs/core/src
New-Item -ItemType Directory -Force templates/full/libs/utils/include/utils
New-Item -ItemType Directory -Force templates/full/libs/utils/src
New-Item -ItemType Directory -Force templates/full/external
New-Item -ItemType Directory -Force templates/full/tests
New-Item -ItemType Directory -Force templates/full/src
New-Item -ItemType File     -Force templates/full/external/.gitkeep
```

- [ ] **Step 2: cmake/deps.cmake 작성**

`templates/full/cmake/deps.cmake`:
```cmake
include(FetchContent)

# vcpkg 연동: VCPKG_ROOT 환경변수가 있으면 vcpkg 툴체인 활성화
if(DEFINED ENV{VCPKG_ROOT} AND NOT DEFINED CMAKE_TOOLCHAIN_FILE)
    set(CMAKE_TOOLCHAIN_FILE "$ENV{VCPKG_ROOT}/scripts/buildsystems/vcpkg.cmake"
        CACHE STRING "Vcpkg toolchain file")
endif()

# GoogleTest
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG        v1.14.0
)
set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
FetchContent_MakeAvailable(googletest)

# vcpkg / FetchContent 듀얼 모드 예시 (주석 해제 후 사용):
#
# find_package(fmt CONFIG QUIET)
# if(NOT fmt_FOUND)
#     FetchContent_Declare(fmt
#         GIT_REPOSITORY https://github.com/fmtlib/fmt.git
#         GIT_TAG 10.2.1)
#     FetchContent_MakeAvailable(fmt)
# endif()
```

- [ ] **Step 3: core.h 작성**

`templates/full/libs/core/include/core/core.h`:
```cpp
#pragma once

#include <string>

namespace core {
    std::string version();
}
```

- [ ] **Step 4: core.cpp stub 작성**

`templates/full/libs/core/src/core.cpp`:
```cpp
#include "core/core.h"

namespace core {
    std::string version() {
        return "";
    }
}
```

- [ ] **Step 5: core CMakeLists.txt 작성**

`templates/full/libs/core/CMakeLists.txt`:
```cmake
add_library(core STATIC
    src/core.cpp
)

target_include_directories(core PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
```

- [ ] **Step 6: utils.h 작성**

`templates/full/libs/utils/include/utils/utils.h`:
```cpp
#pragma once

#include <string>

namespace utils {
    std::string to_upper(const std::string& s);
}
```

- [ ] **Step 7: utils.cpp stub 작성**

`templates/full/libs/utils/src/utils.cpp`:
```cpp
#include "utils/utils.h"

namespace utils {
    std::string to_upper(const std::string& s) {
        return s;
    }
}
```

- [ ] **Step 8: utils CMakeLists.txt 작성**

`templates/full/libs/utils/CMakeLists.txt`:
```cmake
add_library(utils STATIC
    src/utils.cpp
)

target_include_directories(utils PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)
```

---

## Task 5: full 템플릿 — 테스트 작성 (TDD: Red)

**Files:**
- Create: `templates/full/tests/CMakeLists.txt`
- Create: `templates/full/tests/test_main.cpp`
- Create: `templates/full/CMakeLists.txt` (임시, Task 8에서 완성)
- Create: `templates/full/CMakePresets.json`

- [ ] **Step 1: tests/CMakeLists.txt 작성**

`templates/full/tests/CMakeLists.txt`:
```cmake
add_executable(tests
    test_main.cpp
)

target_link_libraries(tests PRIVATE
    GTest::gtest_main
    core
    utils
)

include(GoogleTest)
gtest_discover_tests(tests)
```

- [ ] **Step 2: test_main.cpp 작성**

`templates/full/tests/test_main.cpp`:
```cpp
#include <gtest/gtest.h>
#include "core/core.h"
#include "utils/utils.h"

TEST(CoreTest, Version) {
    EXPECT_EQ(core::version(), "0.1.0");
}

TEST(UtilsTest, ToUpperBasic) {
    EXPECT_EQ(utils::to_upper("hello"), "HELLO");
}

TEST(UtilsTest, ToUpperEmpty) {
    EXPECT_EQ(utils::to_upper(""), "");
}

TEST(UtilsTest, ToUpperMixed) {
    EXPECT_EQ(utils::to_upper("Hello World"), "HELLO WORLD");
}
```

- [ ] **Step 3: 임시 루트 CMakeLists.txt 작성**

`templates/full/CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.25)
project(MyApp VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(cmake/deps.cmake)

add_subdirectory(libs/core)
add_subdirectory(libs/utils)

option(BUILD_TESTS "Build tests" ON)
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
```

- [ ] **Step 4: CMakePresets.json 작성**

`templates/full/CMakePresets.json`:
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
    },
    {
      "name": "linux-debug",
      "displayName": "Linux Debug",
      "inherits": "base",
      "condition": {
        "type": "equals",
        "lhs": "${hostSystemName}",
        "rhs": "Linux"
      },
      "cacheVariables": { "CMAKE_BUILD_TYPE": "Debug" }
    }
  ],
  "buildPresets": [
    { "name": "debug",          "configurePreset": "x64-debug" },
    { "name": "release",        "configurePreset": "x64-release" },
    { "name": "relwithdebinfo", "configurePreset": "x64-relwithdebinfo" },
    { "name": "linux-debug",    "configurePreset": "linux-debug" }
  ],
  "testPresets": [
    {
      "name": "debug",
      "configurePreset": "x64-debug",
      "output": { "verbosity": "verbose" }
    },
    {
      "name": "linux-debug",
      "configurePreset": "linux-debug",
      "output": { "verbosity": "verbose" }
    }
  ]
}
```

- [ ] **Step 5: 테스트 실패 확인 (Red)**

```powershell
Push-Location templates/full
cmake --preset x64-debug
cmake --build --preset debug
ctest --preset debug
Pop-Location
```

기대 출력 (stub이므로 실패해야 정상):
```
[ RUN      ] CoreTest.Version
[  FAILED  ] CoreTest.Version
[ RUN      ] UtilsTest.ToUpperBasic
[  FAILED  ] UtilsTest.ToUpperBasic
```

---

## Task 6: full 템플릿 — core 구현 (TDD: Green)

**Files:**
- Modify: `templates/full/libs/core/src/core.cpp`

- [ ] **Step 1: core.cpp 구현으로 교체**

`templates/full/libs/core/src/core.cpp`:
```cpp
#include "core/core.h"

namespace core {
    std::string version() {
        return "0.1.0";
    }
}
```

- [ ] **Step 2: CoreTest 통과 확인**

```powershell
Push-Location templates/full
cmake --build --preset debug
ctest --preset debug -R CoreTest
Pop-Location
```

기대 출력:
```
[ RUN      ] CoreTest.Version
[       OK ] CoreTest.Version
[  PASSED  ] 1 test.
```

---

## Task 7: full 템플릿 — utils 구현 (TDD: Green)

**Files:**
- Modify: `templates/full/libs/utils/src/utils.cpp`

- [ ] **Step 1: utils.cpp 구현으로 교체**

`templates/full/libs/utils/src/utils.cpp`:
```cpp
#include "utils/utils.h"
#include <algorithm>
#include <cctype>

namespace utils {
    std::string to_upper(const std::string& s) {
        std::string result = s;
        std::transform(result.begin(), result.end(), result.begin(),
            [](unsigned char c) { return std::toupper(c); });
        return result;
    }
}
```

- [ ] **Step 2: 전체 테스트 통과 확인**

```powershell
Push-Location templates/full
cmake --build --preset debug
ctest --preset debug
Pop-Location
```

기대 출력:
```
[==========] Running 4 tests from 2 test suites.
[       OK ] CoreTest.Version
[       OK ] UtilsTest.ToUpperBasic
[       OK ] UtilsTest.ToUpperEmpty
[       OK ] UtilsTest.ToUpperMixed
[  PASSED  ] 4 tests.
```

---

## Task 8: full 템플릿 — 루트 완성 + main + vcpkg.json

**Files:**
- Modify: `templates/full/CMakeLists.txt` (install 규칙 + main 추가)
- Create: `templates/full/src/main.cpp`
- Create: `templates/full/vcpkg.json`
- Create: `templates/full/.gitignore`

- [ ] **Step 1: 루트 CMakeLists.txt 완성**

`templates/full/CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.25)
project(MyApp VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(cmake/deps.cmake)

add_subdirectory(libs/core)
add_subdirectory(libs/utils)

add_executable(MyApp src/main.cpp)
target_link_libraries(MyApp PRIVATE core utils)

option(BUILD_TESTS "Build tests" ON)
if(BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()

install(TARGETS MyApp RUNTIME DESTINATION bin)
install(TARGETS core utils
    ARCHIVE DESTINATION lib
    LIBRARY DESTINATION lib
)
install(DIRECTORY libs/core/include/  DESTINATION include)
install(DIRECTORY libs/utils/include/ DESTINATION include)
```

- [ ] **Step 2: src/main.cpp 작성**

`templates/full/src/main.cpp`:
```cpp
#include <iostream>
#include "core/core.h"
#include "utils/utils.h"

int main() {
    std::cout << "Version: " << core::version() << '\n';
    std::cout << utils::to_upper("hello, world!") << '\n';
    return 0;
}
```

- [ ] **Step 3: vcpkg.json 작성**

`templates/full/vcpkg.json`:
```json
{
    "name": "my-project",
    "version": "0.1.0",
    "dependencies": [
        "fmt",
        "spdlog"
    ]
}
```

- [ ] **Step 4: .gitignore 작성**

`templates/full/.gitignore`:
```
build/
.vs/
CMakeUserPresets.json
*.user
out/
```

- [ ] **Step 5: Release 빌드 + 실행 검증**

```powershell
Push-Location templates/full
cmake --preset x64-release
cmake --build --preset release
.\build\x64-release\MyApp.exe
Pop-Location
```

기대 출력:
```
Version: 0.1.0
HELLO, WORLD!
```

- [ ] **Step 6: 전체 테스트 재확인**

```powershell
Push-Location templates/full
cmake --build --preset debug
ctest --preset debug
Pop-Location
```

기대 출력:
```
[  PASSED  ] 4 tests.
```

- [ ] **Step 7: 커밋**

```powershell
git add templates/full
git commit -m "feat: add full cmake template with tests and install rules"
```

---

## Task 9: GitHub Actions CI

**Files:**
- Create: `templates/full/.github/workflows/ci.yml`

- [ ] **Step 1: .github/workflows 디렉토리 생성**

```powershell
New-Item -ItemType Directory -Force "templates/full/.github/workflows"
```

- [ ] **Step 2: ci.yml 작성**

`templates/full/.github/workflows/ci.yml`:
```yaml
name: CI

on:
  push:
    branches: ["**"]
  pull_request:
    branches: ["**"]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Install Ninja
        run: sudo apt-get install -y ninja-build

      - name: Configure
        run: cmake --preset linux-debug

      - name: Build
        run: cmake --build --preset linux-debug

      - name: Test
        run: ctest --preset linux-debug
```

- [ ] **Step 3: CI 파일이 포함된 상태로 커밋**

```powershell
git add "templates/full/.github"
git commit -m "feat: add github actions ci to full template"
```

- [ ] **Step 4: GitHub에 push 후 Actions 탭 확인**

```powershell
git push origin main
```

GitHub 저장소 → Actions 탭에서 워크플로우가 트리거되고 통과하는지 확인.  
`build` 잡이 ✅ 초록불이면 완료.
