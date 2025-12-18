#pragma once
#include "aoc/grid.hpp"
#include <cstddef>
#include <unordered_set>
#include <vector>

namespace day12 {
class Gift {
  using Grid = aoc::Grid<char>;

private:
  Grid m_shape;
  std::unordered_set<Grid> m_variants;

public:
  Gift(const Grid &shape) : m_shape(shape) {
    std::vector<Grid> rects = {{
        shape,
        shape.horizontal_mirroring_on_bottom(),
        shape.vertical_mirroring_on_left(),
        shape.horizontal_mirroring_on_bottom().vertical_mirroring_on_left(),
    }};

    m_variants.insert_range(rects);

    for (const auto &rect : rects) {
      auto current = rect;
      for (size_t i = 0; i < 4; i++) {
        current = current.rotate_clockwise();
        m_variants.insert(current);
      }
    }
  }

  std::unordered_set<Grid> variants() const { return m_variants; }

  size_t area() const { return m_shape.width() * m_shape.height(); }

  size_t size() const {
    size_t size = 0;
    m_shape.forEach([&](const auto &_, [[gnu::unused]] const auto &__,
                        const char v) { size += (v == '#' ? 1 : 0); });

    return size;
  }
};
}; // namespace day12
