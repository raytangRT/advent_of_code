#include "aoc/gtestHelpers.hpp"
#include "solution.hpp"

using namespace day06;

TEST(day06, Part1DEMO) {
  long output = solve();
  EXPECT_EQ(output, 4277556);
}

TEST(day06, Part1Actual) {
  long output = solve(false);
  EXPECT_EQ(output, 6172481852142);
}

TEST(day06, Part2DEMO) {
  long output = solve(true, true);
  EXPECT_EQ(output, 3263827);
}

TEST(day06, Part2Actual) {
  long output = solve(false, true);
  EXPECT_EQ(output, 10188206723429);
}

int main(int argc, char *argv[]) {
  return aoc::runUnitTests(argc, argv, "day06", true);
}
