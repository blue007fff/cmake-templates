#include <iostream>
#include "core/core.h"
#include "utils/utils.h"

int main() {
    std::cout << "Version: " << core::version() << '\n';
    std::cout << utils::to_upper("hello, world!") << '\n';
    return 0;
}
