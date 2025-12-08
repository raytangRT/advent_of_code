#pragma once
#include "fmt/format.h"
#include <functional>
#include <memory>
#include <ostream>
#include <stdexcept>
#include <unordered_map>

namespace aoc {

struct Point {
  int x;
  int y;

  // fmt::format support
  friend auto format_as(const Point &p) {
    return fmt::format("({},{})", p.x, p.y);
  }

  Point(int x, int y) : x(x), y(y) {}
  Point(size_t x, size_t y) : x(x), y(y) {}

  constexpr bool operator==(const Point &other) const = default;
  constexpr auto operator<=>(const Point &other) const = default;

  friend std::ostream &operator<<(std::ostream &os, const Point &ptr) {
    return os << fmt::format("pt{{{},{}}}", ptr.x, ptr.y);
  }
};

template <typename T> struct GraphNode {
  std::vector<std::shared_ptr<GraphNode<T>>> children;

  Point p;
  T value;

  GraphNode(const Point &p, const T &value) : p(p), value(value) {}

  friend std::ostream &operator<<(std::ostream &os, const GraphNode<T> &node) {
    return os << fmt::format("Node{{Point: {}, Value: {}}}", node.p,
                             node.value);
  }
};

template <typename T> class Graph {
private:
  std::shared_ptr<GraphNode<T>> m_root;
  std::unordered_map<Point, std::shared_ptr<GraphNode<T>>> m_nodes;

public:
  class Linker {
  private:
    Point m_sourcePoint;
    Graph<T> *m_graph;

  public:
    Linker(const Point &p, Graph *graph) : m_sourcePoint(p), m_graph(graph) {}

    void ChildOf(const Point &p) {
      std::shared_ptr<GraphNode<T>> parent = m_graph->getNode(p);
      std::shared_ptr<GraphNode<T>> ptr = m_graph->getNode(m_sourcePoint);

      parent->children.push_back(ptr);
    }
  };

  void addRoot(const Point &p, const T &value) {
    m_root = std::make_shared<GraphNode<T>>(p, value);
    m_nodes[p] = m_root;
  }

  Linker addNode(const Point &p, const T &value) {
    if (m_nodes.find(p) == m_nodes.end()) {
      auto ptr = std::make_shared<GraphNode<T>>(p, value);
      m_nodes[p] = std::move(ptr);
    }

    return Linker(p, this);
  };

  std::shared_ptr<GraphNode<T>> getNode(const Point &point) {
    auto ptrItr = m_nodes.find(point);
    if (ptrItr == m_nodes.end()) {
      throw std::invalid_argument(fmt::format("Invalid point {}", point));
    }

    return ptrItr->second;
  }

  std::shared_ptr<GraphNode<T>> root() { return m_root; }
};
} // namespace aoc

// Hash specialization for Point
template <> struct std::hash<aoc::Point> {
  std::size_t operator()(const aoc::Point &p) const {
    return std::hash<int>{}(p.x) ^ (std::hash<int>{}(p.y) << 1);
  }
};
