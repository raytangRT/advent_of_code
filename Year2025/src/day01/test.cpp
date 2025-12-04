#include "solution.hpp"
#include <aoc/gtestHelpers.hpp>
#include <cstdlib>
#include <gtest/gtest.h>
#include <iostream>
#include <tuple>
using namespace Day01;

TEST(Day01, DISABLED_Part1) {
  int output = Day01::solve("./input/day01/part1.test.txt", true);
  EXPECT_EQ(3, output);
}

TEST(Day01, DISABLED_Part1_Actual) {
  int output = solve("./input/day01/part1.txt", true);
  EXPECT_EQ(969, output);
}

TEST(Day01, Part2) {
  int output = solve("./input/day01/part1.test.txt", false);
  EXPECT_EQ(6, output);
}

TEST(Day01, Part2_Actual) {
  int output = solve("./input/day01/part1.txt", false);
  EXPECT_GT(output, 2499);
  EXPECT_GT(output, 3789) << "still too low";
  EXPECT_GT(output, 4374) << "still too low";
  EXPECT_EQ(output, 5887) << "logic output";
};

class TestSolvePart2
    : public testing::TestWithParam<std::tuple<int, int, Day01::Output>> {};

// 2. Define Parameterized Tests
TEST_P(TestSolvePart2, TestCountPart2) {
  const auto [loc, move, expectedOutput] = GetParam();
  auto output = count_part2(loc, move);

  EXPECT_EQ(output.newLocation, expectedOutput.newLocation)
      << "should be " << loc << " + " << move << " = "
      << expectedOutput.newLocation
      << " && withClicks = " << expectedOutput.numOfClicks;
  EXPECT_EQ(output.numOfClicks, expectedOutput.numOfClicks)
      << "should be " << loc << " + " << move << " = "
      << expectedOutput.newLocation
      << " && withClicks = " << expectedOutput.numOfClicks;
}

std::tuple<int, int, Output> _(int cur, int move, int expectedNew,
                               int expectedNumOfClicks) {
  return std::tuple(cur, move, Output{expectedNew, expectedNumOfClicks});
}
// clang-format off
// 3. Instantiate the Test Suite
INSTANTIATE_TEST_SUITE_P(Part2Solvers, TestSolvePart2, testing::Values(
   _(50, -68, 82, 1)
  ,_(82, 30, 12, 1)
  ,_(82, 130, 12, 2)
  ,_(82, 530, 12, 6)
  ,_(82, 18, 0, 1)
  ,_(50, -68, 82, 1)
  ,_(82, -30, 52, 0)
  ,_(52, 48, 0, 1)
  ,_(0, -5, 95, 0)
  ,_(95, 60, 55, 1)
  ,_(55, -55, 0, 1)
  ,_(0, -1, 99, 0)
  ,_(99, -99, 0, 1)
  ,_(0, 14, 14, 0)
  ,_(14, -82, 32, 1)
));
// clang-format on

int main(int argc, char **argv) {
  return aoc::runUnitTests(argc, argv, "day1");
}
