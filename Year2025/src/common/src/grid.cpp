#include "aoc/grid.hpp"
#include "aoc/fileHelpers.hpp"
#include <cstddef>
#include <iostream>
#include <iterator>
#include <vector>

namespace aoc {
Grid::Grid(const std::string &filePath) {
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

void Grid::printGrid() const {
  for (size_t i = 0; i < m_height; i++) {
    for (size_t j = 0; j < m_width; j++) {
      std::cerr << m_grid[i][j];
    }
    std::cerr << std::endl;
  }
}
const std::vector<char> Grid::neighbors(RowIdx row, ColIdx col) const {
  std::vector<char> result;

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

void Grid::set(const RowIdx rowIdx, const ColIdx colIdx, const char &value) {
  if (rowIdx < m_height && colIdx < m_width) {
    m_grid[rowIdx][colIdx] = value;
  }
}

std::vector<char> &Grid::operator[](const RowIdx rowIdx) {
  if (rowIdx < 0 || rowIdx >= m_height) {
    // Handle out-of-bounds access, e.g., throw an exception
    throw std::out_of_range("Index out of bounds");
  }
  return m_grid[rowIdx];
}

const std::vector<char> &Grid::operator[](const RowIdx rowIdx) const {
  if (rowIdx < 0 || rowIdx >= m_height) {
    // Handle out-of-bounds access, e.g., throw an exception
    throw std::out_of_range("Index out of bounds");
  }
  return m_grid[rowIdx];
}

size_t Grid::width() const { return m_width; }
size_t Grid::height() const { return m_height; }

} // namespace aoc
