#include <iostream>

namespace Day04 {

inline long solve(bool testing = true, bool part2 = false) {
  std::string filePath = "./input/Day04/input.test.txt";
  if (!testing) {
    filePath = "./input/Day04/input.txt";
  }
  std::cout << testing << part2;
  return 0;
}
} // namespace Day04
