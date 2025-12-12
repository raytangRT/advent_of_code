#include "aoc/aoc.hpp"
#include "aoc/fileHelpers.hpp"
#include "aoc/points.hpp"
#include <algorithm>
#include <cstddef>
#include <format>
#include <iostream>
#include <unordered_set>
#include <vector>

namespace day09 {

inline double part1Solver(const std::vector<aoc::Point> &points) {
  double maxValue = 0;
  for (size_t i = 0; i < points.size(); i++) {
    const aoc::Point &p1 = points[i];
    for (size_t j = 0; j < i; j++) {
      const aoc::Point &p2 = points[j];
      double width = abs(p1.x - p2.x) + 1;
      double height = abs(p1.y - p2.y) + 1;

      maxValue = std::max(maxValue, width * height);
    }
  }
  return maxValue;
}

using Edges = std::vector<std::pair<aoc::Point, aoc::Point>>;

inline Edges calculateEdges(const std::vector<aoc::Point> &points) {
  Edges edges;
  size_t numOfPoints = points.size();
  for (size_t i = 0; i < numOfPoints; i++) {
    auto p1 = points[i];
    auto p2 = points[(i + 1) % numOfPoints];

    if (p1.x == p2.x) {
      if (p1.y > p2.y) {
        std::swap(p1, p2);
      }
      edges.emplace_back(p1, p2);
    }
  }

  return edges;
}

inline long part2Solver(std::vector<aoc::Point> &points) {
  // all vertical edges of the polygon
  Edges edges = calculateEdges(points);

  std::unordered_set<aoc::Point> invalidPoints;

  auto isValidPoint = [&](const aoc::Point &point) {
    if (invalidPoints.contains(point)) {
      return false;
    }

    bool isValidPoint = false;
    for (const auto &[start, end] : edges) {
      if (start.x >= point.x && start.y <= point.y && point.y < end.y) {
        isValidPoint = !isValidPoint;
      }
    }
    if (!isValidPoint) {
      invalidPoints.insert(point);
    }

    return isValidPoint;
  };

  long maxSize = 0;
  for (size_t i = 0; i < points.size(); i++) {
    const aoc::Point &p1 = points[i];
    for (size_t j = 0; j < i; j++) {
      const aoc::Point &p2 = points[j];
      if (p1.x != p2.x && p1.y != p2.y) {
        double x1 = std::min(p1.x, p2.x), x2 = std::max(p1.x, p2.x),
               y1 = std::min(p1.y, p2.y), y2 = std::max(p1.y, p2.y);
        aoc::Point p3{x1, y2};
        aoc::Point p4{x2, y1};
        aoc::Point center{(x1 + x2) / 2, (y1 + y2) / 2};

        if (isValidPoint(p3) && isValidPoint(p4) && isValidPoint(center)) {
          long size = long(abs(p1.x - p2.x) + 1) * (abs(p1.y - p2.y) + 1);
          maxSize = std::max(maxSize, size);
        }
      }
    }
  }

  return maxSize;
}

inline long solve(bool testing = true, [[gnu::unused]] bool part2 = false) {
  std::string filePath = "./input/day09/input.test.txt";
  if (!testing) {
    filePath = "./input/day09/input.txt";
  }

  auto points = aoc::loadFile(filePath) |
                std::views::transform([](const auto &line) {
                  auto values = aoc::split(line, ',') |
                                std::views::transform([](const auto &s) {
                                  return aoc::to_long(s);
                                });
                  return aoc::Point{values[0], values[1]};
                }) |
                std::ranges::to<std::vector<aoc::Point>>();

  if (!part2) {
    return part1Solver(points);
  } else {
    return part2Solver(points);
  }
}
} // namespace day09
