#pragma once

#include <iostream>
#include <ostream>
#include <vector>

namespace aoc {
struct Range {
  long begin;
  long end;

  void merge(const Range &other);
  bool overlaps_with(const Range &other) const;
  bool is_inrange(const long &v) const;
  long numOfElements() const { return end - begin + 1; }

  friend std::ostream &operator<<(std::ostream &os, const Range &r) {
    return os << "[" << r.begin << "-" << r.end << "]";
  }
};

struct Ranges {
  std::vector<Range> ranges;

  void insert(Range);

  auto begin() const { return ranges.begin(); }

  auto end() const { return ranges.end(); }

  friend std::ostream &operator<<(std::ostream &os, const Ranges &rngs) {
    for (const auto &r : rngs.ranges) {
      os << r << ", ";
    }
    return os << std::endl;
  }
};

} // namespace aoc
template <> struct std::formatter<aoc::Range> : std::formatter<std::string> {
  // The parse() method is required to handle format specifiers (e.g., in
  // "{:...}")
  constexpr auto parse(std::format_parse_context &ctx) {
    // We can reuse the string formatter's parse function if we convert to a
    // string internally
    return std::formatter<std::string>::parse(ctx);
  }

  // The format() method is required to convert the custom type to a string
  auto format(const aoc::Range &p, std::format_context &ctx) const {
    // Use std::format to create the desired string representation
    std::string s = std::format("[{}, {}]", p.begin, p.end);

    // Delegate the actual formatting to the base string formatter,
    // which handles alignment, padding, etc.
    return std::formatter<std::string>::format(s, ctx);
  }
}; // namespace aoc
