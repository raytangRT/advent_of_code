#include "aoc/fileHelpers.hpp"
#include "aoc/stringHelper.hpp"
#include "spdlog/spdlog.h"
#include <cstddef>
#include <format>
#include <iostream>
#include <numeric>
#include <stdexcept>
#include <string>
#include <unordered_set>
#include <vector>

namespace Day02 {

inline std::vector<long> find_dupes(long lower, long upper) {
  std::vector<long> result;

  std::string lowerStr = std::to_string(lower);
  std::string upperStr = std::to_string(upper);

  if (lowerStr.length() % 2 != 0 && upperStr.length() % 2 != 0) {
    return result;
  }

  if (lowerStr.length() % 2 != 0) {
    lower = std::pow(10, lowerStr.length());
    lowerStr = std::to_string(lower);
  }

  if (upperStr.length() % 2 != 0) {
    upper = std::pow(10, upperStr.length() - 1) - 1;
  }
  long startingNum = std::stoi(lowerStr.substr(0, lowerStr.length() / 2));

  auto buildNum = [](long num) {
    int len = std::to_string(num).length();
    return num * std::pow(10, len) + num;
  };

  long target = buildNum(startingNum);
  for (; target <= upper; target = buildNum(++startingNum)) {
    if (target >= lower && target <= upper) {
      result.push_back(target);
    }
  }

  return result;
}

inline std::vector<long> find_dupes_part2(long lower, long upper) {
  spdlog::info("{}, {}", lower, upper);
  std::unordered_set<long> result;
  std::vector<int> combinations;
  int lowerLength = std::to_string(lower).length();
  int upperLength = std::to_string(upper).length();

  auto buildNum = [](int num, int numOfDigits, int targetLength) {
    int toRepeatCount = targetLength / numOfDigits;

    std::string s1 = aoc::repeat(std::to_string(num), toRepeatCount);
    long output;
    std::istringstream iss1(s1);
    if (!(iss1 >> output)) {
      std::cerr << "Error converting '" << s1 << "' using istringstream."
                << "input = " << num << ", repeatCount = " << toRepeatCount
                << ", numOfDigits = " << numOfDigits << std::endl;
    }
    return output;
  };

  for (int i = lowerLength - 1; i > 0; i--) {
    if (lowerLength % i == 0) {
      int startingNum = lower / std::pow(10, lowerLength - i);
      auto toCheck = buildNum(startingNum, i, lowerLength);
      while (toCheck <= upper) {
        if (toCheck >= lower)
          result.emplace(toCheck);
        toCheck = buildNum(startingNum++, i, lowerLength);
      }
    }
  }

  if (upperLength > lowerLength) {
    auto remaining = find_dupes_part2(std::pow(10, lowerLength), upper);
    if (remaining.size() > 0) {
      result.insert(remaining.begin(), remaining.end());
    }
  }

  return std::vector<long>(result.begin(), result.end());
}

inline long solve(const std::string &fileName, bool part2 = false) {
  const std::vector<std::string> lines = aoc::loadFile(fileName);
  if (lines.size() > 1) {
    throw std::invalid_argument("should be a one liner input");
  }

  long result = 0;

  for (const auto &rangeString : aoc::split(lines[0], ',')) {
    const auto rangeStrings = aoc::split(rangeString, '-');
    long lower = std::stol(rangeStrings[0]);
    long upper = std::stol(rangeStrings[1]);
    std::vector<long> dupes;
    if (part2) {
      dupes = find_dupes_part2(lower, upper);
    } else {
      dupes = find_dupes(lower, upper);
    }

    long sum = std::accumulate(dupes.begin(), dupes.end(), 0l);

    spdlog::info(std::format("{} - {}: size = {}, {} + {} = {}", lower, upper,
                             dupes.size(), result, sum, result + sum));

    result += sum;
  }

  spdlog::info("final result = {}", result);

  return result;
}

} // namespace Day02
