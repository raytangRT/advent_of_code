#include "aoc/fileHelpers.hpp"
#include "aoc/stringHelper.hpp"
#include "spdlog/spdlog.h"
#include <algorithm>
#include <cstddef>
#include <iostream>
#include <iterator>
#include <string>

namespace Day03 {

inline long calculateMaxJolt(const std::string &bank) {
  std::vector<int> values;

  std::transform(bank.begin(), bank.end(), std::back_inserter(values),
                 [](const char &v) { return v - '0'; });

  size_t frontIdx = 0;
  int frontValue = values[frontIdx];
  // ignore the last one
  for (size_t i = 1; i < values.size() - 1; i++) {
    if (values[i] > frontValue) {
      frontIdx = i;
      frontValue = values[i];
    }
  }

  size_t backIdx = values.size() - 1;
  int backValue = values[backIdx];

  for (size_t i = backIdx; i > frontIdx; i--) {
    if (values[i] > backValue) {
      backValue = values[i];
      backIdx = i;
    }
  }

  return frontValue * 10 + backValue;
}

inline long calculateMaxJoltPart2(const std::string &bank) {
  std::vector<int> values;

  std::transform(bank.begin(), bank.end(), std::back_inserter(values),
                 [](const char &v) { return v - '0'; });

  std::vector<int> result;

  auto findMax = [&](size_t startingIdx, int remainingDigits) {
    int maxValue = values[startingIdx];
    int maxValueIdx = startingIdx;
    size_t movingRange = values.size() - startingIdx - remainingDigits;
    for (size_t i = startingIdx; i <= startingIdx + movingRange; i++) {
      if (values[i] > maxValue) {
        maxValue = values[i];
        maxValueIdx = i;
      }
    }

    return std::pair{maxValue, maxValueIdx};
  };

  size_t nextIdx = 0;
  int remainingDigits = 12;
  do {
    const auto &[v, idx] = findMax(nextIdx, remainingDigits);
    result.push_back(v);
    nextIdx = idx + 1;
  } while (--remainingDigits > 0);

  long output = 0;
  for (const int val : result) {
    output = output * 10 + val;
  }

  return output;
}

inline long solve(bool testing, bool part2 = false) {
  std::string filePath = "./input/Day03/input.test.txt";
  if (!testing) {
    filePath = "./input/Day03/input.txt";
  }
  long result = 0;
  for (const auto &line : aoc::loadFile(filePath)) {
    if (part2) {
      result += calculateMaxJoltPart2(line);
    } else {
      result += calculateMaxJolt(line);
    }
  }
  return result;
}
} // namespace Day03
