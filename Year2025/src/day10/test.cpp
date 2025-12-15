#include "aoc/gtestHelpers.hpp"
#include "solution.hpp"
#include <gtest/gtest.h>

using namespace day10;

TEST(day10, Part1DEMO) {
  long output = solve();
  EXPECT_EQ(output, 7);
}

TEST(day10, Part1Actual) {
  long output = solve(false);
  EXPECT_EQ(output, 507);
}

TEST(day10, Part2DEMO) {
  long output = solve(true, true);
  EXPECT_EQ(output, 33);
}

TEST(day10, Part2Actual) {
  long output = solve(false, true);
  EXPECT_EQ(output, 18981);
}

int main(int argc, char *argv[]) {
  return aoc::runUnitTests(argc, argv, "day10", true);
}
