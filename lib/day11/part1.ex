defmodule Day11.Part1 do
  require Logger

  def run(mode \\ :sample) do
    Enum.reduce(1..25, {%{}, read(mode)}, fn idx, {result, stones} ->
      splitted_stones = split_stones(stones)
      result = Map.put(result, idx, splitted_stones)
      {result, splitted_stones}
    end)
    |> then(fn {_result, stone} ->
      stone
    end)
  end

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day11")
    |> Enum.at(0)
    |> String.split(" ")
    |> AOC.list_to_integer()
  end

  def has_even_digits?(number) do
    number
    |> abs()
    |> Integer.to_string()
    |> String.length()
    |> rem(2) == 0
  end

  def split_in_half(string) do
    len = String.length(string)
    mid = div(len, 2)

    first_half = String.slice(string, 0, mid)
    second_half = String.slice(string, mid, len - mid)

    [String.to_integer(first_half), String.to_integer(second_half)]
  end

  def split_stones(stones) do
    Enum.map(stones, &split_stone/1)
    |> List.flatten()
  end

  def split_stone(stone) do
    cond do
      stone == 0 ->
        [1]

      has_even_digits?(stone) ->
        split_in_half(Integer.to_string(stone))

      true ->
        [stone * 2024]
    end
  end
end
