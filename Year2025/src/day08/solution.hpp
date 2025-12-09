#include "aoc/aoc.hpp"
#include "aoc/fileHelpers.hpp"
#include "aoc/numberHelpers.hpp"
#include "aoc/points.hpp"
#include <absl/hash/hash.h>
#include <algorithm>
#include <iostream>
#include <queue>
#include <ranges>
#include <string>
#include <unordered_set>
#include <utility>
#include <vector>

namespace day08 {

struct JunctionBox {
  size_t idx;
  aoc::Point3d point;

  JunctionBox(size_t idx, int x, int y, int z) : idx{idx}, point(x, y, z) {}

  bool operator==(const JunctionBox &other) const {
    return idx == other.idx && point == other.point;
  }

  // template <typename H> friend H AbslHashValue(H h, const JunctionBox &jb) {
  // return H::combine(std::move(h), jb.idx, jb.point);
  // }
  struct HashFunction {
    size_t operator()(const JunctionBox &jb) const {
      return absl::HashOf(jb.idx, jb.point.x, jb.point.y, jb.point.z);
    }
  };
};

using Type = std::pair<double, std::pair<JunctionBox, JunctionBox>>;

struct TypeGreater {
  constexpr bool operator()(const Type t1, const Type t2) {
    return t1.first > t2.first;
  }
};

struct Circuit {
private:
  std::unordered_set<JunctionBox, JunctionBox::HashFunction> junctionBoxes;

public:
  bool exists(const JunctionBox &jb) {
    return junctionBoxes.find(jb) != junctionBoxes.end();
  }

  void insert(const JunctionBox &jb) { junctionBoxes.insert(jb); }

  size_t size() const { return junctionBoxes.size(); }

  void clear() { junctionBoxes.clear(); }

  static Circuit *merge(Circuit *left, Circuit *right) {
    Circuit *merged = new Circuit();

    merged->junctionBoxes.insert_range(left->junctionBoxes);
    merged->junctionBoxes.insert_range(right->junctionBoxes);
    left->clear();
    right->clear();

    return merged;
  }
};

using DistanceMinHeap =
    std::priority_queue<Type, std::vector<Type>, TypeGreater>;

inline long part2Solver(size_t numOfJunctionBox, DistanceMinHeap &minHeap) {
  std::vector<Circuit *> circuits;
  while (true) {
    const auto [distance, pair] = minHeap.top();
    const auto &[left, right] = pair;
    minHeap.pop();

    Circuit *leftCircuit = nullptr, *rightCircuit = nullptr;

    for (auto c : circuits) {
      if (c->exists(left)) {
        leftCircuit = c;
      }
      if (c->exists(right)) {
        rightCircuit = c;
      }
    }

    if (leftCircuit == nullptr && rightCircuit == nullptr) {
      Circuit *c = new Circuit();
      c->insert(left);
      c->insert(right);
      circuits.push_back(c);
    }

    size_t newCircuitSize = 0;
    if (leftCircuit == nullptr && rightCircuit != nullptr) {
      rightCircuit->insert(left);
      newCircuitSize = rightCircuit->size();
    }

    if (leftCircuit != nullptr && rightCircuit == nullptr) {
      leftCircuit->insert(right);
      newCircuitSize = leftCircuit->size();
    }

    if (leftCircuit != nullptr && rightCircuit != nullptr) {
      // merging circuit
      Circuit *newCircuit = Circuit::merge(leftCircuit, rightCircuit);
      circuits.push_back(newCircuit);
      newCircuitSize = newCircuit->size();
    }

    if (newCircuitSize == numOfJunctionBox) {
      return left.point.x * right.point.x;
    }
  }

  return 0;
}

long part1(auto &minHeap, size_t expectedConnectionCount) {
  std::vector<Circuit *> circuits;
  size_t connectedCount = 0;
  while (connectedCount < expectedConnectionCount) {
    const auto [distance, pair] = minHeap.top();
    const auto &[left, right] = pair;
    minHeap.pop();

    Circuit *leftCircuit = nullptr, *rightCircuit = nullptr;

    for (auto c : circuits) {
      if (c->exists(left)) {
        leftCircuit = c;
      }
      if (c->exists(right)) {
        rightCircuit = c;
      }
    }

    if (leftCircuit == nullptr && rightCircuit == nullptr) {
      Circuit *c = new Circuit();
      c->insert(left);
      c->insert(right);
      circuits.push_back(c);
      connectedCount++;
      continue;
    }

    if (leftCircuit == nullptr && rightCircuit != nullptr) {
      rightCircuit->insert(left);
      connectedCount++;
      continue;
    }

    if (leftCircuit != nullptr && rightCircuit == nullptr) {
      leftCircuit->insert(right);
      connectedCount++;
      continue;
    }

    // merging circuit
    circuits.push_back(Circuit::merge(leftCircuit, rightCircuit));
    connectedCount++;
  }
  std::sort(circuits.begin(), circuits.end(),
            [](const auto &l, const auto &r) { return l->size() > r->size(); });

  return circuits[0]->size() * circuits[1]->size() * circuits[2]->size();
}

inline long solve(size_t expectedConnectionCount, bool testing = true,
                  [[gnu::unused]] bool part2 = false) {
  std::string filePath = "./input/day08/input.test.txt";
  if (!testing) {
    filePath = "./input/day08/input.txt";
  }

  const auto &lines = aoc::loadFile(filePath);

  auto junctionBoxes =
      std::views::zip(std::views::iota(0), lines) |
      std::views::transform([](const auto &pair) {
        const auto &[idx, line] = pair;
        auto values =
            aoc::split(line, ',') | std::views::transform([](const auto &s) {
              return aoc::to_long(s);
            });
        return JunctionBox(idx, values[0], values[1], values[2]);
      }) |
      std::ranges::to<std::vector<JunctionBox>>();

  DistanceMinHeap minHeap;
  for (size_t i = 0; i < junctionBoxes.size(); i++) {
    auto left = junctionBoxes[i];
    for (size_t j = 0; j < i; j++) {
      auto right = junctionBoxes[j];
      double distance = aoc::Point3d::distance(left.point, right.point);
      minHeap.emplace(distance, std::make_pair(left, right));
    }
  }

  if (!part2) {
    return part1(minHeap, expectedConnectionCount);
  } else {
    return part2Solver(junctionBoxes.size(), minHeap);
  }
}
} // namespace day08
