cmake_minimum_required(VERSION 3.25)
project(Hello VERSION 0.1.0 LANGUAGES CXX)

# C++20 required — will error instead of silently falling back
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(Hello src/main.cpp)
