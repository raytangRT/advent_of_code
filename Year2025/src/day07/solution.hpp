#include "aoc/aoc.hpp"
#include "aoc/graph.hpp"
#include "aoc/grid.hpp"
#include "fmt/format.h"
#include <cstddef>
#include <future>
#include <iostream>
#include <memory>
#include <numeric>
#include <stdexcept>

namespace day07 {

inline long countPart1(aoc::Grid &grid) {
  long splitCount = 0;
  for (aoc::RowIdx i = 1; i < grid.height(); i++) {
    for (aoc::ColIdx j = 0; j < grid.width(); j++) {
      const char c = grid[i][j];
      if (c == '.' && grid[i - 1][j] == 'S') {
        grid[i][j] = '|';
        continue;
      }

      if (c == '^' && grid[i - 1][j] == '|') {
        if (j > 0) {
          if (grid[i][j - 1] != '^') {
            grid[i][j - 1] = '|';
          }
        }

        if (j < grid.width()) {
          if (grid[i][j + 1] != '^') {
            grid[i][j + 1] = '|';
          }
        }

        splitCount++;
      }

      if (c == '.' && grid[i - 1][j] == '|') {
        grid[i][j] = '|';
      }
    }
  }
  return splitCount;
}

inline long countPart2(aoc::Grid &grid) {
  aoc::Graph<long> graph;

  for (aoc::RowIdx i = 0; i < grid.height(); i++) {
    for (aoc::ColIdx j = 0; j < grid.width(); j++) {
      const char c = grid[i][j];
      if (i == 0) {
        if (c == 'S') {
          graph.addRoot({i, j}, 'S');
          break;
        }
        continue;
      }

      if (c == '.' && grid[i - 1][j] == 'S') {
        grid[i][j] = '|';
        graph.addNode({i, j}, 0).ChildOf({i - 1, j});
        break;
      }

      if (c == '^' && grid[i - 1][j] == '|') {
        if (j > 0) {
          if (grid[i][j - 1] != '^') {
            grid[i][j - 1] = '|';

            graph.addNode({i, j - 1}, 0).ChildOf({i - 1, j});
          }
        }

        if (j < grid.width()) {
          if (grid[i][j + 1] != '^') {
            grid[i][j + 1] = '|';
            graph.addNode({i, j + 1}, 0).ChildOf({i - 1, j});
          }
        }
        continue;
      }

      if (grid[i - 1][j] == '|') {
        grid[i][j] = '|';
        graph.addNode({i, j}, 0).ChildOf({i - 1, j});
      }
    }
  }

  std::function<void(std::shared_ptr<aoc::GraphNode<long>>)> dfs =
      [&](std::shared_ptr<aoc::GraphNode<long>> node) {
        if (!node) {
          return;
        }

        auto children = node->children;
        if (children.empty() && node->value == 0) {
          node->value = 1;
          return;
        }

        for (auto &child : node->children) {
          if (child->value == 0)
            dfs(child);
        }

        node->value =
            std::accumulate(children.begin(), children.end(), 0l,
                            [](long sum, auto &n) { return sum + n->value; });
      };

  std::shared_ptr<aoc::GraphNode<long>> root = graph.root();
  dfs(root);

  return root->value;
}

inline long solve(bool testing = true, [[gnu::unused]] bool part2 = false) {
  std::string filePath = "./input/day07/input.test.txt";
  if (!testing) {
    filePath = "./input/day07/input.txt";
  }

  aoc::Grid grid(filePath);

  long splitCount = 0;

  if (!part2) {
    splitCount = countPart1(grid);
  } else {
    splitCount = countPart2(grid);
  }
  return splitCount;
}
} // namespace day07
