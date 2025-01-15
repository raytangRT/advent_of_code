defmodule Year2024.Day10.Part2 do
  require Logger

  def run(mode \\ :sample) do
    read(mode)
    |> walk()
    |> calculate_scores()
  end

  def read(mode \\ :sample) do
    file_path = if mode == :actual, do: "day10.txt", else: "day10.sample.txt"

    Grid.parse(file_path, fn _, _, char ->
      String.to_integer(char)
    end)
  end

  def walk(grid) do
    Grid.get_cells(grid, &(&1.value == 0))
    |> Enum.map(fn cell ->
      {cell, walk(grid, cell, []) |> List.flatten()}
    end)
  end

  def walk(_, current, list) when current.value == 9 do
    {:hiking_tail, [current | list]}
  end

  def walk(grid, current, list) do
    left = Point.move(current.point, {-1, 0})
    right = Point.move(current.point, {1, 0})
    up = Point.move(current.point, {0, -1})
    down = Point.move(current.point, {0, 1})

    Enum.map([left, right, up, down], fn new_point ->
      if Grid.in_bound?(grid, new_point) and
           Grid.get_cell(grid, new_point).value == current.value + 1 do
        walk(grid, Grid.get_cell(grid, new_point), [current | list])
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  def print(grid) do
    Grid.print(grid, &Integer.to_string(&1.value))
  end

  def calculate_scores(starting_cells) do
    Enum.map(starting_cells, fn {cell, trails} ->
      {cell, calculate_score(trails)}
    end)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  def calculate_score(trails) do
    trails
    |> Enum.uniq()
    |> Enum.count()
  end
end
