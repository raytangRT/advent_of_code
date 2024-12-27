defmodule Day16.Part1 do
  import HeapGuards
  require Logger
  alias AOC.Text
  alias Grid.Cell

  # 89344 too high
  # 73408 too high
  def run(mode \\ :sample) do
    {grid, distances} =
      read(mode)
      |> cleanup_dead_path()
      |> walk()

    {grid, path} = calculate_optimal(grid)
    calculate_score(path)
    # |> calculate_optimal()

    # calculate_score(path)
  end

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day16")
    |> Grid.new(fn _x, _y, value ->
      case value do
        "#" -> {:not_scored, :wall}
        "S" -> {1, :start}
        "E" -> {:not_scored, :end}
        "." -> {nil, :empty_space}
      end
    end)
  end

  def cleanup_dead_path(%Grid{cells: cells} = grid) do
    dead_paths =
      Enum.filter(cells, fn {_, %Cell{value: {_, type}}} ->
        type == :empty_space
      end)
      |> Enum.filter(fn {_, cell} ->
        neighbors(grid, cell, &(&1 == :wall))
        |> then(&(length(&1) == 3))
      end)

    if length(dead_paths) > 0 do
      new_grid =
        dead_paths
        |> Enum.reduce(grid, fn {point, _}, grid ->
          Grid.replace(grid, point, {:not_scored, :wall})
        end)

      cleanup_dead_path(new_grid)
    else
      grid
    end
  end

  defp format_cell(%Cell{value: {score, value}}) do
    case value do
      :wall -> "#"
      :start -> "S"
      :end -> "E"
      :up -> "^"
      :down -> "v"
      :left -> "<"
      :right -> ">"
      :empty_space -> "."
      :special_wall -> "*" |> Text.red()
      :optimal -> "O" |> Text.yellow()
    end
  end

  def print_to_console(grid) do
    Grid.print(grid, &format_cell/1)
  end

  def print_to_file(grid) do
    Grid.print_to_file(grid, "./output/day16/output.txt", fn %Cell{value: {score, value}} ->
      case value do
        :wall -> "#"
        :start -> "S"
        :end -> "E"
        :empty_space -> "."
        :top -> "^#{Integer.to_string(score)}"
        :bottom -> "v#{Integer.to_string(score)}"
        :left -> "<#{Integer.to_string(score)}"
        :right -> ">#{Integer.to_string(score)}"
        _ -> Integer.to_string(score)
      end <> "|"
    end)
  end

  def walk(%Grid{cells: cells} = grid) when is_struct(grid, Grid) do
    starting_cell =
      Grid.get_cells(grid, fn %Cell{value: {_score, value}} -> value == :start end)
      |> hd

    heap =
      Heap.new(fn %Cell{value: {l_score, _}}, %Cell{value: {r_score, _}} ->
        l_score < r_score
      end)
      |> Heap.push(starting_cell)

    distances =
      Enum.reduce(cells, %{}, fn {point, _}, distances ->
        Map.put(distances, point, :infinity)
      end)
      |> Map.put(Cell.point(starting_cell), 0)

    walk_dijkstra(grid, heap, distances)
  end

  def walk_dijkstra(grid, heap, distances) when is_empty_heap(heap) do
    {grid, distances}
  end

  def walk_dijkstra(%Grid{} = grid, heap, distances) when not is_empty_heap(heap) do
    {%Cell{value: {min_cell_score, min_cell_facing}} = min_cell, heap} = Heap.split(heap)

    min_cell_facing = if min_cell_facing == :start, do: :right, else: min_cell_facing

    neighbors(grid, min_cell, &(&1 not in [:wall]))
    |> Enum.reduce({grid, heap, distances}, fn {position_relative_to_min_cell,
                                                %Cell{point: point, value: {_, type}}},
                                               {grid, heap, distances} ->
      new_score =
        min_cell_score + if min_cell_facing == position_relative_to_min_cell, do: 1, else: 1001

      if type != :end and Map.get(distances, point) > new_score do
        cell_value = {new_score, position_relative_to_min_cell}
        grid = Grid.replace(grid, point, cell_value)
        heap = Heap.push(heap, Cell.new(point, cell_value))
        distances = Map.replace!(distances, point, new_score)
        {grid, heap, distances}
      else
        {grid, heap, distances}
      end
    end)
    |> then(fn {grid, heap, distances} -> walk_dijkstra(grid, heap, distances) end)
  end

  def neighbors(grid, current, value_filter_fn) do
    Grid.get_neighbors(grid, current, [:up, :down, :left, :right])
    |> Enum.filter(fn {_, %Cell{value: {_, type}}} ->
      value_filter_fn.(type)
    end)
  end

  def calculate_optimal(grid) do
    %Cell{point: ending_point} =
      ending_cell =
      Grid.get_cells(grid, fn %Cell{value: {_, type}} -> type == :end end)
      |> hd

    calculate_optimal(grid, ending_cell, [ending_point])
  end

  def calculate_optimal(grid, cell, path) do
    {grid, next_cell, path} =
      neighbors(grid, cell, fn value ->
        value not in [:wall, :end, :optimal]
      end)
      |> Enum.min_by(fn {_,
                         %Cell{
                           value: {neighbor_score, _}
                         }} ->
        neighbor_score
      end)
      |> then(fn {_, %Cell{point: point, value: {score, t}} = cell} ->
        path = [point | path]

        if t != :start do
          {Grid.replace(grid, point, {score, :optimal}), cell, path}
        else
          {grid, cell, path}
        end
      end)

    if Cell.value(next_cell) |> elem(1) == :start do
      {grid, path}
    else
      calculate_optimal(grid, next_cell, path)
    end
  end

  def calculate_score(path) do
    starting_dir = :right

    path
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.map(fn [
                     %Point{x: from_x, y: from_y},
                     %Point{x: to_x, y: to_y}
                   ] ->
      {to_x - from_x, to_y - from_y}
    end)
    |> Enum.reduce({%{}, starting_dir}, fn {x, y}, {score, next_direction} ->
      toward_direction =
        cond do
          x == 0 and y == -1 ->
            :up

          x == 0 and y == 1 ->
            :down

          x == -1 and y == 0 ->
            :left

          x == 1 and y == 0 ->
            :right
        end

      score =
        if toward_direction != next_direction do
          Map.update(score, :turn, 1, &(&1 + 1))
        else
          score
        end
        |> Map.update(:step, 1, &(&1 + 1))

      {score, toward_direction}
    end)
    |> elem(0)
  end
end
