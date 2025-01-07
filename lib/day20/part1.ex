defmodule Day20.Part1 do
  alias Grid.Cell
  # 5530 too high
  def run(mode \\ :sample) do
    maze = read(mode)
    original_path_length = length(Maze.dijkstra(maze)) - 1

    clippable_walls = get_clippable_walls(maze)

    bimap =
      clippable_walls
      |> Enum.with_index()
      |> Enum.reduce([], fn {%Cell{point: point}, idx}, result ->
        ProgressBar.render(idx, length(clippable_walls), suffix: :count)
        maze = Maze.remove_wall(maze, point)
        path = Maze.dijkstra(maze)
        new_path_length = length(path) - 1

        if original_path_length - new_path_length > 0 do
          [{original_path_length - new_path_length, point} | result]
        else
          result
        end
      end)
      |> BiMultiMap.new()

    IO.puts("")

    BiMultiMap.keys(bimap)
    |> Enum.filter(&(&1 >= 100))
    |> Enum.map(fn key -> BiMultiMap.get(bimap, key) |> length() end)
    |> Enum.sum()
  end

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day20")
    |> Grid.new(fn _x, _y, v ->
      case v do
        "." -> :slot
        "#" -> :wall
        "S" -> :start
        "E" -> :end
      end
    end)
    |> Maze.new(&Cell.value(&1))
  end

  def get_clippable_walls(%Maze{grid: grid}) do
    Grid.get_cells(grid, fn %Cell{} = cell ->
      Grid.get_neighbors(grid, cell, [:up, :down, :left, :right])
      |> Enum.reject(fn {_, cell} -> is_nil(cell) end)
      |> Enum.filter(fn {_, %Cell{value: value}} ->
        value in [:slot, :start, :end]
      end)
      |> Enum.count() >= 2
    end)
  end
end
