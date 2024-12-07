defmodule Day5 do
  require Logger

  def run do
    rules =
      AOC.read_file("day5.txt")
      |> Enum.map(fn line ->
        line
        |> String.split("|")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> Enum.reduce(%{}, fn {left, right}, m ->
        Map.update(m, left, [right], fn value ->
          [right | value]
        end)
      end)

    AOC.read_file("day5.queue.txt")
    |> Enum.map(&AOC.parse/1)
    |> Enum.filter(fn line ->
      line
      |> Enum.with_index()
      |> Enum.into(%{})
      |> cal_index(rules)
      |> then(fn {list, rules} ->
        filter_in?({Map.to_list(list), rules})
      end)
    end)
    |> Enum.map(&mid/1)
    |> Enum.sum()
  end

  def cal_index(list, rules) do
    rules =
      Map.to_list(rules)
      |> Enum.reduce(%{}, fn {key, values}, m ->
        min =
          values
          |> Enum.map(&Map.get(list, &1))
          |> Enum.min()

        Map.put(m, key, min || -1)
      end)

    {list, rules}
  end

  def filter_in?({[{value, idx} | tail], rules}) do
    min_idx = Map.get(rules, value)

    cond do
      min_idx >= 0 and idx >= min_idx ->
        false

      length(tail) == 0 ->
        true

      true ->
        filter_in?({tail, rules})
    end
  end

  def mid(list) do
    Enum.at(list, div(length(list), 2))
  end
end
