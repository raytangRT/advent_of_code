#pragma once

#include <cstddef>
#include <functional>
#include <vector>

namespace aoc {

using RowIdx = std::size_t;
using ColIdx = std::size_t;

class Grid {
private:
  std::vector<std::vector<char>> m_grid;

  size_t m_width;
  size_t m_height;

public:
  Grid(const std::string &filePath);

  void printGrid() const;

  template <typename Func> void forEach(Func &&fn) const {
    for (RowIdx i = 0; i < m_height; ++i) {
      for (ColIdx j = 0; j < m_width; ++j) {
        fn(i, j, m_grid[i][j]);
      }
    }
  }

  void set(const RowIdx, const ColIdx, const char &);

  std::vector<char> neighbors(RowIdx, ColIdx) const;
};
} // namespace aoc
