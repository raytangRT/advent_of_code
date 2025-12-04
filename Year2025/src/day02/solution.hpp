#include "aoc/fileHelpers.hpp"
#include <stdexcept>
#include <string>

namespace Day02 {

inline int solve(const std::string &fileName) {
  const std::vector<std::string> lines = aoc::loadFile(fileName);
  if (lines.size() > 1) {
    throw std::invalid_argument("should be a one liner input");
  }
  const std::string line = lines[0];
  return 0;
}
} // namespace Day02
