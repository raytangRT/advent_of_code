#include "aoc/range.hpp"
#include <algorithm>
#include <utility>

namespace aoc {
void Range::merge(const Range &other) {
  if (overlaps_with(other)) {
    begin = std::min(begin, other.begin);
    end = std::max(end, other.end);
  }
}

bool Range::overlaps_with(const Range &other) const {
  return begin <= other.end && end >= other.begin;
}

bool Range::is_inrange(const long &in) const {
  return begin <= in && end >= in;
}

void Ranges::insert(Range r) {
  if (r.begin > r.end)
    std::swap(r.begin, r.end);

  auto it = std::lower_bound(
      ranges.begin(), ranges.end(), r,
      [](const Range &a, const Range &b) { return a.begin < b.begin; });

  // Insert at correct position
  it = ranges.insert(it, r);

  // Merge left
  if (it != ranges.begin()) {
    auto prev = it - 1;
    if (prev->end + 1 >= it->begin) {
      prev->end = std::max(prev->end, it->end);
      it = ranges.erase(it);
      it = prev;
    }
  }

  // Merge right (possibly multiple)
  while (it + 1 != ranges.end() && it->end + 1 >= (it + 1)->begin) {
    (it + 1)->begin =
        std::min(it->begin, (it + 1)->begin); // usually unnecessary
    it->end = std::max(it->end, (it + 1)->end);
    ranges.erase(it + 1);
  }
}
} // namespace aoc
