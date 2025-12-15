#pragma once

#include "stringHelper.hpp"
#include <concepts>
#include <cstddef>
#include <cstdlib>
#include <iostream>
#include <limits>
#include <stdexcept>
#include <vector>

namespace aoc {

template <typename T>
concept Numeric = std::integral<T> || std::floating_point<T>;

template <Numeric T> class Matrix {
private:
  std::vector<std::vector<T>> m_data;

  static constexpr T getEpsilon() {
    // Choose based on type
    if constexpr (std::is_same_v<T, float>) {
      return T(1e-6);
    } else if constexpr (std::is_same_v<T, double>) {
      return T(1e-10);
    } else {
      // Fallback for other types
      return std::sqrt(std::numeric_limits<T>::epsilon());
    }
  }

public:
  Matrix() {}
  Matrix(const Matrix<T> &other) : m_data(other.m_data) {}

  size_t height() const { return m_data.size(); }
  size_t width() const { return m_data[0].size(); }
  size_t size() const { return height() * width(); }

  void addRow(const std::vector<T> &row) {
    if (!m_data.empty() && width() != row.size()) {
      throw std::invalid_argument("column width not matched");
    }
    m_data.push_back(row);
  }

  void concatenate(const std::vector<T> &vec) {
    if (vec.size() != height()) {
      throw std::invalid_argument("size mismatched");
    }
    size_t i = 0;
    for (auto &row : m_data) {
      row.push_back(vec[i++]);
    }
  }

  friend std::ostream &operator<<(std::ostream &os, const Matrix<T> &matrix) {
    os << "Matrix=========" << std::endl;
    for (const auto &row : matrix.m_data) {
      os << "[" << to_string(row) << "]\r\n";
    }

    return os << "Matrix=========" << std::endl;
  }

  const std::vector<T> operator[](const size_t idx) const {
    return m_data[idx];
  }

  std::vector<T> &operator[](const size_t idx) { return m_data[idx]; }

  Matrix<T> gaussian_elimination(const std::vector<T> &rhs) const {
    if (height() != rhs.size()) {
      throw std::invalid_argument("size mismatched");
    }

    const size_t m = height(); // rows
    const size_t n = width();  // variables
    constexpr T eps = getEpsilon();

    Matrix<T> reduced(*this);
    reduced.concatenate(rhs);

    size_t rank = 0;
    std::vector<size_t> pivotCols;
    std::vector<size_t> pivotRows;

    // ---------- Forward elimination: row echelon form ----------
    for (size_t colIdx = 0; colIdx < n && rank < m; colIdx++) {
      size_t pivot_row = rank;
      T max_val = std::abs(reduced[rank][colIdx]);
      for (size_t i = rank + 1; i < m; ++i) {
        T val = std::abs(reduced[i][colIdx]);
        if (val > max_val) {
          max_val = val;
          pivot_row = i;
        }
      }

      if (max_val < eps) {
        // free variable column
        continue;
      }

      if (pivot_row != rank) {
        std::swap(reduced[rank], reduced[pivot_row]);
      }

      const T pivot_val = reduced[rank][colIdx];
      pivotCols.push_back(colIdx);
      pivotRows.push_back(rank);

      // Eliminate below pivot
      for (size_t i = rank + 1; i < m; i++) {
        T factor = reduced[i][colIdx] / pivot_val;
        if (std::abs(factor) < eps)
          continue;

        for (size_t j = colIdx; j <= n; j++) {
          reduced[i][j] -= factor * reduced[rank][j];
        }
      }
      rank++;
    }

    // ---------- Gauss-Jordan backward phase: full RREF ----------
    // Process pivots from bottom to top
    for (int k = int(pivotCols.size()) - 1; k >= 0; --k) {
      size_t col = pivotCols[k];
      size_t row = pivotRows[k];

      T pivot_val = reduced[row][col];
      if (std::abs(pivot_val) < eps)
        continue;

      // Normalize pivot row so pivot becomes 1
      if (std::abs(pivot_val - T(1)) > eps) {
        for (size_t j = col; j <= n; ++j) {
          reduced[row][j] /= pivot_val;
        }
      }

      // Eliminate above pivot
      for (int i = int(row) - 1; i >= 0; --i) {
        T factor = reduced[i][col];
        if (std::abs(factor) < eps)
          continue;

        for (size_t j = col; j <= n; ++j) {
          reduced[i][j] -= factor * reduced[row][j];
        }
      }
    }

    return reduced;
  }
  // Assumes `this` is already in RREF [A|b] form.
  // n = number of variables, last column is RHS.
  // Returns one particular solution with free vars = 0.
  std::vector<T> rref_solution(std::vector<bool> &isFree) {
    const size_t m = height();
    const size_t n = width() - 1; // last col is RHS
    constexpr T eps = getEpsilon();

    isFree.assign(n, true); // mark all as free initially
    std::vector<int> pivotRow(
        n, -1); // pivotRow[j] = row index where col j has leading 1

    // 1) Identify pivots: in RREF, each nonzero row has a single leading 1
    for (size_t i = 0; i < m; ++i) {
      // find first non-zero entry in row i
      int firstCol = -1;
      for (size_t j = 0; j < n; ++j) {
        if (std::abs(m_data[i][j]) > eps) {
          firstCol = (int)j;
          break;
        }
      }
      if (firstCol == -1) {
        // [0 ... 0 | c]; if c != 0 => inconsistent
        if (std::abs(m_data[i][n]) > eps) {
          // throw std::runtime_error("no solution (inconsistent row in RREF)");
          std::cerr << "inconsistent\r\n";
        }
        continue; // 0 = 0 row
      }

      // leading entry should be 1 in RREF
      // (optionally normalize if not)
      if (std::abs(m_data[i][firstCol] - T(1)) > eps) {
        // normalize row i
        T piv = m_data[i][firstCol];
        for (size_t j = firstCol; j <= n; ++j) {
          m_data[i][j] = m_data[i][j] / piv;
        }
      }

      isFree[firstCol] = false;    // this variable is basic
      pivotRow[firstCol] = (int)i; // row where x_firstCol has its equation
    }

    // 2) Build one particular solution: set all free vars = 0
    std::vector<T> x(n, T(0));

    // For each basic variable j, read its equation from the pivot row:
    // x_j + sum_{k free} a_{row,k} * x_k = b_row
    // with free variables = 0, we get x_j = b_row
    for (size_t j = 0; j < n; ++j) {
      if (isFree[j])
        continue; // skip free vars here
      int row = pivotRow[j];
      if (row == -1)
        continue; // safety

      T value = m_data[row][n]; // RHS
      // subtract contributions of any *basic* vars with larger index (if
      // present)
      for (size_t k = j + 1; k < n; ++k) {
        if (!isFree[k]) {
          value -= m_data[row][k] * x[k];
        }
        // free vars contribute 0 in this particular solution
      }
      x[j] = value;
    }

    return x;
  }
};
} // namespace aoc
