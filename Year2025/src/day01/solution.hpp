#include "aoc/fileHelpers.hpp"

namespace Day01 {
inline int modulo(int a, int b) {
  const int result = a % b;
  return result >= 0 ? result : result + b;
}

struct Output {
  int newLocation;
  int numOfClicks;
};

inline Output count_part1(const int start, const int move) {
  int newLocation = modulo(start + move, 100);
  return Output(newLocation, newLocation == 0 ? 1 : 0);
}

inline Output count_part2(const int location, const int move) {
  auto d = std::div(move, 100);
  int numOfClicks = std::abs(d.quot);
  int remindingMoves = d.rem;

  int newLocation = location + remindingMoves;
  if (location != 0 && (newLocation < 0 || newLocation > 100)) {
    numOfClicks++;
  }
  newLocation = modulo(newLocation, 100);
  if (newLocation == 0) {
    numOfClicks++;
  }

  return Output{newLocation, numOfClicks};
}

//
// Put your solution code directly here or in common/
inline int solve(const std::string &filePath, bool part1) {
  auto data = aoc::loadFile(filePath);
  int location = 50;
  int numOfZero = 0;
  for (auto &d : data) {
    int sign = d.front() == 'L' ? -1 : 1;
    d.erase(0, 1);
    int move = sign * std::stoi(d);

    auto f = count_part1;
    if (!part1) {
      f = count_part2;
    }

    const Output output = f(location, move);
    location = output.newLocation;
    numOfZero += output.numOfClicks;
  }

  return numOfZero;
}
} // namespace Day01
