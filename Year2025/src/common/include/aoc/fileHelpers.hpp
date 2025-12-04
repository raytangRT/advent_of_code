#pragma once

#include <filesystem>
#include <fstream>
#include <stdexcept>
#include <string>
#include <vector>

namespace aoc {

inline std::vector<std::string> loadFile(const std::string &filePath) {
  if (!std::filesystem::exists(filePath)) {
    throw std::invalid_argument("file not found");
  }
  std::ifstream inputFile(filePath);
  std::string line;
  std::vector<std::string> result;
  while (std::getline(inputFile, line)) {
    result.push_back(line);
  }
  return result;
}
} // namespace aoc
