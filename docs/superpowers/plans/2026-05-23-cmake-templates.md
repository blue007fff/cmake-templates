# CMake Templates Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** CMake 학습용 튜토리얼 3종(01-hello / 02-with-lib / 03-with-deps)과 실용 템플릿 3종(project / library / scratch)을 작성한다.

**Architecture:** 튜토리얼은 `tutorials/` 하위에 번호 순서로, 실용 템플릿은 루트에 위치. 각 템플릿은 독립적으로 복사해 즉시 빌드 가능. `CMakePresets.json`이 VS Open Folder 연동의 진입점.

**Tech Stack:** CMake 3.25+, C++20, Ninja, fmt 10.2.1, GoogleTest v1.14.0, GitHub Actions

---

## Prerequisites

- CMake 3.25+: `cmake --version` 으로 확인
- Ninja: VS 2022 설치 시 포함, 또는 `winget install Ninja-build.Ninja`
- Visual Studio 2022 — "Desktop development with C++" 워크로드 필요

---

## 파일 맵

```
tutorials/
├── 01-hello/
│   ├── CMakeLists.txt
│   ├── CMakePresets.json
│   ├── src/main.cpp
│   └── .gitignore
├── 02-with-lib/
│   ├── CMakeLists.txt
│   ├── CMakePresets.json
│   ├── src/main.cpp
│   ├── libs/mylib/CMakeLists.txt
│   ├── libs/mylib/include/mylib/mylib.h
│   ├── libs/mylib/src/mylib.cpp
│   └── .gitignore
└── 03-with-deps/
    ├── CMakeLists.txt
    ├── CMakePresets.json
    ├── cmake/deps.cmake
    ├── src/main.cpp
    └── .gitignore

scratch/
├── CMakeLists.txt
├── CMakePresets.json
├── example1.cpp
├── example2.cpp
└── .gitignore

library/
├── CMakeLists.txt
├── CMakePresets.json
├── cmake/MyLibConfig.cmake.in
├── include/mylib/mylib.h
├── src/mylib.cpp
├── tests/CMakeLists.txt
├── tests/test_mylib.cpp
├── .github/workflows/ci.yml
└── .gitignore

project/
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
├── .github/workflows/ci.yml
└── .gitignore
```

---

## Task 1: tutorials/01-hello

**Files:**
- Create: `tutorials/01-hello/CMakeLists.txt`
- Create: `tutorials/01-hello/CMakePresets.json`
- Create: `tutorials/01-hello/src/main.cpp`
- Create: `tutorials/01-hello/.gitignore`

- [ ] **Step 1: 디렉토리 생성**

```powershell
New-Item -ItemType Directory -Force tutorials/01-hello/src
```

- [ ] **Step 2: CMakeLists.txt 작성**

`tutorials/01-hello/CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.25)
project(Hello VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(Hello src/main.cpp)
```

- [ ] **Step 3: CMakePresets.json 작성**

`tutorials/01-hello/CMakePresets.json`:
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

`tutorials/01-hello/src/main.cpp`:
```cpp
#include <iostream>

int main() {
    std::cout << "Hello, World!\n";
    return 0;
}
```

- [ ] **Step 5: .gitignore 작성**

`tutorials/01-hello/.gitignore`:
```
build/
.vs/
CMakeUserPresets.json
*.user
out/
```

- [ ] **Step 6: 빌드 검증**

```powershell
Push-Location tutorials/01-hello
cmake --preset x64-debug
cmake --build --preset debug
.\build\x64-debug\Hello.exe
Pop-Location
```

기대 출력:
```
Hello, World!
```

- [ ] **Step 7: 커밋**

```powershell
git add tutorials/01-hello
git commit -m "feat: add 01-hello tutorial"
```

---

## Task 2: tutorials/02-with-lib — mylib 라이브러리

**Files:**
- Create: `tutorials/02-with-lib/libs/mylib/CMakeLists.txt`
- Create: `tutorials/02-with-lib/libs/mylib/include/mylib/mylib.h`
- Create: `tutorials/02-with-lib/libs/mylib/src/mylib.cpp`

- [ ] **Step 1: 디렉토리 생성**

```powershell
New-Item -ItemType Directory -Force tutorials/02-with-lib/libs/mylib/include/mylib
New-Item -ItemType Directory -Force tutorials/02-with-lib/libs/mylib/src
New-Item -ItemType Directory -Force tutorials/02-with-lib/src
```

- [ ] **Step 2: mylib.h 작성**

`tutorials/02-with-lib/libs/mylib/include/mylib/mylib.h`:
```cpp
#pragma once

#include <string>

namespace mylib {
    std::string greet(const std::string& name);
}
```

- [ ] **Step 3: mylib.cpp 작성**

`tutorials/02-with-lib/libs/mylib/src/mylib.cpp`:
```cpp
#include "mylib/mylib.h"

namespace mylib {
    std::string greet(const std::string& name) {
        return "Hello, " + name + "!";
    }
}
```

- [ ] **Step 4: mylib CMakeLists.txt 작성**

`tutorials/02-with-lib/libs/mylib/CMakeLists.txt`:
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

## Task 3: tutorials/02-with-lib — 루트 + 검증

**Files:**
- Create: `tutorials/02-with-lib/CMakeLists.txt`
- Create: `tutorials/02-with-lib/CMakePresets.json`
- Create: `tutorials/02-with-lib/src/main.cpp`
- Create: `tutorials/02-with-lib/.gitignore`

- [ ] **Step 1: 루트 CMakeLists.txt 작성**

`tutorials/02-with-lib/CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.25)
project(AppWithLib VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_subdirectory(libs/mylib)

add_executable(AppWithLib src/main.cpp)
target_link_libraries(AppWithLib PRIVATE mylib)
```

- [ ] **Step 2: CMakePresets.json 작성**

`tutorials/02-with-lib/CMakePresets.json`:
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

- [ ] **Step 3: src/main.cpp 작성**

`tutorials/02-with-lib/src/main.cpp`:
```cpp
#include <iostream>
#include "mylib/mylib.h"

int main() {
    std::cout << mylib::greet("World") << '\n';
    return 0;
}
```

- [ ] **Step 4: .gitignore 작성**

`tutorials/02-with-lib/.gitignore`:
```
build/
.vs/
CMakeUserPresets.json
*.user
out/
```

- [ ] **Step 5: 빌드 검증**

```powershell
Push-Location tutorials/02-with-lib
cmake --preset x64-debug
cmake --build --preset debug
.\build\x64-debug\AppWithLib.exe
Pop-Location
```

기대 출력:
```
Hello, World!
```

- [ ] **Step 6: 커밋**

```powershell
git add tutorials/02-with-lib
git commit -m "feat: add 02-with-lib tutorial"
```

---

## Task 4: tutorials/03-with-deps

**Files:**
- Create: `tutorials/03-with-deps/cmake/deps.cmake`
- Create: `tutorials/03-with-deps/CMakeLists.txt`
- Create: `tutorials/03-with-deps/CMakePresets.json`
- Create: `tutorials/03-with-deps/src/main.cpp`
- Create: `tutorials/03-with-deps/.gitignore`

- [ ] **Step 1: 디렉토리 생성**

```powershell
New-Item -ItemType Directory -Force tutorials/03-with-deps/cmake
New-Item -ItemType Directory -Force tutorials/03-with-deps/src
```

- [ ] **Step 2: cmake/deps.cmake 작성**

`tutorials/03-with-deps/cmake/deps.cmake`:
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

- [ ] **Step 3: CMakeLists.txt 작성**

`tutorials/03-with-deps/CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.25)
project(WithDeps VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

include(cmake/deps.cmake)

add_executable(WithDeps src/main.cpp)
target_link_libraries(WithDeps PRIVATE fmt::fmt)
```

- [ ] **Step 4: CMakePresets.json 작성**

`tutorials/03-with-deps/CMakePresets.json`:
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

- [ ] **Step 5: src/main.cpp 작성**

`tutorials/03-with-deps/src/main.cpp`:
```cpp
#include <fmt/core.h>

int main() {
    fmt::print("Hello, {}!\n", "World");
    return 0;
}
```

- [ ] **Step 6: .gitignore 작성**

`tutorials/03-with-deps/.gitignore`:
```
build/
.vs/
CMakeUserPresets.json
*.user
out/
```

- [ ] **Step 7: 빌드 검증**

```powershell
Push-Location tutorials/03-with-deps
cmake --preset x64-debug
cmake --build --preset debug
.\build\x64-debug\WithDeps.exe
Pop-Location
```

기대 출력:
```
Hello, World!
```

- [ ] **Step 8: 커밋**

```powershell
git add tutorials/03-with-deps
git commit -m "feat: add 03-with-deps tutorial"
```

---

## Task 5: scratch

**Files:**
- Create: `scratch/CMakeLists.txt`
- Create: `scratch/CMakePresets.json`
- Create: `scratch/example1.cpp`
- Create: `scratch/example2.cpp`
- Create: `scratch/.gitignore`

- [ ] **Step 1: 디렉토리 생성**

```powershell
New-Item -ItemType Directory -Force scratch
```

- [ ] **Step 2: CMakeLists.txt 작성**

`scratch/CMakeLists.txt`:
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

- [ ] **Step 3: CMakePresets.json 작성**

`scratch/CMakePresets.json`:
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

- [ ] **Step 4: example1.cpp 작성**

`scratch/example1.cpp`:
```cpp
#include <iostream>

int main() {
    std::cout << "example1\n";
    return 0;
}
```

- [ ] **Step 5: example2.cpp 작성**

`scratch/example2.cpp`:
```cpp
#include <iostream>

int main() {
    std::cout << "example2\n";
    return 0;
}
```

- [ ] **Step 6: .gitignore 작성**

`scratch/.gitignore`:
```
build/
.vs/
CMakeUserPresets.json
*.user
out/
```

- [ ] **Step 7: 빌드 검증 — 두 exe 모두 생성되는지 확인**

```powershell
Push-Location scratch
cmake --preset x64-debug
cmake --build --preset debug
.\build\x64-debug\example1.exe
.\build\x64-debug\example2.exe
Pop-Location
```

기대 출력:
```
example1
example2
```

- [ ] **Step 8: 커밋**

```powershell
git add scratch
git commit -m "feat: add scratch template"
```

---

## Task 6: library — 라이브러리 본체 + stub

**Files:**
- Create: `library/cmake/MyLibConfig.cmake.in`
- Create: `library/include/mylib/mylib.h`
- Create: `library/src/mylib.cpp`

- [ ] **Step 1: 디렉토리 생성**

```powershell
New-Item -ItemType Directory -Force library/cmake
New-Item -ItemType Directory -Force library/include/mylib
New-Item -ItemType Directory -Force library/src
New-Item -ItemType Directory -Force library/tests
New-Item -ItemType Directory -Force "library/.github/workflows"
```

- [ ] **Step 2: mylib.h 작성**

`library/include/mylib/mylib.h`:
```cpp
#pragma once

#include <string>

namespace mylib {
    std::string greet(const std::string& name);
}
```

- [ ] **Step 3: mylib.cpp stub 작성**

`library/src/mylib.cpp`:
```cpp
#include "mylib/mylib.h"

namespace mylib {
    std::string greet(const std::string& name) {
        return "";
    }
}
```

- [ ] **Step 4: MyLibConfig.cmake.in 작성**

`library/cmake/MyLibConfig.cmake.in`:
```cmake
@PACKAGE_INIT@

include("${CMAKE_CURRENT_LIST_DIR}/MyLibTargets.cmake")
check_required_components(MyLib)
```

---

## Task 7: library — 테스트 작성 (TDD: Red)

**Files:**
- Create: `library/tests/CMakeLists.txt`
- Create: `library/tests/test_mylib.cpp`
- Create: `library/CMakeLists.txt`
- Create: `library/CMakePresets.json`

- [ ] **Step 1: tests/CMakeLists.txt 작성**

`library/tests/CMakeLists.txt`:
```cmake
add_executable(tests
    test_mylib.cpp
)

target_link_libraries(tests PRIVATE
    GTest::gtest_main
    mylib
)

include(GoogleTest)
gtest_discover_tests(tests)
```

- [ ] **Step 2: test_mylib.cpp 작성**

`library/tests/test_mylib.cpp`:
```cpp
#include <gtest/gtest.h>
#include "mylib/mylib.h"

TEST(MyLibTest, GreetBasic) {
    EXPECT_EQ(mylib::greet("World"), "Hello, World!");
}

TEST(MyLibTest, GreetEmpty) {
    EXPECT_EQ(mylib::greet(""), "Hello, !");
}

TEST(MyLibTest, GreetName) {
    EXPECT_EQ(mylib::greet("CMake"), "Hello, CMake!");
}
```

- [ ] **Step 3: CMakeLists.txt 작성**

`library/CMakeLists.txt`:
```cmake
cmake_minimum_required(VERSION 3.25)
project(MyLib VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_library(mylib STATIC
    src/mylib.cpp
)

target_include_directories(mylib PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

option(BUILD_TESTS "Build tests" ON)
if(BUILD_TESTS)
    include(FetchContent)
    FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG        v1.14.0
    )
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
    FetchContent_MakeAvailable(googletest)

    enable_testing()
    add_subdirectory(tests)
endif()

include(CMakePackageConfigHelpers)

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

- [ ] **Step 4: CMakePresets.json 작성**

`library/CMakePresets.json`:
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
Push-Location library
cmake --preset x64-debug
cmake --build --preset debug
ctest --preset debug
Pop-Location
```

기대 출력 (stub이므로 실패해야 정상):
```
[ RUN      ] MyLibTest.GreetBasic
[  FAILED  ] MyLibTest.GreetBasic
```

---

## Task 8: library — 구현 + CI (TDD: Green)

**Files:**
- Modify: `library/src/mylib.cpp`
- Create: `library/.gitignore`
- Create: `library/.github/workflows/ci.yml`

- [ ] **Step 1: mylib.cpp 구현으로 교체**

`library/src/mylib.cpp`:
```cpp
#include "mylib/mylib.h"

namespace mylib {
    std::string greet(const std::string& name) {
        return "Hello, " + name + "!";
    }
}
```

- [ ] **Step 2: 전체 테스트 통과 확인**

```powershell
Push-Location library
cmake --build --preset debug
ctest --preset debug
Pop-Location
```

기대 출력:
```
[==========] Running 3 tests from 1 test suite.
[       OK ] MyLibTest.GreetBasic
[       OK ] MyLibTest.GreetEmpty
[       OK ] MyLibTest.GreetName
[  PASSED  ] 3 tests.
```

- [ ] **Step 3: .gitignore 작성**

`library/.gitignore`:
```
build/
.vs/
CMakeUserPresets.json
*.user
out/
```

- [ ] **Step 4: ci.yml 작성**

`library/.github/workflows/ci.yml`:
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

- [ ] **Step 5: 커밋**

```powershell
git add library
git commit -m "feat: add library template with find_package support"
```

---

## Task 9: project — cmake 인프라 + 라이브러리 stub

**Files:**
- Create: `project/cmake/deps.cmake`
- Create: `project/libs/core/CMakeLists.txt`
- Create: `project/libs/core/include/core/core.h`
- Create: `project/libs/core/src/core.cpp`
- Create: `project/libs/utils/CMakeLists.txt`
- Create: `project/libs/utils/include/utils/utils.h`
- Create: `project/libs/utils/src/utils.cpp`

- [ ] **Step 1: 디렉토리 생성**

```powershell
New-Item -ItemType Directory -Force project/cmake
New-Item -ItemType Directory -Force project/libs/core/include/core
New-Item -ItemType Directory -Force project/libs/core/src
New-Item -ItemType Directory -Force project/libs/utils/include/utils
New-Item -ItemType Directory -Force project/libs/utils/src
New-Item -ItemType Directory -Force project/external
New-Item -ItemType Directory -Force project/tests
New-Item -ItemType Directory -Force project/src
New-Item -ItemType File     -Force project/external/.gitkeep
New-Item -ItemType Directory -Force "project/.github/workflows"
```

- [ ] **Step 2: cmake/deps.cmake 작성**

`project/cmake/deps.cmake`:
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

`project/libs/core/include/core/core.h`:
```cpp
#pragma once

#include <string>

namespace core {
    std::string version();
}
```

- [ ] **Step 4: core.cpp stub 작성**

`project/libs/core/src/core.cpp`:
```cpp
#include "core/core.h"

namespace core {
    std::string version() {
        return "";
    }
}
```

- [ ] **Step 5: core CMakeLists.txt 작성**

`project/libs/core/CMakeLists.txt`:
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

`project/libs/utils/include/utils/utils.h`:
```cpp
#pragma once

#include <string>

namespace utils {
    std::string to_upper(const std::string& s);
}
```

- [ ] **Step 7: utils.cpp stub 작성**

`project/libs/utils/src/utils.cpp`:
```cpp
#include "utils/utils.h"

namespace utils {
    std::string to_upper(const std::string& s) {
        return s;
    }
}
```

- [ ] **Step 8: utils CMakeLists.txt 작성**

`project/libs/utils/CMakeLists.txt`:
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

## Task 10: project — 테스트 작성 (TDD: Red)

**Files:**
- Create: `project/tests/CMakeLists.txt`
- Create: `project/tests/test_main.cpp`
- Create: `project/CMakeLists.txt` (임시, Task 12에서 완성)
- Create: `project/CMakePresets.json`

- [ ] **Step 1: tests/CMakeLists.txt 작성**

`project/tests/CMakeLists.txt`:
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

`project/tests/test_main.cpp`:
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

`project/CMakeLists.txt`:
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

`project/CMakePresets.json`:
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
Push-Location project
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

## Task 11: project — core + utils 구현 (TDD: Green)

**Files:**
- Modify: `project/libs/core/src/core.cpp`
- Modify: `project/libs/utils/src/utils.cpp`

- [ ] **Step 1: core.cpp 구현으로 교체**

`project/libs/core/src/core.cpp`:
```cpp
#include "core/core.h"

namespace core {
    std::string version() {
        return "0.1.0";
    }
}
```

- [ ] **Step 2: utils.cpp 구현으로 교체**

`project/libs/utils/src/utils.cpp`:
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

- [ ] **Step 3: 전체 테스트 통과 확인**

```powershell
Push-Location project
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

## Task 12: project — 루트 완성 + main + vcpkg.json + CI

**Files:**
- Modify: `project/CMakeLists.txt`
- Create: `project/src/main.cpp`
- Create: `project/vcpkg.json`
- Create: `project/.gitignore`
- Create: `project/.github/workflows/ci.yml`

- [ ] **Step 1: 루트 CMakeLists.txt 완성**

`project/CMakeLists.txt`:
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

`project/src/main.cpp`:
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

`project/vcpkg.json`:
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

`project/.gitignore`:
```
build/
.vs/
CMakeUserPresets.json
*.user
out/
```

- [ ] **Step 5: ci.yml 작성**

`project/.github/workflows/ci.yml`:
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

- [ ] **Step 6: Release 빌드 + 실행 검증**

```powershell
Push-Location project
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

- [ ] **Step 7: 커밋**

```powershell
git add project
git commit -m "feat: add project template with tests and CI"
```
