defmodule Day22.Part1.Tests do
  use ExUnit.Case
  import Day22.Part1

  for {input, output} <- [
        {1, 8_685_429},
        {10, 4_700_978},
        {100, 15_273_692},
        {2024, 8_667_524}
      ] do
    @input input
    @expected_output output
    test "calculate score for #{input}" do
      assert @expected_output == score
    end
  end
end
