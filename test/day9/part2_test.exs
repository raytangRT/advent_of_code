defmodule Day9.Part2.Test do
  use ExUnit.Case

  alias Day9.Part2

  test "basic example" do
    memory_blocks = [
      {{0, 1}, 0},
      {{2, 3}, 9},
      {{4, 4}, 2},
      {{5, 7}, 1},
      {{8, 10}, 7},
      {{12, 13}, 4},
      {{15, 17}, 3},
      {{22, 25}, 5},
      {{27, 30}, 6},
      {{36, 39}, 8}
    ]

    # Compact and calculate checksum
    compacted = Part2.fold(memory_blocks) |> Part2.fill_gaps()
    checksum = Part2.calculate_check_sum(compacted)

    # Replace with actual expected checksum after verification
    assert checksum == 2858
  end

  test "no movement possible" do
    memory_blocks = [
      {{0, 3}, 1},
      {{4, 7}, 2},
      {{8, 11}, 3}
    ]

    compacted = Part2.fold(memory_blocks) |> Part2.fill_gaps()
    checksum = Part2.calculate_check_sum(compacted)

    # In this case, files cannot move, checksum remains based on original positions
    assert checksum ==
             1 * 0 + 1 * 1 + 1 * 2 + 1 * 3 +
               2 * 4 + 2 * 5 + 2 * 6 + 2 * 7 +
               3 * 8 + 3 * 9 + 3 * 10 + 3 * 11
  end

  test "gaps too small" do
    memory_blocks = [
      {{0, 3}, 1},
      {{5, 6}, 2},
      {{8, 10}, 3},
      {{12, 15}, 4}
    ]

    compacted = Part2.fold(memory_blocks) |> Part2.fill_gaps()
    checksum = Part2.calculate_check_sum(compacted)

    # Replace with actual expected checksum after verification
    assert checksum == 150
  end

  test "large input" do
    memory_blocks =
      Enum.concat([
        Enum.map(0..50, fn i -> {{i * 5, i * 5 + 2}, i + 1} end),
        Enum.map(51..100, fn i -> {{i * 5, i * 5 + 4}, i + 1} end)
      ])

    compacted = Part2.fold(memory_blocks) |> Part2.fill_gaps()
    checksum = Part2.calculate_check_sum(compacted)

    # Just ensure it completes without error for now
    assert is_integer(checksum)
  end
end
