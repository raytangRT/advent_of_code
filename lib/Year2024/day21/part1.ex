defmodule Year2024.Day21.Part1 do
  require Logger
  import Year2024.Day21.Helpers

  def run(mode \\ :sample) do
    read(mode)
    |> Enum.map(fn code ->
      path = walk(code)

      calculate(code, path)
    end)
    |> Enum.sum()
  end

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day21")
    |> Enum.reduce([], fn line, result ->
      [line | result]
    end)
    |> Enum.reverse()
  end

  def print(lists) do
    Enum.map(lists, fn list ->
      Enum.reduce(list, "", fn c, r ->
        r <>
          case c do
            :down -> "v"
            :up -> "^"
            :left -> "<"
            :right -> ">"
            :press -> "A"
          end
      end)
      |> IO.puts()
    end)
  end

  def cross_join(left, right) do
    ListUtils.cross_join(left, right)
    |> Enum.map(fn {left, right} -> left ++ right end)
  end

  def key_in(code) do
    String.graphemes(code)
    |> Enum.reduce({[], "A"}, fn to_press, {result, current} ->
      paths = get_numpad_paths(current, to_press)

      if result == [] do
        {paths, to_press}
      else
        {cross_join(result, paths), to_press}
      end
    end)
    |> elem(0)
  end

  def click_arrow_pad(path) do
    execute_on_arrowpad(path)
    |> min_length_list()
  end

  def walk(code) do
    key_in(code)
    |> Enum.map(&click_arrow_pad/1)
    |> ListUtils.flatten()
    |> Enum.map(&click_arrow_pad/1)
    |> ListUtils.flatten()
    |> min_length_list()
    |> hd
  end

  def calculate(code, path) do
    value = code |> String.replace_suffix("A", "") |> Integer.parse() |> elem(0)
    IO.puts("#{code} = #{value} * #{length(path)} = #{value * length(path)}")
    value * length(path)
  end

  def min_length(list) do
    Enum.reduce(list, :inf, fn l, min_length ->
      if length(l) < min_length do
        length(l)
      else
        min_length
      end
    end)
  end

  def min_length_list(list) do
    min_length = min_length(list)

    Enum.reject(list, &(length(&1) > min_length))
  end
end
