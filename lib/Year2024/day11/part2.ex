defmodule Year2024.Day11.Part2 do
  require Logger
  @count 75

  def run() do
    stone_counter = Counter.new(read())

    split_stones(stone_counter, 1)
    |> Counter.total()
  end

  def split_stones(stone_counter, iterator_count) when iterator_count > @count do
    stone_counter
  end

  def split_stones(stone_counter, iteration_count) do
    ProgressBar.render(iteration_count, @count, suffix: :count)

    new_stone_counter =
      Enum.reduce(stone_counter, Counter.new(), fn {stone, count}, new_stone_counter ->
        new_stones = split_stone(stone)

        Enum.reduce(new_stones, new_stone_counter, fn new_stone, new_stone_counter ->
          Counter.add(new_stone_counter, new_stone, count)
        end)
      end)

    split_stones(new_stone_counter, iteration_count + 1)
  end

  def read() do
    AOC.read_file(:actual, "day11")
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
