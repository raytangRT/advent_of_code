#pragma once
#include "aoc/matrix.hpp"
#include "aoc/rangeHelpers.hpp"
#include "gift.hpp"
#include <ostream>
#include <ranges>
#include <vector>

namespace day12 {

class GiftBox {
private:
  std::vector<size_t> m_requiredGifts;

public:
  GiftBox(const std::vector<size_t> &requiredGifts)
      : m_requiredGifts(requiredGifts) {}

  std::vector<std::pair<size_t, GiftBox>> pickGift() const {
    std::vector<std::pair<size_t, GiftBox>> combos;
    for (size_t i = 0; i < m_requiredGifts.size(); i++) {
      if (m_requiredGifts[i] > 0) {
        std::vector<size_t> picked(m_requiredGifts);
        picked[i]--;
        combos.emplace_back(i, GiftBox(picked));
      }
    }
    return combos;
  }

  bool isEmpty() const {
    for (const auto &gifts : m_requiredGifts) {
      if (gifts > 0) {
        return false;
      }
    }
    return true;
  }
  size_t total_space_required(const std::vector<Gift> &gifts) {
    size_t total = 0;
    for (const size_t i : std::views::iota(0u, gifts.size())) {
      total += m_requiredGifts[i] * gifts[i].size();
    }
    return total;
  }

  size_t total_area(const std::vector<Gift> &gifts) {
    size_t total = 0;
    for (size_t i = 0; i < gifts.size(); i++) {
      total += m_requiredGifts[i] * gifts[i].area();
    }
    return total;
  }

  friend std::ostream &operator<<(std::ostream &os, const GiftBox &gb) {
    return os << aoc::to_string(gb.m_requiredGifts);
  }
};
} // namespace day12
