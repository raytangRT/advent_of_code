defmodule Day2 do
  require Logger
  @input_path "./input/day2.txt"

  def run() do
    AOC.read_file(@input_path)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(fn l -> Enum.map(l, &String.to_integer/1) end)
    |> Enum.map(&safe_report?/1)
    |> Enum.count(&(!is_nil(&1)))
  end

  defp safe_report?(report) do
    report
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [l, r] -> l - r end)
    |> check_monotonicity()
    |> AOC.not_nil_do(&check_differences_within_range/1)
  end

  defp check_monotonicity(differences) do
    cond do
      # All positive, decreasing
      Enum.all?(differences, &(&1 > 0)) -> differences
      # All negative, increasing
      Enum.all?(differences, &(&1 < 0)) -> differences
      # Not monotonic
      true -> nil
    end
  end

  defp check_differences_within_range(diff) do
    cond do
      Enum.any?(diff, &(abs(&1) > 3)) -> nil
      Enum.any?(diff, &(abs(&1) < 1)) -> nil
      true -> diff
    end
  end

  def run2 do
    AOC.read_file(@input_path)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&AOC.list_to_integer/1)
    |> Enum.map(&prepare_report/1)
    |> Enum.map(fn {report_data, chunks} ->
      if not is_nil(safe_report?(chunks)) do
        report_data
      else
        nil
      end
    end)
    |> Enum.count(&(not is_nil(&1)))
  end

  defp prepare_report(report_data) do
    chunks =
      report_data
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [l, r] -> l - r end)

    {report_data, chunks}
  end
end
