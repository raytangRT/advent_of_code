#include "aoc/aoc.hpp"
#include "aoc/fileHelpers.hpp"
#include "aoc/matrix.hpp"
#include "aoc/rangeHelpers.hpp"
#include <algorithm>
#include <iostream>
#include <ranges>
#include <regex>
#include <stdexcept>
#include <string>
#include <unordered_map>
#include <vector>

namespace day11 {
using Input = std::unordered_map<std::string, std::vector<std::string>>;

inline long walk(const Input &input, const std::string &from,
                 const std::string &to,
                 std::unordered_map<std::string, long> &memo) {
  if (from == to) {
    return 1;
  }

  if (memo.contains(from)) {
    return memo.at(from);
  }

  long total = 0;
  for (const auto &child :
       aoc::getOr(input, from, std::vector<std::string>{})) {
    total += walk(input, child, to, memo);
  }
  memo[from] = total;

  return total;
}

inline long walk(const Input &input, const std::string &from,
                 const std::string &to) {
  std::unordered_map<std::string, long> memo;
  return walk(input, from, to, memo);
}

inline long solvePart1(const Input &input) { return walk(input, "you", "out"); }

inline long
walk(const Input &input,
     const std::vector<std::pair<std::string, std::string>> &paths) {
  return paths | aoc::accumulate(1l, [&](long total, const auto &path) {
           const auto &[from, to] = path;
           return total * walk(input, from, to);
         });
}

inline long solvePart2(Input input) {
  long path1 = walk(input, {{"svr", "fft"}, {"fft", "dac"}, {"dac", "out"}});
  long path2 = walk(input, {{"svr", "dac"}, {"dac", "fft"}, {"fft", "out"}});
  return path1 + path2;
}

inline long solve(bool testing = true, [[gnu::unused]] bool part2 = false) {
  std::string filePath = "./input/day11/input.test.txt";
  if (!testing) {
    filePath = "./input/day11/input.txt";
  }

  if (part2 && testing) {
    filePath = "./input/day11/input.part2.test.txt";
  }

  std::regex re(R"((\w{3}): (.*))");
  std::unordered_map<std::string, std::vector<std::string>> data;
  for (const auto &line : aoc::loadFile(filePath)) {
    std::smatch matches;
    if (!std::regex_match(line, matches, re)) {
      std::cerr << "regex mismatched line" << std::endl;
      continue;
    }

    std::string in = matches[1];
    std::vector<std::string> outs = aoc::split(matches[2], ' ');
    data[in] = outs;
  }

  if (!part2) {
    return solvePart1(data);
  } else {
    return solvePart2(data);
  }

  return 0;
}
} // namespace day11
