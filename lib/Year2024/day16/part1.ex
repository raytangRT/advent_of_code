defmodule Year2024.Day16.Part1 do
  import HeapGuards
  require Logger
  alias AOC.Text
  alias Grid.Cell

  def run(mode \\ :sample) do
    read(mode)
    |> cleanup_dead_path()
    |> walk()
  end

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day16")
    |> Grid.new(fn _x, _y, value ->
      case value do
        "#" -> {:not_scored, :wall}
        "S" -> {0, :start}
        "E" -> {:not_scored, :end}
        "." -> {nil, :empty_space}
      end
    end)
  end

  def cleanup_dead_path(%Grid{cells: cells} = grid) do
    dead_paths =
      cells
      |> Enum.filter(fn {_, %Cell{point: point, value: {_, type}}} ->
        type == :empty_space and
          [
            Grid.get_cell_value(grid, Point.move_up(point)),
            Grid.get_cell_value(grid, Point.move_left(point)),
            Grid.get_cell_value(grid, Point.move_right(point)),
            Grid.get_cell_value(grid, Point.move_down(point))
          ]
          |> Enum.count(&(elem(&1, 1) == :wall)) == 3
      end)
      |> Enum.map(fn {_, %Cell{point: point}} ->
        point
      end)

    cleanup_dead_path(grid, dead_paths)
  end

  def cleanup_dead_path(grid, cells_to_remove) when length(cells_to_remove) == 0 do
    grid
  end

  def cleanup_dead_path(grid, cells_to_remove) do
    Enum.reduce(cells_to_remove, grid, fn point, grid ->
      Grid.replace(grid, point, {:not_scored, :wall})
    end)
    |> cleanup_dead_path()
  end

  def print_to_console(grid) do
    Grid.print(grid, fn %Cell{value: {_score, value}} ->
      case value do
        :wall -> "#"
        :start -> "S"
        :end -> "E"
        :up -> "^"
        :down -> "v"
        :left -> "<"
        :right -> ">"
        :empty_space -> "."
        :optimal -> "O" |> Text.yellow()
      end
    end)
  end

  def find_cell(grid, cell_type) do
    Grid.get_cells(grid, fn %Cell{value: {_score, value}} -> value == cell_type end)
    |> hd
  end

  def walk(%Grid{} = grid) when is_struct(grid, Grid) do
    starting_cell = find_cell(grid, :start)

    heap =
      Heap.new(fn %Cell{value: {l_score, _}}, %Cell{value: {r_score, _}} ->
        l_score < r_score
      end)
      |> Heap.push(starting_cell)

    walk_dijkstra({grid, heap})
  end

  @clockwise %{
    left: :up,
    right: :down,
    up: :right,
    down: :left
  }

  @counter_clockwise %{
    left: :down,
    right: :up,
    up: :left,
    down: :right
  }

  defp get_next_cell(grid, current_point, direction) do
    new_point =
      case direction do
        :up -> Point.move_up(current_point)
        :down -> Point.move_down(current_point)
        :left -> Point.move_left(current_point)
        :right -> Point.move_right(current_point)
        _ -> current_point
      end

    Grid.get_cell(grid, new_point)
  end

  def walk_dijkstra({grid, heap}) when is_empty_heap(heap) do
    grid
  end

  def walk_dijkstra({%Grid{} = grid, heap}) do
    {%Cell{point: min_cell_point, value: {_, min_cell_facing}}, heap} =
      Heap.split(heap)

    min_cell_score = Grid.get_cell_value(grid, min_cell_point) |> elem(0)
    min_cell_facing = if min_cell_facing == :start, do: :right, else: min_cell_facing

    [
      {min_cell_facing, 1},
      {Map.get(@clockwise, min_cell_facing), 1 + 1000},
      {Map.get(@counter_clockwise, min_cell_facing), 1 + 1000}
    ]
    |> Enum.map(fn {direction, score_to_increase} ->
      {get_next_cell(grid, min_cell_point, direction), direction, score_to_increase}
    end)
    |> Enum.filter(fn {%Cell{value: {_score, type}}, _, _} -> type in [:empty_space, :end] end)
    |> Enum.reduce({grid, heap}, fn {cell, new_direciton, score_to_increase}, {grid, heap} ->
      %Cell{point: cell_point, value: {current_score, current_facing}} = cell
      new_score = min_cell_score + score_to_increase

      if current_score > new_score do
        new_direciton = if current_facing == :end, do: :end, else: new_direciton
        grid = Grid.replace(grid, cell_point, {new_score, new_direciton})
        heap = Heap.push(heap, Grid.get_cell(grid, cell_point))
        {grid, heap}
      else
        {grid, heap}
      end
    end)
    |> walk_dijkstra()
  end

  def build_graph(grid) do
    starting_cell = find_cell(grid, :start)

    build_graph(grid, Graph.new(), starting_cell, MapSet.new(), :right)
  end

  def build_graph(_grid, graph, %Cell{value: {_, type}}, visited, _facing) when type == :end do
    {graph, visited}
  end

  def build_graph(grid, graph, %Cell{point: source_point}, visited, facing) do
    [
      Point.move_up(source_point),
      Point.move_down(source_point),
      Point.move_left(source_point),
      Point.move_right(source_point)
    ]
    |> Enum.reject(&MapSet.member?(visited, {source_point, &1}))
    |> Enum.reject(fn p ->
      new_facing =
        cond do
          Point.move_left(source_point) == p -> :left
          Point.move_right(source_point) == p -> :right
          Point.move_up(source_point) == p -> :up
          Point.move_down(source_point) == p -> :down
        end

      MapSet.member?(visited, {source_point, p, new_facing})
    end)
    |> Enum.reject(fn p -> Grid.get_cell_value(grid, p) |> elem(1) == :wall end)
    |> Enum.reduce({graph, [], visited}, fn p, {graph, to_visit, visited} ->
      new_facing =
        cond do
          Point.move_left(source_point) == p -> :left
          Point.move_right(source_point) == p -> :right
          Point.move_up(source_point) == p -> :up
          Point.move_down(source_point) == p -> :down
        end

      weight = if new_facing != facing, do: 1001, else: 1
      MapSet.member?(visited, {source_point, p, new_facing})
      graph = Graph.add_edge(graph, source_point, p, weight: weight)
      to_visit = [{p, new_facing} | to_visit]
      visited = MapSet.put(visited, {source_point, p, new_facing})
      {graph, to_visit, visited}
    end)
    |> then(fn {graph, to_visit, visited} ->
      Enum.reduce(to_visit, {graph, visited}, fn {p, facing}, {graph, visited} ->
        build_graph(grid, graph, Grid.get_cell(grid, p), visited, facing)
      end)
    end)
  end

  def overlay(grid, path) do
    Enum.reduce(path, grid, fn p, grid ->
      Grid.replace(grid, p, {0, :optimal})
    end)
    |> print_to_console()
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
