#pragma once

#include <algorithm>
#include <functional>
#include <numeric>
#include <optional>
#include <queue>
#include <ranges>
#include <string>
#include <unordered_map>
namespace aoc {
template <class T, class Op> struct accumulate_closure {
  T init;
  Op op;

  // Perfect forwarding of the range
  template <std::ranges::input_range R>
  constexpr auto operator()(R &&r) const
      noexcept(noexcept(std::accumulate(std::begin(r), std::end(r), init,
                                        op))) {
    using std::begin, std::end;
    return std::accumulate(begin(r), end(r), init, std::ref(op)); // important!
  }
};

struct accumulate_t {
  // Allow perfect forwarding of init and op
  template <class T, class Op = std::plus<>>
  constexpr auto operator()(T &&init, Op &&op = {}) const
      noexcept(std::is_nothrow_move_constructible_v<T> &&
               std::is_nothrow_move_constructible_v<Op>) {
    return accumulate_closure<std::decay_t<T>, std::decay_t<Op>>{
        std::forward<T>(init), std::forward<Op>(op)};
  }
};

inline constexpr accumulate_t accumulate{};

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

struct stoi_fn {
  int operator()(const std::string &input) { return std::stoi(input); }
};

inline constexpr stoi_fn stoi;

template <typename T> T pop(std::queue<T> &queue) {
  T value = queue.front();
  queue.pop();
  return value;
}

template <typename TIn, typename TOut> struct cast_fn {
  TOut operator()(const TIn &in) { return (TOut)in; }
};

template <typename TIn, typename TOut> inline constexpr cast_fn<TIn, TOut> cast;

template <typename T> std::vector<T> pop_all(std::queue<T> &queue) {
  std::vector<T> result;
  while (!queue.empty()) {
    result.push_back(aoc::pop(queue));
  }
  return result;
}

template <std::ranges::viewable_range R> auto enumerate(R &&r) {
  using std::ranges::distance;
  using std::views::iota;
  using std::views::zip;

  if constexpr (std::ranges::sized_range<R>) {
    auto d = distance(r);
    return zip(iota(0, d), std::forward<R>(r)); // bounded iota for sized ranges
  } else {
    return zip(iota(0), std::forward<R>(r)); // unbounded iota for others
  }
}
template <typename TKey, typename TValue>
TValue getOr(const std::unordered_map<TKey, TValue> &map, const TKey &key,
             const TValue &defaultValue) {
  return getOr(map, key, [&]() { return defaultValue; });
}
template <typename TKey, typename TValue, typename Fn>
TValue getOr(const std::unordered_map<TKey, TValue> &map, const TKey &key,
             Fn &&fn)
  requires std::invocable<Fn>
{
  if (auto found = map.find(key); found != map.end()) {
    return found->second;
  }
  return std::forward<Fn>(fn)();
}

} // namespace aoc
