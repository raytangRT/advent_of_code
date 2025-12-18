#pragma once

#include "absl/hash/hash.h"
#include "fileHelpers.hpp"
#include "points.hpp"
#include <cstddef>
#include <iostream>
#include <sstream>
#include <stdexcept>
#include <vector>

namespace aoc {

using RowIdx = std::size_t;
using ColIdx = std::size_t;

template <typename T> class Grid {
private:
  std::vector<std::vector<T>> m_grid;

  size_t m_width;
  size_t m_height;

public:
  Grid(const std::string &filePath) {
    const auto lines = aoc::loadFile(filePath);

    m_height = lines.size();
    m_width = lines[0].length();

    m_grid.resize(m_height, std::vector<char>(m_width));

    // Fill row-by-row
    for (RowIdx i = 0; i < m_height; ++i) {
      const auto &line = lines[i];
      for (ColIdx j = 0; j < m_width; ++j) {
        m_grid[i][j] = line[j];
      }
    }
  }

  Grid() : m_width(0), m_height(0) {}

  Grid(size_t width, size_t height, const T &defaultValue)
      : m_width(width), m_height(height) {
    for (size_t i = 0; i < height; i++) {
      m_grid.push_back(std::vector<T>(width, defaultValue));
    }
  }

  Grid(const std::vector<std::vector<T>> &input) : Grid() {
    for (const auto &row : input) {
      addRow(row);
    }
  }

  void printGrid() const {
    for (size_t i = 0; i < m_height; i++) {
      for (size_t j = 0; j < m_width; j++) {
        std::cerr << m_grid[i][j];
      }
      std::cerr << std::endl;
    }
  }

  template <typename Func> void forEach(Func &&fn) const {
    for (RowIdx i = 0; i < m_height; ++i) {
      for (ColIdx j = 0; j < m_width; ++j) {
        fn(i, j, m_grid[i][j]);
      }
    }
  }

  bool set(const Point &p, const T &value) { return set(p.y, p.x, value); }

  bool set(const RowIdx rowIdx, const ColIdx colIdx, const T &value) {
    if (rowIdx < m_height && colIdx < m_width) {
      m_grid[rowIdx][colIdx] = value;
      return true;
    }
    return false;
  }

  const std::vector<T> neighbors(RowIdx row, ColIdx col) const {
    std::vector<T> result;

    const std::vector dirs = {
        std::pair{-1, -1}, {-1, 0}, {-1, 1}, {0, -1}, {0, 1},
        {1, -1},           {1, 0},  {1, 1}};

    for (auto [dr, dc] : dirs) {
      auto nr = row + dr;
      auto nc = col + dc;

      if (nr >= 0 && nr < m_height && nc >= 0 && nc < m_width) {
        result.push_back(m_grid[nr][nc]);
      }
    }
    return result;
  }

  const T &get(const Point &p) const { return get(p.y, p.x); }
  const T &get(const RowIdx &row, const ColIdx &col) {
    return m_grid[row][col];
  }

  const std::vector<T> &getRow(const Point &p) { return m_grid[p.y]; }
  const std::vector<T> &getCol(const ColIdx colIdx) {
    std::vector<T> result;
    for (size_t i = 0; i < colIdx; i++) {
      for (size_t j = 0; j < m_height; j++) {
        result.push_back(m_grid[j][i]);
      }
    }

    return result;
  }
  const std::vector<T> &getCol(const Point &p) { return getCol(p.x); }

  std::vector<T> &operator[](const RowIdx rowIdx) {
    if (rowIdx < 0 || rowIdx >= m_height) {
      // Handle out-of-bounds access, e.g., throw an exception
      std::cerr << "out of bound at " << rowIdx << std::endl;
      throw std::out_of_range("Index out of bounds");
    }
    return m_grid[rowIdx];
  }

  const std::vector<T> &operator[](const RowIdx rowIdx) const {
    return m_grid[rowIdx];
  }

  size_t width() const { return m_width; }
  size_t height() const { return m_height; }

  void addRow(const std::vector<T> &row) {
    if (m_width > 0 && m_width != row.size()) {
      throw std::invalid_argument("width and row.size() mismatched");
    }
    if (m_width == 0) {
      m_width = row.size();
    }

    m_grid.push_back(row);
    m_height++;
  }

  Grid<T> rotate_clockwise() const {
    Grid<T> newGrid(m_height, m_width, T{});
    for (size_t r = 0; r < m_height; ++r) {
      for (size_t c = 0; c < m_width; ++c) {
        // (r, c) -> (c, m_height - 1 - r)
        if (!newGrid.set(c, m_height - 1 - r, m_grid[r][c])) {
          throw std::invalid_argument("invalid grid");
        }
      }
    }
    return newGrid;
  }
  // Mirrors the grid by flipping top ↔ bottom (mirror line at bottom edge)
  Grid<T> horizontal_mirroring_on_bottom() const {
    Grid<T> newGrid(m_width, m_height, T{});

    for (size_t r = 0; r < m_height; ++r) {
      for (size_t c = 0; c < m_width; ++c) {
        // Map original (r, c) → new (height-1-r, c)
        // Top row becomes bottom row, bottom row becomes top row
        newGrid.set(m_height - 1 - r, c, m_grid[r][c]);
      }
    }
    return newGrid;
  }

  // Mirrors the grid by flipping left ↔ right (mirror line on left edge)
  Grid<T> vertical_mirroring_on_left() const {
    Grid<T> newGrid(m_width, m_height, T{});

    for (size_t r = 0; r < m_height; ++r) {
      for (size_t c = 0; c < m_width; ++c) {
        // Map original (r, c) → new (r, width-1-c)
        // Left column becomes right column, right column becomes left column
        newGrid.set(r, m_width - 1 - c, m_grid[r][c]);
      }
    }
    return newGrid;
  }

  const std::vector<std::vector<T>> &data() const { return m_grid; }

  bool deepEquals(const Grid<T> &other) const {
    for (size_t i = 0; i < m_height; i++) {
      for (size_t j = 0; j < m_width; j++) {
        if (m_grid[i][j] != other.m_grid[i][j]) {
          return false;
        }
      }
    }
    return true;
  }

  bool operator==(const Grid<T> &other) const {
    return m_width == other.m_width && m_height == other.m_height &&
           deepEquals(other);
  }
};

} // namespace aoc
//
namespace std {
template <typename T> struct hash<aoc::Grid<T>> {
  size_t operator()(const aoc::Grid<T> &grid) const {
    return absl::HashOf(grid.width(), grid.height(), grid.data());
  }
};

} // namespace std

#include <fmt/format.h>
#include <string>

namespace fmt {

template <> struct formatter<aoc::Grid<char>> : formatter<std::string> {
  // Required: parse format specifications (we ignore them here)
  constexpr auto parse(format_parse_context &ctx) { return ctx.begin(); }

  // The actual formatting
  auto format(const aoc::Grid<char> &grid, format_context &ctx) const {
    std::stringstream ss;
    ss << std::endl;

    for (size_t r = 0; r < grid.height(); ++r) {
      for (size_t c = 0; c < grid.width(); ++c) {
        ss << grid[r][c];
      }
      ss << std::endl;
    }

    // Correct way: use the base class instance (this->) to format the string
    return formatter<std::string>::format(ss.str(), ctx);
  }
};

} // namespace fmt
