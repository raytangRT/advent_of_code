#pragma once

#include <algorithm>
#include <functional>
#include <numeric>
#include <optional>
#include <ranges>
namespace aoc {

template <class T, class Op> struct accumulate_closure {
  T init;
  Op op;

  template <std::ranges::input_range R> auto operator()(R &&r) const {
    using std::begin, std::end;
    return std::accumulate(begin(r), end(r), init, op);
  }
};

struct accumulate_t {
  template <class T, class Op = std::plus<>>
  auto operator()(T init, Op op = {}) const {
    return accumulate_closure<T, Op>{std::move(init), std::move(op)};
  }
};

inline constexpr accumulate_t accumulate;

template <std::ranges::viewable_range R, class T, class Op>
auto operator|(R &&r, const accumulate_closure<T, Op> &c) {
  return c(std::forward<R>(r));
}

template <typename Proj = std::identity> class EqualsTo {
private:
  Proj m_proj;

public:
  constexpr explicit EqualsTo(Proj proj) : m_proj(std::move(proj)) {}

  template <typename T>
  constexpr bool operator()(const T &t1, const T &t2) const {
    return std::invoke(m_proj, t1) == std::invoke(m_proj, t2);
  }
};

template <typename T>
inline std::optional<std::pair<T, T>> find_boundary(const std::vector<T> &input,
                                                    const T &source) {
  std::vector<T> sortedInput = input;
  std::sort(sortedInput.begin(), sortedInput.end());

  auto lowerBound =
      std::lower_bound(sortedInput.begin(), sortedInput.end(), source);
  if (lowerBound == sortedInput.begin()) {
    return std::nullopt;
  }

  auto upperBound = std::upper_bound(lowerBound, sortedInput.end(), source);
  if (upperBound == sortedInput.end())
    return std::nullopt;

  return std::make_pair(*std::prev(lowerBound), *upperBound);
}
} // namespace aoc
