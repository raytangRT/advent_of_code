#!/usr/bin/env bash
# newday.sh — perfect AoC day creator + auto-reconfigure
set -euo pipefail

[[ $# -eq 1 && $1 =~ ^[0-9]+$ && $1 -ge 1 && $1 -le 25 ]] || {
  echo "Usage: $0 <day> (1-25)"
  exit 1
}

DAY_NUM=$1
DAY=$(printf "day%02d" "$DAY_NUM")

echo "Creating $DAY ..."

mkdir -p "src/$DAY" bin input

cat >"src/$DAY/test.cpp" <<EOF
#include "aoc/gtestHelpers.hpp"
#include "solution.hpp"

using namespace $DAY;

TEST($DAY, Part1DEMO) {
  long output = solve();
  EXPECT_EQ(output, 13);
}

TEST($DAY, DISABLED_Part1Actual) {
  long output = solve(false);
  EXPECT_EQ(output, 13);
}

TEST($DAY, DISABLED_Part2DEMO) {
  long output = solve(true, false);
  EXPECT_EQ(output, 13);
}

TEST($DAY, DISABLED_Part2Actual) {
  long output = solve(false, true);
  EXPECT_EQ(output, 13);
}

int main(int argc, char *argv[]) {
  return aoc::runUnitTests(argc, argv, "$DAY");
}
EOF

cat >"src/$DAY/solution.hpp" <<EOF
#include "aoc/aoc.hpp"

namespace $DAY {

inline long solve(bool testing = true, [[gnu::unused]] bool part2 = false) {
  std::string filePath = "./input/$DAY/input.test.txt";
  if (!testing) {
    filePath = "./input/$DAY/input.txt";
  }

  return 0;
}
}
EOF

mkdir -p "input/$DAY"
touch "input/$DAY/input.test.txt"
touch "input/$DAY/input.txt"

# Auto-reconfigure (silently)
echo "Configuring Meson..."
meson setup build --reconfigure --native-file native-clang.ini

echo "Done! → ./bin/$DAY"
echo "   Test:    ninja test -C build"
