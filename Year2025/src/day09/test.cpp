#include "aoc/gtestHelpers.hpp"
#include "solution.hpp"
#include <gtest/gtest.h>

using namespace day09;

TEST(day09, Part1DEMO) {
  long output = solve();
  EXPECT_EQ(output, 50);
}

TEST(day09, Part1Actual) {
  long output = solve(false);
  EXPECT_EQ(output, 4773451098);
}

TEST(day09, Part2DEMO) {
  long output = solve(true, true);
  EXPECT_EQ(output, 24);
}

TEST(day09, Part2Actual) {
  long output = solve(false, true);
  EXPECT_EQ(output, 1429075575);
}

int main(int argc, char *argv[]) {
  return aoc::runUnitTests(argc, argv, "day09", true);
}
