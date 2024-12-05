defmodule Day2 do
  require Logger
  @input_path "day2.txt"
  #
  # part1: 287
  def run(tolerance \\ 0) do
    AOC.read_file(@input_path)
    |> Enum.map(&String.split(&1, " "))
    |> Enum.map(&AOC.list_to_integer/1)
    |> Enum.map(&safe_report?(&1, tolerance))
    |> Enum.count(&(!is_nil(&1)))
  end

  def safe_report?(report, tolerance) do
    prepare_report_data(report, tolerance)
    |> check_monotonicity()
    |> AOC.not_nil_do(&check_differences_within_range/1)
  end

  def prepare_report_data(data, tolerance) do
    {data,
     data
     |> Enum.chunk_every(2, 1, :discard)
     |> Enum.map(fn [l, r] -> {{l, r}, l - r} end), tolerance}
  end

  def check_monotonicity_v2(report_data) do
    cond do
      AOC.increasing?(report_data) -> {:ok, :increasing}
      AOC.decreasing?(report_data) -> {:ok, :decreasing}
      true -> {:error, :out_of_sequence}
    end
  end

  def check_differences_within_range_v2(diff) do
    Enum.all?(diff, fn {_, d} -> AOC.in_range(abs(d), 1, 3) end)
  end

  defp check_monotonicity({report_data, diff, tolerance}) do
    differences = Enum.map(diff, fn {_, d} -> d end)

    decreasing_count = Enum.count(differences, &(&1 > 0))
    increasing_count = Enum.count(differences, &(&1 < 0))
    count = Enum.count(differences)

    cond do
      decreasing_count == count or increasing_count == count ->
        {report_data, diff, tolerance}

      # Not monotonic and no tolerance
      tolerance == 0 ->
        nil

      # Not monotonic but with tolerance
      true ->
        {_, idx} =
          Enum.with_index(diff)
          |> Enum.find(fn {{_, dif}, _} ->
            if increasing_count > decreasing_count do
              dif >= 0
            else
              dif <= 0
            end
          end)

        attempt_1 = safe_report?(AOC.remove_at(report_data, idx), tolerance - 1)

        attempt_2 = safe_report?(AOC.remove_at(report_data, idx + 1), tolerance - 1)

        if not is_nil(attempt_1) do
          if not is_nil(attempt_2) do
            {list1, _, _} = attempt_1
            {list2, _, _} = attempt_2

            if Enum.sort(list1) != Enum.sort(list2) do
              Logger.error(
                "orig = #{AOC.list(report_data)}, Both attempt works, 1 = #{AOC.list(attempt_1)}, 2 = #{AOC.list(attempt_2)}"
              )
            end
          end

          attempt_1
        else
          attempt_2
        end
    end
  end

  defp check_differences_within_range({report_data, diff, tolerance}) do
    if not (AOC.increasing?(report_data) or AOC.decreasing?(report_data)) do
      Logger.error("Error found, #{AOC.list(report_data)}")
    end

    in_range_count = Enum.count(diff, fn {_, d} -> AOC.in_range(abs(d), 1, 3) end)
    count = Enum.count(diff)

    cond do
      in_range_count == count ->
        # Logger.info("OK report = #{AOC.list(report_data)}")
        {report_data, diff, tolerance}

      tolerance == 0 ->
        nil

      true ->
        items_to_remove =
          diff
          |> Enum.with_index()
          |> Enum.filter(fn {{_, dif}, _} ->
            !AOC.in_range(abs(dif), 1, 3)
          end)

        if Enum.count(items_to_remove) > tolerance do
          nil
        else
          # Logger.info("data = #{AOC.list(report_data)}, diff = #{AOC.list(diff)}")

          # Logger.info(
          #   "report_data = #{AOC.list(report_data)}, items_to_remove = #{AOC.list(items_to_remove)}"
          # )
          #
          [head | _] = items_to_remove
          {_, idx} = head

          attempt_1 = safe_report?(AOC.remove_at(report_data, idx), tolerance - 1)

          if not is_nil(attempt_1) do
            attempt_1
          else
            safe_report?(AOC.remove_at(report_data, idx + 1), tolerance - 1)
          end
        end
    end
  end
end
