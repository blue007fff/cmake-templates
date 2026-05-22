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
