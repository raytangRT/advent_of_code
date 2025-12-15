#pragma once

#include <absl/hash/hash.h>
#include <vector>

namespace aoc {
template <typename T> struct VectorHash {
  std::size_t operator()(const std::vector<T> &vec) const {
    return absl::HashOf(vec);
  }
};
} // namespace aoc
