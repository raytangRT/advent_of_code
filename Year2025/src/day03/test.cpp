#include "aoc/gtestHelpers.hpp"
#include "solution.hpp"
#include "gtest/gtest.h"
#include <gtest/gtest.h>
#include <sstream>
#include <string>

using namespace Day03;

struct TestParams {
  std::string bank;
  long expectedJolt;
  bool isPart1 = true;

  std::string to_string() const {
    std::stringstream ss;
    ss << "bank = " << bank << "|";
    ss << "expectedJolt = " << expectedJolt << "|";
    ss << "isPart1 = " << isPart1;
    return ss.str();
  }
};

class Day03CalculateTest : public testing::TestWithParam<TestParams> {};

TEST_P(Day03CalculateTest, TestDay03) {
  const auto &[bank, expectedJolt, isPart1] = GetParam();

  long output = 0;
  if (isPart1)
    output = calculateMaxJolt(bank);
  else
    output = calculateMaxJoltPart2(bank);

  EXPECT_EQ(output, expectedJolt)
      << "bank = " << bank << ", expectedJolt = " << expectedJolt
      << ", actualJolt = " << output;
}

// clang-format off
INSTANTIATE_TEST_SUITE_P(Day03CalculatePart1Test, Day03CalculateTest, aoc::test_params<TestParams>({
   {"987654321111111", 98}
 , {"811111111111119", 89}
 , {"234234234234278", 78}
 , {"818181911112111", 92}
}));

INSTANTIATE_TEST_SUITE_P(Day03CalculatePart2Test, Day03CalculateTest, aoc::test_params<TestParams>({
   {"987654321111111", 987654321111, false}
 , {"811111111111119", 811111111119, false}
 , {"234234234234278", 434234234278, false}
 , {"818181911112111", 888911112111, false}
}));

// clang-format on

TEST(Day03_Part1, Part1Demo) {
  long output = solve(true);
  EXPECT_EQ(output, 357);
}

TEST(Day03_Part1, Part1Actual) {
  long output = solve(false);
  EXPECT_EQ(output, 17493);
}

TEST(Day03, Part2DEMO) {
  long output = solve(true, true);
  EXPECT_EQ(output, 3121910778619);
}

TEST(Day03, Part2Actual) {
  long output = solve(false, true);
  EXPECT_EQ(output, 173685428989126);
}

int main(int argc, char *argv[]) {
  return aoc::runUnitTests(argc, argv, "Day03", true);
}
