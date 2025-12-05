#include "aoc/grid.hpp"
#include <algorithm>
#include <iostream>
#include <vector>

namespace Day04 {

inline std::vector<std::pair<aoc::RowIdx, aoc::ColIdx>>
countPart1(const aoc::Grid &grid) {
  std::vector<std::pair<aoc::RowIdx, aoc::ColIdx>> result;
  grid.forEach([&](const aoc::RowIdx rowIdx, const aoc::ColIdx colIdx,
                   const char &value) {
    if (value == '@') {
      std::vector<char> neighbors = grid.neighbors(rowIdx, colIdx);
      auto count = std::count_if(neighbors.begin(), neighbors.end(),
                                 [](const char &v) { return v == '@'; });

      if (count <= 3) {
        result.emplace_back(rowIdx, colIdx);
      }
    }
  });

  return result;
}
inline long countPart2(aoc::Grid &grid) {
  long rowCount = 0;
  auto toRemove = countPart1(grid);
  while (toRemove.size() > 0) {
    rowCount += toRemove.size();
    for (const auto &[rowIdx, colIdx] : toRemove) {
      grid.set(rowIdx, colIdx, '.');
    }
    toRemove = countPart1(grid);
  }
  return rowCount;
}

inline long solve(bool testing = true, bool part2 = false) {
  std::string filePath = "./input/Day04/input.test.txt";
  if (!testing) {
    filePath = "./input/Day04/input.txt";
  }

  aoc::Grid grid(filePath);
  long rowCount = 0;

  if (!part2) {
    rowCount = countPart1(grid).size();
  } else {
    rowCount = countPart2(grid);
  }

  return rowCount;
}
} // namespace Day04
