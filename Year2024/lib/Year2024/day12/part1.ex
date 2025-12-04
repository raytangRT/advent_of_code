defmodule Year2024.Day12.Part1 do
  require Logger
  alias Day12.Plot
  alias Day12.Region
  alias Grid.Cell

  def run(mode \\ :sample) do
    {grid, regions} =
      read(mode)
      |> recognize()

    regions
    |> Enum.map(fn region ->
      Region.area(region) * Region.perimeter(grid, region)
    end)
    |> Enum.sum()
  end

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day12")
    |> Grid.new(fn x, y, value ->
      {:not_visited, Plot.new(x, y, value)}
    end)
  end

  def recognize(grid) do
    Enum.reduce(Grid.keys(grid), {grid, []}, fn point, {grid, regions} ->
      cell = Grid.get_cell(grid, point)

      case Cell.value(cell) do
        {:visited, _} ->
          {grid, regions}

        {:not_visited, plot} ->
          grid = Grid.replace(grid, point, {:visited, plot})
          {grid, cells_in_region} = walk(grid, plot, [plot])
          {grid, [Region.new(plot.value, cells_in_region) | regions]}
      end
    end)
  end

  def walk(grid, target, cells_in_region) when is_list(cells_in_region) do
    walk({grid, cells_in_region}, target, {1, 0})
    |> walk(target, {0, 1})
    |> walk(target, {-1, 0})
    |> walk(target, {0, -1})
  end

  def walk({grid, cells_in_region}, target, direction) when is_tuple(direction) do
    new_plot = Grid.get_cell_value(grid, Point.move(target.point, direction))

    case new_plot do
      nil ->
        {grid, cells_in_region}

      {:visited, _} ->
        {grid, cells_in_region}

      {_, plot} when plot.value != target.value ->
        {grid, cells_in_region}

      {_, plot} ->
        grid = Grid.replace(grid, plot.point, {:visited, plot})
        cells_in_region = [plot | cells_in_region]
        walk(grid, plot, cells_in_region)
    end
  end
end
