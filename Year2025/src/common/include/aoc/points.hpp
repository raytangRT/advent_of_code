#pragma once

#include <fmt/format.h>
#include <functional>
#include <iostream>
#include <string>

namespace aoc {

struct Point {
  int x;
  int y;

  friend std::string format_as(const Point &p) {
    return fmt::format("({},{})", p.x, p.y);
  }

  Point(int x, int y) : x(x), y(y) {}
  Point(size_t x, size_t y) : x(x), y(y) {}
  Point(long x, long y) : x(x), y(y) {}

  constexpr auto operator<=>(const Point &other) const = default;

  friend std::ostream &operator<<(std::ostream &os, const Point &p) {
    return os << "pt{" << p.x << ',' << p.y << '}';
  }
};

struct Point3d {
  int x;
  int y;
  int z;

  friend std::string format_as(const Point3d &p) {
    return fmt::format("({},{},{})", p.x, p.y, p.z);
  }

  static float distance(const Point3d &p1, const Point3d &p2) {
    float dx = p1.x - p2.x;
    float dy = p1.y - p2.y;
    float dz = p1.z - p2.z;
    return dx * dx + dy * dy + dz * dz;
  }

  Point3d(int x, int y, int z) : x(x), y(y), z(z) {}

  constexpr bool operator==(const Point3d &other) const = default;
  constexpr auto operator<=>(const Point3d &other) const = default;

  friend std::ostream &operator<<(std::ostream &os, const Point3d &p) {
    return os << "pt{" << p.x << ',' << p.y << "," << p.z << '}';
  }
};

} // namespace aoc

// Hash specialization for Point
template <> struct std::hash<aoc::Point> {
  std::size_t operator()(const aoc::Point &p) const {
    return std::hash<int>{}(p.x) ^ (std::hash<int>{}(p.y) << 1);
  }
};

// Hash specialization for Point
template <> struct std::hash<aoc::Point3d> {
  std::size_t operator()(const aoc::Point3d &p) const {
    return std::hash<int>{}(p.x) ^ (std::hash<int>{}(p.y) << 1) ^
           (std::hash<int>{}(p.z) << 4);
  }
};

template <> struct std::formatter<aoc::Point> : std::formatter<std::string> {
  // The parse() method is required to handle format specifiers (e.g., in
  // "{:...}")
  constexpr auto parse(std::format_parse_context &ctx) {
    // We can reuse the string formatter's parse function if we convert to a
    // string internally
    return std::formatter<std::string>::parse(ctx);
  }

  // The format() method is required to convert the custom type to a string
  auto format(const aoc::Point &p, std::format_context &ctx) const {
    // Use std::format to create the desired string representation
    std::string s = std::format("[{}, {}]", p.x, p.y);

    // Delegate the actual formatting to the base string formatter,
    // which handles alignment, padding, etc.
    return std::formatter<std::string>::format(s, ctx);
  }
};
