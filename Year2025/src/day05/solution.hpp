#include "aoc/fileHelpers.hpp"
#include "aoc/range.hpp"
#include "aoc/stringHelper.hpp"
#include <algorithm>
#include <format>
#include <iostream>
#include <numeric>
#include <string>
#include <vector>

namespace day05 {
;

inline aoc::Ranges convertIntoRanges(const std::vector<std::string> &input) {
  aoc::Ranges ranges;

  for (const std::string &v : input) {
    const auto &r = aoc::split(v, '-');
    long begin = std::stol(r[0]);
    long end = std::stol(r[1]);

    ranges.insert({begin, end});
  }

  return ranges;
}

inline long countPart1(const std::vector<long> &idToCheck,
                       const aoc::Ranges &rngs) {
  long count = 0;
  for (const auto &id : idToCheck) {
    for (const auto &rng : rngs) {
      if (rng.is_inrange(id)) {
        count++;
      }
    }
  }
  return count;
}

inline long long countPart2(const aoc::Ranges &rngs) {
  return std::accumulate(rngs.begin(), rngs.end(), 0ll,
                         [](long sum, const aoc::Range &rng) {
                           return sum + rng.numOfElements();
                         });
}

inline long long solve(bool testing = true, bool part2 = false) {
  std::string filePath = "./input/day05/input.test.txt";
  if (!testing) {
    filePath = "./input/day05/input.txt";
  }

  std::vector<std::string> ranges;
  std::vector<long> idToCheck;

  bool loadIntoRanges = true;
  for (const std::string &line : aoc::loadFile(filePath)) {
    if (line == "") {
      loadIntoRanges = false;
      continue;
    }

    if (loadIntoRanges) {
      ranges.push_back(line);
    } else {
      idToCheck.push_back(std::stol(line));
    }
  }

  auto r = convertIntoRanges(ranges);

  long long count = 0;

  if (!part2) {
    count = countPart1(idToCheck, r);
  } else {
    count = countPart2(r);
  }

  return count;
}
} // namespace day05
