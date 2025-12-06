#pragma once
#include <charconv>
#include <cstdlib>
#include <iostream>
#include <string>
#include <string_view>

namespace aoc {
inline long to_long(std::string_view s) {
  long result = 0;
  const auto [ptr, ec] = std::from_chars(s.data(), s.data() + s.size(), result);
  if (ec != std::errc{}) {
    std::cerr << "Invalid number: " << s << '\n';
    std::abort();
  }
  return result;
}

inline long to_long(const std::string &input) {
  return to_long(std::string_view(input));
}

} // namespace aoc
