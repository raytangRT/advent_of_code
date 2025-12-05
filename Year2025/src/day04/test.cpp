#include "aoc/gtestHelpers.hpp"
#include "solution.hpp"

using namespace Day04;

TEST(Day04, Part1DEMO) {
  long output = solve();
  EXPECT_EQ(output, 13);
}

TEST(Day04, Part1Actual) {
  long output = solve(false);
  EXPECT_EQ(output, 13);
}

int main(int argc, char *argv[]) {
  return aoc::runUnitTests(argc, argv, "Day04");
}
