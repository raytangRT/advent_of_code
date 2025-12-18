#include "aoc/gtestHelpers.hpp"
#include "solution.hpp"
#include "src/day12/treeRegion.hpp"
#include <optional>
#include <vector>

using namespace day12;

TEST(day12, Part1DEMO) {
  long output = solve();
  EXPECT_EQ(output, 2);
}

TEST(day12, Part1Actual) {
  long output = solve(false);
  EXPECT_EQ(output, 433);
}

TEST(day12, Part2DEMO) {
  GTEST_SKIP();
  long output = solve(true, true);
  EXPECT_EQ(output, 13);
}

TEST(day12, Part2Actual) {
  GTEST_SKIP();
  long output = solve(false, true);
  EXPECT_EQ(output, 13);
}

int main(int argc, char *argv[]) {
  return aoc::runUnitTests(argc, argv, "day12", true);
}
