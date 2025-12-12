#include "aoc/aoc.hpp"
#include "aoc/fileHelpers.hpp"
#include "aoc/points.hpp"
#include <algorithm>
#include <cstddef>
#include <format>
#include <iostream>
#include <ranges>
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
        int x1 = std::min(p1.x, p2.x), x2 = std::max(p1.x, p2.x),
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
// Helper to get min/max for a pair of points
struct Bounds {
  long long min_x, max_x, min_y, max_y;
};

inline Bounds get_bounds(const aoc::Point &a, const aoc::Point &b) {
  return {std::min(a.x, b.x), std::max(a.x, b.x), std::min(a.y, b.y),
          std::max(a.y, b.y)};
}

inline long part2SolverV2(std::vector<aoc::Point> &points) {
  size_t n = points.size();
  auto calculateSize = [](const aoc::Point &p1, const aoc::Point &p2) {
    auto width = abs(p1.x - p2.x) + 1;
    auto height = abs(p1.y - p2.y) + 1;
    return width * height;
  };

  struct Edge {
    aoc::Point p1, p2;
  };

  struct Candidate {
    long long area;
    aoc::Point p1, p2; // p1 is the "top-left-ish", p2 "bottom-right-ish"
  };

  std::vector<Edge> edges;
  edges.reserve(n);
  for (size_t i = 0; i < n; i++) {
    edges.emplace_back(points[i], points[(i + n - 1) % n]);
  }

  std::vector<Candidate> candidates;
  candidates.reserve(n * (n - 1) / 2);

  for (size_t i = 0; i < n; ++i) {
    for (size_t j = i + 1; j < n; ++j) {
      aoc::Point a = points[i];
      aoc::Point b = points[j];
      long long area = calculateSize(a, b);
      if (a.x > b.x || (a.x == b.x && a.y > b.y)) {
        std::swap(a, b);
      }
      candidates.push_back({area, a, b});
    }
  }
  //
  // Sort descending by area
  std::sort(
      candidates.begin(), candidates.end(),
      [](const Candidate &a, const Candidate &b) { return a.area > b.area; });
  // Check each candidate from largest to smallest
  for (const auto &cand : candidates) {
    const auto rect = get_bounds(cand.p1, cand.p2);
    // Rectangle interior: (rect.min_x, rect.min_y) to (rect.max_x, rect.max_y)
    // Strictly inside: x > min_x && x < max_x, same for y

    bool crossed = false;
    for (const auto &edge : edges) {
      const auto eb = get_bounds(edge.p1, edge.p2);

      // Does this edge cross strictly through the interior both horizontally
      // and vertically?
      bool spans_x = (eb.max_x > rect.min_x) && (eb.min_x < rect.max_x);
      bool spans_y = (eb.max_y > rect.min_y) && (eb.min_y < rect.max_y);

      if (spans_x && spans_y) {
        crossed = true;
        break;
      }
    }

    if (!crossed) {
      return cand.area; // No boundary edge crosses interior → valid and largest
    }
  }
  return 0;
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
    return part2SolverV2(points);
  }
}
} // namespace day09
