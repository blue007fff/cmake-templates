# cmake-templates

C++20 / CMake 3.25+ 프로젝트 템플릿 모음.  
각 템플릿은 독립적으로 복사해서 즉시 사용 가능합니다.

## 구조

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

- **project / library / scratch** — 복사해서 바로 쓰는 실용 템플릿
- **tutorials/** — CMake 개념을 순서대로 학습하는 자료

## 공통 스펙

| 항목 | 값 |
|---|---|
| C++ 표준 | C++20 |
| CMake 최소 버전 | 3.25 |
| 빌드 시스템 | Ninja |
| VS 연동 | CMakePresets.json (Open Folder) |
| compile_commands.json | 생성됨 (clangd / LSP 지원) |

## 사전 요구사항

- **CMake 3.25+** — `cmake --version` 으로 확인
- **Ninja** — VS 2022 설치 시 포함, 또는 `winget install Ninja-build.Ninja`
- **Visual Studio 2022** — "Desktop development with C++" 워크로드

## 빠른 시작

### tutorials/01-hello

```powershell
cd tutorials/01-hello
cmake --preset x64-debug
cmake --build --preset debug
.\build\x64-debug\Hello.exe
```

### tutorials/02-with-lib

```powershell
cd tutorials/02-with-lib
cmake --preset x64-debug
cmake --build --preset debug
.\build\x64-debug\MyApp.exe
```

### tutorials/03-with-deps

fmt를 FetchContent로 자동 다운로드합니다 (첫 빌드 시 시간 소요).

```powershell
cd tutorials/03-with-deps
cmake --preset x64-debug
cmake --build --preset debug
.\build\x64-debug\MyApp.exe
```

### scratch

`.cpp` 파일을 추가하면 각각 별도 실행파일로 빌드됩니다.

```powershell
cd scratch
cmake --preset x64-debug
cmake --build --preset debug
.\build\x64-debug\example1.exe
.\build\x64-debug\example2.exe
```

### library

GoogleTest 포함 테스트, `find_package(MyLib)` 지원 설치 규칙.

```powershell
cd library
cmake --preset x64-debug
cmake --build --preset debug
ctest --preset debug
```

### project

vcpkg 또는 FetchContent 자동 fallback, GoogleTest, GitHub Actions CI.

```powershell
cd project
cmake --preset x64-debug
cmake --build --preset debug
ctest --preset debug
.\build\x64-debug\MyApp.exe
```

vcpkg가 설치되어 있으면 `VCPKG_ROOT` 환경변수를 설정하면 자동으로 연동됩니다.

## 튜토리얼 학습 순서

| # | 폴더 | 학습 내용 |
|---|---|---|
| 1 | `tutorials/01-hello` | `cmake_minimum_required`, `project`, `add_executable`, CMakePresets.json |
| 2 | `tutorials/02-with-lib` | `add_library`, `target_include_directories`, `add_subdirectory` |
| 3 | `tutorials/03-with-deps` | `FetchContent_Declare`, `FetchContent_MakeAvailable`, SHA 핀닝 |

## 프리셋

모든 템플릿에서 동일한 프리셋을 사용합니다.

| 프리셋 (configure) | 설명 |
|---|---|
| `x64-debug` | Debug 빌드 |
| `x64-release` | Release 빌드 |
| `x64-relwithdebinfo` | RelWithDebInfo 빌드 |
| `linux-debug` | Debug 빌드 (CI 전용, Linux) |

```powershell
cmake --preset x64-debug        # configure
cmake --build --preset debug    # build
ctest --preset debug            # test (library, project 만)
```

Visual Studio에서는 폴더를 열면 (`File > Open > Folder`) 프리셋이 자동으로 인식됩니다.
