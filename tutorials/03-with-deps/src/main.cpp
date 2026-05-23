#include <fmt/core.h>
#include <spdlog/spdlog.h>

int main() {
    fmt::print("Hello, {}!\n", "fmtlib");

    spdlog::info("¾È³ç, {}!", "spdlog");
    spdlog::warn("this is a warning");
    spdlog::error("something went wrong: {}", 42);

    return 0;
}
