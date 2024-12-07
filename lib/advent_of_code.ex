defmodule AOC do
  require Logger

  def read_file(file_path) do
    Path.expand(Path.join(["./input", file_path]))
    |> File.stream!([:line])
    |> Stream.map(&String.trim/1)
  end

  def not_nil_do(input, f) do
    input
    |> case do
      nil -> nil
      ^input -> f.(input)
    end
  end

  def parse(str, delim \\ ",") when is_bitstring(str) do
    str |> String.split(delim) |> Enum.map(&String.to_integer/1)
  end

  def list_to_integer(list) when is_list(list) do
    Enum.map(list, &String.to_integer/1)
  end

  def in_range(target, lower, upper)
      when is_number(target) and is_number(lower) and is_number(upper) do
    lower <= target and target <= upper
  end

  def list(list) do
    inspect(list, charlists: :as_lists)
  end

  def print_list(list, prefix \\ "") do
    Logger.info("#{prefix} = #{AOC.list(list)}")
  end

  def remove_at(list, idx) when is_list(list) and is_number(idx) do
    {left, [_ | right]} = Enum.split(list, idx)
    left ++ right
  end

  def increasing?(list) do
    Enum.all?(Enum.zip(list, tl(list)), fn {a, b} -> a < b end)
  end

  def decreasing?(list) do
    Enum.all?(Enum.zip(list, tl(list)), fn {a, b} -> a > b end)
  end
end
