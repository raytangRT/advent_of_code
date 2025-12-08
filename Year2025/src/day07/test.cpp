#include "aoc/gtestHelpers.hpp"
#include "solution.hpp"

using namespace day07;

TEST(day07, Part1DEMO) {
  long output = solve();
  EXPECT_EQ(output, 21);
}

TEST(day07, Part1Actual) {
  long output = solve(false);
  EXPECT_EQ(output, 1681);
}

TEST(day07, Part2DEMO) {
  long output = solve(true, true);
  EXPECT_EQ(output, 40);
}

TEST(day07, Part2Actual) {
  long output = solve(false, true);
  EXPECT_EQ(output, 422102272495018);
}

int main(int argc, char *argv[]) {
  return aoc::runUnitTests(argc, argv, "day07");
}
