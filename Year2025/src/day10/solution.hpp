#include "absl/hash/hash.h"
#include "aoc/aoc.hpp"
#include "aoc/dynamic_bit.hpp"
#include "aoc/fileHelpers.hpp"
#include "aoc/hashHelpers.hpp"
#include "aoc/matrix.hpp"
#include "aoc/rangeHelpers.hpp"
#include "fmt/base.h"
#include "z3++.h"
#include <absl/strings/str_replace.h>
#include <algorithm>
#include <cstddef>
#include <numeric>
#include <optional>
#include <ostream>
#include <queue>
#include <ranges>
#include <regex>
#include <string>
#include <unordered_set>
#include <vector>

namespace day10 {

struct Input {
  aoc::DynamicBits requiredOutput;
  std::vector<aoc::DynamicBits> buttons;
  std::vector<size_t> requiredJolts;
};

inline std::vector<Input> parseInputs(const std::string &filePath) {
  std::vector<Input> inputs;
  std::smatch matches;

  for (const auto &line : aoc::loadFile(filePath)) {
    if (!std::regex_search(line, matches,
                           std::regex(R"(\[([.#]+)\] (.*) \{(.*)\})"))) {
      continue;
    }

    aoc::DynamicBits requiredOutput(
        absl::StrReplaceAll(matches[1].str(), {{".", "0"}, {"#", "1"}}));

    size_t n = requiredOutput.size();

    std::vector<aoc::DynamicBits> buttons =
        aoc::RegexMatchers(R"(\(([0-9,]+)\))", matches[2]) |
        std::views::transform([n](const std::smatch &match) {
          return aoc::DynamicBits(
              aoc::split(match[1], ',') | std::views::transform(aoc::stoi) |
              aoc::accumulate(std::vector(n, false), [](auto v, size_t idx) {
                v[idx] = true;
                return v;
              }));
        }) |
        std::ranges::to<std::vector>();

    std::vector<size_t> jolts = aoc::split(matches[3], ',') |
                                std::views::transform(aoc::stoi) |
                                std::ranges::to<std::vector<size_t>>();

    inputs.emplace_back(requiredOutput, buttons, jolts);
  }

  return inputs;
}
inline long solvePart1_bfs(const std::vector<Input> &inputs) {
  return inputs | aoc::accumulate(0l, [](long total, const Input &input) {
           const aoc::DynamicBits &expectedOutput = input.requiredOutput;
           aoc::DynamicBits start(expectedOutput.size(), false);
           std::queue<aoc::DynamicBits> queue;
           std::unordered_set<aoc::DynamicBits> visited;
           long pressed = 0;

           queue.push(start);
           visited.insert(start);

           while (!queue.empty()) {
             for (const aoc::DynamicBits &current : aoc::pop_all(queue)) {
               if (current == expectedOutput) {
                 return total + pressed;
               }

               for (const aoc::DynamicBits &button : input.buttons) {
                 aoc::DynamicBits next = current ^ button;
                 if (!visited.contains(next)) {
                   visited.insert(next);
                   queue.push(next);
                 }
               }
             }
             pressed++;
           }
           std::cerr << "not found for " << expectedOutput << std::endl;

           return total;
         });
}

inline long solvePart1(const std::vector<Input> &inputs) {
  size_t total = 0;
  for (const auto &input : inputs) {
    aoc::DynamicBits requiredOutput = input.requiredOutput;
    size_t n = requiredOutput.size();

    size_t count = 1;
    bool found = false;
    std::vector<aoc::DynamicBits> buttons = input.buttons;
    std::vector<aoc::DynamicBits> inputs(n, requiredOutput);

    auto calculateCombo = [buttons,
                           n](const std::vector<aoc::DynamicBits> &inputs)
        -> std::optional<std::vector<aoc::DynamicBits>> {
      std::vector<aoc::DynamicBits> newInputs;
      for (const auto &button : buttons) {
        for (const auto &input : inputs) {
          auto result = button ^ input;
          if (result == aoc::DynamicBits::min(n)) {
            return std::nullopt;
          }
          newInputs.push_back(result);
        }
      }
      return std::make_optional(newInputs);
    };

    while (count < 100) {
      auto newInputs = calculateCombo(inputs);
      if (!newInputs) {
        found = true;
        break;
      }
      inputs = *newInputs;
      count++;
    }

    if (found) {
      total += count;
    } else {
      std::cerr << "not found for " << input.requiredOutput << std::endl;
    }
  }

  return total;
}

inline long solvePart2(const std::vector<Input> &inputs) {
  return inputs | aoc::accumulate(0l, [](long total, const Input &input) {
           auto requiredJolts = input.requiredJolts;
           size_t n = requiredJolts.size();
           aoc::Matrix<float> matrix;

           for (size_t i = 0; i < n; i++) {
             aoc::DynamicBits bitmask(n, false);
             bitmask.flip_at(i);

             std::vector<float> row;
             for (const auto &button : input.buttons) {
               float num = 0.0;
               if ((button & bitmask) == bitmask) {
                 num = 1.0;
               }
               row.push_back(num);
             }

             matrix.addRow(row);
           }

           std::vector<float> rhs =
               requiredJolts | std::views::transform(aoc::cast<size_t, float>) |
               std::ranges::to<std::vector>();

           aoc::Matrix<float> aug(matrix);
           aug.concatenate(rhs);

           auto reduced = matrix.gaussian_elimination(rhs);

           std::vector<bool> isFree;
           auto x = reduced.rref_solution(isFree);

           return total + std::accumulate(
                              x.begin(), x.end(), 0l,
                              [](auto sum, const auto &v) { return sum + v; });
         });
}
inline long solvePart2_z3(const std::vector<Input> &inputs) {
  long result = 0;
  for (const auto &input : inputs) {
    z3::context c;
    std::vector<z3::expr> vars;
    z3::optimize optimize(c);

    size_t maxJolt = *std::max_element(input.requiredJolts.begin(),
                                       input.requiredJolts.end());
    for (size_t i = 0; i < input.buttons.size(); i++) {
      std::string varName = std::format("x{}", i);
      auto var = c.int_const(varName.c_str());
      vars.push_back(var);
      optimize.add(var >= 0);
      optimize.add(var <= c.int_val((int)maxJolt));
    }

    for (const auto &[ridx, requiredJolt] :
         aoc::enumerate(input.requiredJolts)) {
      z3::expr lhs = c.int_val(0);
      aoc::DynamicBits bitmask(input.requiredJolts.size(), false);
      bitmask.flip_at(ridx);

      for (const auto &[bidx, button] : aoc::enumerate(input.buttons)) {
        if ((button & bitmask) == bitmask) {
          lhs = lhs + vars[bidx];
        }
      }

      optimize.add(lhs == c.int_val(int(requiredJolt)));
    }
    z3::expr total_cost = c.int_val(0);
    for (const auto &var : vars) {
      total_cost = total_cost + var;
    }
    optimize.minimize(total_cost); // Add minimization objective

    if (optimize.check() == z3::sat) {
      z3::model m = optimize.get_model();
      auto total = vars | aoc::accumulate(0l, [&m](auto total, auto var) {
                     return total + m.eval(var).as_int64();
                   });
      result += total;
    } else {
      std::cerr << aoc::to_string(input.requiredJolts)
                << " > No solution exists (unsat)" << std::endl;
    }
  }
  return result;
}

inline long solve(bool testing = true, [[gnu::unused]] bool part2 = false) {
  std::string filePath = "./input/day10/input.test.txt";
  if (!testing) {
    filePath = "./input/day10/input.txt";
  }
  std::vector<Input> inputs = parseInputs(filePath);

  if (!part2) {
    return solvePart1_bfs(inputs);
  } else {
    return solvePart2_z3(inputs);
  }
}
} // namespace day10
