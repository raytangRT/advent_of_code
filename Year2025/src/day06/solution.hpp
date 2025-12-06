#include "aoc/aoc.hpp"
#include "aoc/numberHelpers.hpp"
#include "fmt/format.h"
#include <format>
#include <functional>
#include <iostream>
#include <numeric>
#include <regex>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace day06 {

struct Problem {
  std::vector<long> numbers;
  char op;

  long calculate() const {
    switch (op) {
    case '+':
      return std::accumulate(numbers.begin(), numbers.end(), 0l);
    case '*':
      return std::accumulate(numbers.begin(), numbers.end(), 1l,
                             std::multiplies<>());
    default:
      throw std::invalid_argument(std::to_string(op));
    }
  }

  Problem cloneAndReset() {
    Problem out = {numbers, op};
    numbers.clear();
    op = '\0';
    return out;
  }
};

inline std::vector<Problem>
buildProblemsPart1(const std::vector<std::string> &lines) {
  std::vector<Problem> problems;
  for (size_t i = 0; i < lines.size(); i++) {
    std::string cleanLine =
        std::regex_replace(lines[i], std::regex("\\s+"), " ");

    aoc::rtrim(cleanLine);
    aoc::ltrim(cleanLine);

    const auto &splitted_lines = aoc::split(cleanLine, ' ');
    for (size_t j = 0; j < splitted_lines.size(); j++) {
      const auto &value = splitted_lines[j];
      if (i == 0) {
        Problem p;
        p.numbers.push_back(aoc::to_long(value));
        problems.push_back(p);
      } else {
        Problem &p = problems[j];
        if (i + 1 == lines.size()) {
          p.op = value[0];
        } else {
          p.numbers.push_back(aoc::to_long(value));
        }
      }
    }
  }
  return problems;
}

inline auto buildProblemsPart2(std::vector<std::string> &lines) {
  std::vector<Problem> problems;
  Problem tmp;
  size_t width = lines[0].length();
  for (size_t i = 1; i < lines.size(); i++) {
    width = std::max(width, lines[i].length());
  }

  for (size_t i = 0; i < lines.size(); i++) {
    if (lines[i].length() != width) {
      lines[i].append(" ", width - lines[i].length());
    }
  }

  for (size_t i = 0; i < width; i++) {
    std::string num = "";
    for (size_t j = 0; j < lines.size() - 1; j++) {
      num += lines[j][i];
    }
    aoc::trim(num);
    char opLine = lines[lines.size() - 1][i];

    if (num == "" && opLine == ' ') {
      problems.push_back(tmp.cloneAndReset());
      continue;
    }

    if (opLine != ' ' && opLine != '\0') {
      tmp.op = opLine;
    }

    tmp.numbers.push_back(aoc::to_long(num));
  }

  problems.push_back(tmp);

  return problems;
}

inline long solve(bool testing = true, [[gnu::unused]] bool part2 = false) {
  std::string filePath = "./input/day06/input.test.txt";
  if (!testing) {
    filePath = "./input/day06/input.txt";
  }
  std::vector<std::string> lines = aoc::loadFile(filePath);

  std::vector<Problem> problems;
  if (!part2) {
    problems = buildProblemsPart1(lines);
  } else {
    problems = buildProblemsPart2(lines);
  }

  return std::accumulate(
      problems.begin(), problems.end(), 0l,
      [](long sum, const Problem &p) { return sum + p.calculate(); });
}
} // namespace day06
