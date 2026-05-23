#include <iostream>
#include <spdlog/spdlog.h>  // deps.cmake 에서 spdlog 활성화 후 사용
#include "core/core.h"
#include "utils/utils.h"

int main() {
	std::cout << "Version: " << core::version() << '\n';
	std::cout << utils::to_upper("hello, world!") << '\n';

	spdlog::info("Version: {}", core::version());
	// spdlog::info("{}", utils::to_upper("hello, world!"));

	return 0;
}
