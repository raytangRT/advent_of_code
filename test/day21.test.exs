defmodule Day21.Part1.Tests do
  use ExUnit.Case
  import Day21.Part1

  for {input, output} <- [
        {"029A", 68 * 29},
        {"980A", 60 * 980},
        {"179A", 68 * 179},
        {"456A", 64 * 456},
        {"379A", 64 * 379}
      ] do
    @input input
    @expected_output output
    test "calculate score for #{input}" do
      path = walk(@input)
      score = calculate(@input, path)
      assert @expected_output == score
    end
  end
end
