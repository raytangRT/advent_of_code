#include "aoc/gtestHelpers.hpp"
#include "solution.hpp"
#include <gtest/gtest.h>

using namespace Day04;

TEST(Day04, Part1DEMO) {
  long output = solve();
  EXPECT_EQ(output, 13);
}

TEST(Day04, Part1Actual) {
  long output = solve(false);
  EXPECT_EQ(output, 1370);
}

TEST(Day04, Part2DEMO) {
  long output = solve(true, true);
  EXPECT_EQ(output, 43);
}

TEST(Day04, Part2Actual) {
  long output = solve(false, true);
  EXPECT_EQ(output, 8437);
}
int main(int argc, char *argv[]) {
  return aoc::runUnitTests(argc, argv, "Day04", true);
}
