#pragma once

#include "fileHelpers.hpp"
#include "points.hpp"
#include <cstddef>
#include <iostream>
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
      throw std::out_of_range("Index out of bounds");
    }
    return m_grid[rowIdx];
  }

  const std::vector<T> &operator[](const RowIdx rowIdx) const {
    return this[rowIdx];
  }

  size_t width() const { return m_width; }
  size_t height() const { return m_height; }
};

} // namespace aoc
