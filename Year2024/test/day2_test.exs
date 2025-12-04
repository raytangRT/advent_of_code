defmodule Day2Test do
  use ExUnit.Case

  for report_data_raw <- [
        "48 46 47 49 51 54 56",
        "1 1 2 3 4 5",
        "1 2 3 4 5 5",
        "5 1 2 3 4 5",
        "1 4 3 2 1",
        "1 6 7 8 9",
        "1 2 3 4 3",
        "9 8 7 6 7",
        "7 10 8 10 11",
        "29 28 27 25 26 25 22 20"
      ] do
    @report_data_raw report_data_raw
    test "Safe Reports data = #{AOC.list(report_data_raw)}" do
      report_data = @report_data_raw |> String.split(" ") |> Enum.map(&String.to_integer/1)
      result = Day2.safe_report?(report_data, 1)
      assert not is_nil(result)
    end
  end
end
