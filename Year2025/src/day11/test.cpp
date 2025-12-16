#include "aoc/gtestHelpers.hpp"
#include "solution.hpp"

using namespace day11;

TEST(day11, Part1DEMO) {
  long output = solve();
  EXPECT_EQ(output, 5);
}

TEST(day11, Part1Actual) {
  long output = solve(false);
  EXPECT_EQ(output, 511);
}

TEST(day11, Part2DEMO) {
  long output = solve(true, true);
  EXPECT_EQ(output, 2);
}

TEST(day11, Part2Actual) {
  long output = solve(false, true);
  EXPECT_EQ(output, 458618114529380);
}

int main(int argc, char *argv[]) {
  return aoc::runUnitTests(argc, argv, "day11", true);
}
