#include "aoc/gtestHelpers.hpp"
#include "solution.hpp"
#include <gtest/gtest.h>

using namespace day08;

TEST(day08, Part1DEMO) {
  long output = solve(10);
  EXPECT_EQ(output, 40);
}

TEST(day08, Part1Actual) {
  long output = solve(1000, false);
  EXPECT_GT(output, 720);
  EXPECT_EQ(output, 129564);
}

TEST(day08, Part2DEMO) {
  long output = solve(0, true, true);
  EXPECT_EQ(output, 25272);
}

TEST(day08, Part2Actual) {
  long output = solve(0, false, true);
  EXPECT_EQ(output, 42047840);
}

int main(int argc, char *argv[]) {
  return aoc::runUnitTests(argc, argv, "day08", true);
}
