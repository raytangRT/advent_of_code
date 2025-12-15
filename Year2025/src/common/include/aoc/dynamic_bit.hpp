#pragma once
#include "absl/hash/hash.h"
#include <algorithm>
#include <format>
#include <functional>
#include <ostream>
#include <stdexcept>
#include <vector>

namespace aoc {
class DynamicBits {
private:
  std::vector<bool> m_data;

public:
  DynamicBits(const std::string &input) {
    m_data.reserve(input.size());
    for (const char c : input) {
      if (c == '0') {
        m_data.push_back(false);
      } else if (c == '1') {
        m_data.push_back(true);
      } else {
        throw std::invalid_argument(std::format("{} not supported", c));
      }
    }
  }

  // Two constructors: one for copy, one for move
  explicit DynamicBits(const std::vector<bool> &data) : m_data(data) {}
  explicit DynamicBits(std::vector<bool> &&data) : m_data(std::move(data)) {}
  explicit DynamicBits(size_t n, bool defaultValue)
      : m_data(std::vector<bool>(n, defaultValue)) {}

  DynamicBits operator^(const DynamicBits &other) const {
    if (size() != other.size()) {
      throw std::invalid_argument("size mismatched");
    }

    std::vector<bool> result(size());
    std::ranges::transform(m_data, other.m_data, result.begin(),
                           std::bit_xor<>{});
    return DynamicBits{std::move(result)}; // Move into result
  }

  bool operator==(const DynamicBits &other) const {
    return m_data == other.m_data;
  }

  size_t size() const { return m_data.size(); }
  bool operator[](size_t idx) const { return m_data[idx]; }

  void flip_at(size_t idx) { m_data[idx] = !m_data[idx]; }

  friend std::ostream &operator<<(std::ostream &os, const DynamicBits &db) {
    os << "DynamicBits[";
    for (bool bit : db.m_data) {
      os << (bit ? '1' : '0');
    }
    return os << "]";
  }

  size_t hash() const { return absl::HashOf(m_data); }

  static constexpr DynamicBits min(size_t n) {
    return DynamicBits(std::vector<bool>(n, false));
  }

  DynamicBits operator&(const DynamicBits &other) const {
    if (size() != other.size()) {
      throw std::invalid_argument("size mismatched");
    }

    std::vector<bool> result(size());
    std::ranges::transform(m_data, other.m_data, result.begin(),
                           std::bit_and<>{});
    return DynamicBits(result);
  }
};
} // namespace aoc

template <> struct std::hash<aoc::DynamicBits> {
  size_t operator()(const aoc::DynamicBits &db) const { return db.hash(); }
};
