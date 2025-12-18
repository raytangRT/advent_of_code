#pragma once

#include "aoc/grid.hpp"
#include "spdlog/spdlog.h"
#include <optional>
#include <ranges>

namespace day12 {
class TreeRegion {
  using Grid = aoc::Grid<char>;

private:
  Grid m_grid;

public:
  TreeRegion(const Grid &grid) : m_grid(grid) {}

  std::optional<TreeRegion> try_place(const std::pair<size_t, size_t> &location,
                                      const Grid &target) const {
    const auto &[sourceRowIdx, sourceColIdx] = location;
    if (sourceRowIdx - target.height() < 0 ||
        sourceColIdx + target.width() > m_grid.width()) {
      std::cerr << "ouot of bound\r\n";
      return std::nullopt;
    }

    spdlog::info("trying to place at Row = {}, Col = {}", sourceRowIdx,
                 sourceColIdx);
    spdlog::info(m_grid);
    spdlog::info(target);

    size_t sourceStartingRow = sourceRowIdx - (target.height() - 1);
    for (const size_t rowIdx : std::views::iota(0u, target.height())) {
      const std::vector<char> sourceRow = m_grid[sourceStartingRow + rowIdx];
      for (const size_t colIdx : std::views::iota(0u, target.width())) {
        const char sourceCell = sourceRow[sourceColIdx + colIdx];
        if (target[rowIdx][colIdx] == '#' && sourceCell != '.') {
          return std::nullopt;
        }
      }
    }

    auto source = m_grid;
    sourceStartingRow = sourceRowIdx - (target.height() - 1);
    for (const size_t rowIdx : std::views::iota(0u, target.height())) {
      std::vector<char> &sourceRow = source[sourceStartingRow + rowIdx];
      for (const size_t colIdx : std::views::iota(0u, target.width())) {
        if (target[rowIdx][colIdx] == '#')
          sourceRow[sourceColIdx + colIdx] = target[rowIdx][colIdx];
      }
    }

    spdlog::info("new grid");
    spdlog::info(source);

    return std::make_optional(TreeRegion{source});
  }
  std::vector<std::pair<size_t, size_t>>
  available_locations(const Grid &shape) const {
    std::vector<std::pair<size_t, size_t>> result;

    const size_t h = shape.height();
    const size_t w = shape.width();

    if (h == 0 || w == 0 || h > m_grid.height() || w > m_grid.width()) {
      return result; // shape doesn't fit anywhere
    }

    // Minimum bottom_row needed: shape must fit upward from it
    const size_t min_bottom_row = h - 1;
    const size_t max_left_col = m_grid.width() - w;

    // Scan all possible bottom rows (from lowest possible upward)
    for (size_t bottom_row = min_bottom_row; bottom_row < m_grid.height();
         ++bottom_row) {
      for (size_t left_col = 0; left_col <= max_left_col; ++left_col) {
        result.emplace_back(bottom_row, left_col);
      }
    }

    return result;
  }

  size_t size() const { return m_grid.height() * m_grid.width(); }
};
} // namespace day12
