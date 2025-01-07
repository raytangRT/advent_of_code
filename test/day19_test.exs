defmodule Day19.Part1.Tests do
  use ExUnit.Case
  import Day19.Part1

  @towels "r, wr, b, g, bwu, rb, gb, br" |> String.split(", ")

  for {pattern, expected_result} <- [
        {"brwrr", :ok},
        {"bggr", :ok},
        {"gbbr", :ok},
        {"rrbgbr", :ok},
        {"ubwu", :failed},
        {"bwurrg", :ok},
        {"brgr", :ok},
        {"bbrgwb", :failed}
      ] do
    @pattern pattern
    @expected_result expected_result
    @tag :skip
    test "verify pattern for #{pattern}" do
      towels = Enum.group_by(@towels, &String.length/1)
      # uniq = calculate_unique_patterns(towels) |> Map.values() |> Enum.reverse()
      # result = test_pattern({uniq, @pattern})
      # assert result == @expected_result
    end
  end
end

defmodule Day19.Part2.Test do
  use ExUnit.Case
  import Day19.Part2

  @towels "r, wr, b, g, bwu, rb, gb, br"
          |> String.split(", ")
          |> Enum.map(&{&1, [{&1}]})
          |> Map.new()

  for {pattern, expected_count} <- [
        {"brwrr", 2},
        {"bggr", 1},
        {"gbbr", 4},
        {"rrbgbr", 6},
        {"bwurrg", 1},
        {"brgr", 2},
        {"ubwu", 0},
        {"bbrgwb", 0}
      ] do
    @pattern pattern
    @expected_count expected_count
    test "verify pattern for #{pattern}" do
      cache = check_resursivly(@pattern, 3, @towels)
      count = build(@pattern, cache) |> length
      assert count == @expected_count
    end
  end
end
