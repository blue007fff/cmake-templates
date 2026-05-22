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
