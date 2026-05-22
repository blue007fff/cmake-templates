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
