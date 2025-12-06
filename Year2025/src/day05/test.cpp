#include "aoc/gtestHelpers.hpp"
#include "solution.hpp"

using namespace day05;

TEST(day05, Part1DEMO) {
  long output = solve();
  EXPECT_EQ(output, 3);
}

TEST(day05, Part1Actual) {
  long output = solve(false);
  EXPECT_EQ(output, 733);
}

TEST(day05, Part2DEMO) {
  long output = solve(true, true);
  EXPECT_EQ(output, 14);
}

TEST(day05, Part2Actual) {
  long long output = solve(false, true);
  EXPECT_EQ(output, 345821388687084);
}

int main(int argc, char *argv[]) {
  return aoc::runUnitTests(argc, argv, "day05", true);
}
