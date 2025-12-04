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

cat >"src/$DAY/main.cpp" <<EOF
#include <iostream>
#include <fstream>
#include <string>

int main() {
    std::ifstream f(std::string(AOC_INPUT_DIR) + "/$DAY.txt");
    if (!f) { std::cerr << "Missing input/$DAY.txt\n"; return 1; }

    std::string line;
    while (std::getline(f, line)) {
        // Day $DAY_NUM
    }
    std::cout << "Part 1:\nPart 2:\n";
}
EOF

cat >"src/$DAY/meson.build" <<EOF
exe = executable(
  '$DAY',
  'main.cpp',
  dependencies: [common_dep],
  override_options: ['cpp_std=c++23'],
  install: true,
  install_dir: meson.source_root() / 'bin'
)
all_day_targets += exe
EOF

touch "input/$DAY.txt"

# Auto-reconfigure (silently)
echo "Configuring Meson..."
if [ -d build ]; then
  meson setup build --reconfigure --native-file native-clang.ini >/dev/null 2>&1
else
  meson setup build --native-file native-clang.ini >/dev/null 2>&1
fi

echo "Done! → ./bin/$DAY"
echo "   Build:    ninja -C build $DAY"
echo "   Run:      ./bin/$DAY"
echo ""
echo "   Tip: add this to your shell:"
echo "     alias n='ninja -C build'"
echo "     → then just: n $DAY"
