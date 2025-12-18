#include "aoc/aoc.hpp"
#include "aoc/fileHelpers.hpp"
#include "aoc/grid.hpp"
#include "aoc/matrix.hpp"
#include "aoc/rangeHelpers.hpp"
#include "gift.hpp"
#include "giftBox.hpp"
#include "spdlog/spdlog.h"
#include "src/day12/treeRegion.hpp"
#include <cstddef>
#include <optional>
#include <ranges>
#include <ratio>
#include <regex>
#include <string>
#include <unordered_set>
#include <utility>
#include <vector>

namespace day12 {
using namespace aoc;
using Grid = Grid<char>;

// Conversion function
inline auto to_char_vector(const std::string &s) {
  return std::vector<char>(s.begin(), s.end());
};

struct Input {
  std::vector<Grid> gifts;
  std::vector<std::pair<Grid, std::vector<size_t>>> trees;
};

inline Input parseInput(const std::string &filePath) {
  Input input;
  std::vector<std::string> lines = aoc::loadFile(filePath);
  size_t lineNo = 0;

  std::regex pattern(R"((\d+)x(\d+): (.*))");

  while (lineNo < lines.size()) {
    const std::string line = lines[lineNo];
    if (line == "0:" || line == "1:" || line == "2:" || line == "3:" ||
        line == "4:" || line == "5:") {
      Grid grid;
      grid.addRow(lines[lineNo + 1] | to_char_vector);
      grid.addRow(lines[lineNo + 2] | to_char_vector);
      grid.addRow(lines[lineNo + 3] | to_char_vector);
      lineNo += 5;
      input.gifts.push_back(grid);
      continue;
    }

    std::smatch matches;
    if (std::regex_match(lines[lineNo], matches, pattern)) {
      auto width = matches[1].str() | aoc::stoi_fn();
      auto height = matches[2].str() | aoc::stoi_fn();

      Grid grid(width, height, '.');

      auto numOfGifts = aoc::split(matches[3].str(), ' ') |
                        std::views::transform(aoc::stoul) |
                        std::ranges::to<std::vector>();

      input.trees.emplace_back(grid, numOfGifts);
      lineNo++;
    }
  }
  return input;
}
inline bool place([[gnu::unused]] const TreeRegion &region,
                  const GiftBox &giftBox, const std::vector<Gift> &gifts) {
  if (giftBox.isEmpty()) {
    spdlog::info("emptied giftbox");
    std::cerr << "emptied giftbox \r\n";
    return true;
  }

  for (const auto &[giftIdx, newGiftBox] : giftBox.pickGift()) {
    for (const auto &giftVariant : gifts[giftIdx].variants()) {
      for (const auto &location : region.available_locations(giftVariant)) {
        auto newRegion = region.try_place(location, giftVariant);
        if (newRegion != std::nullopt) {
          if (place(*newRegion, newGiftBox, gifts)) {
            return true;
          }
        }
      }
    }
  }
  return false;
}

inline long solvePart1(const Input &input) {
  long result = 0;

  std::vector<Gift> gifts =
      input.gifts |
      std::views::transform([](const Grid &rect) { return Gift(rect); }) |
      std::ranges::to<std::vector>();

  for (const auto &[region, giftCombo] : input.trees) {
    TreeRegion treeRegion(region);
    GiftBox giftBox(giftCombo);
    if (treeRegion.size() <= giftBox.total_area(gifts)) {
      std::cerr << "skipping .....\r\n";
      continue;
    }

    if (place(treeRegion, giftBox, gifts)) {
      result++;
    }
  }

  return result; // Replace with actual logic later
}

inline long solvePart1_attempt2(const Input &input) {
  long result = 0;

  std::vector<Gift> gifts =
      input.gifts |
      std::views::transform([](const Grid &rect) { return Gift(rect); }) |
      std::ranges::to<std::vector>();

  for (const auto &[region, giftCombo] : input.trees) {
    TreeRegion treeRegion(region);
    GiftBox giftBox(giftCombo);

    size_t total_area_required = giftBox.total_area(gifts);
    if (treeRegion.size() >= total_area_required) {
      result++;
    }
  }
  return result;
}

inline long solve(bool testing = true, [[gnu::unused]] bool part2 = false) {
  std::string filePath = "./input/day12/input.test.txt";
  if (!testing) {
    filePath = "./input/day12/input.txt";
  }

  Input input = parseInput(filePath);

  if (!part2) {
    return solvePart1_attempt2(input);
  }

  return 0;
}
} // namespace day12
