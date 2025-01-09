defmodule Maze do
  alias Grid.Cell
  defstruct [:graph, :grid, :cell_type_fn]

  @start_tag :start
  @end_tag :end
  @wall_tag :wall
  @slot_tag :slot
  @path_tag :path
  @start_path_tag :start_path
  @end_path_tag :end_path
  @label_point_tag :label_point

  @spec new(%Grid{}, (Cell.t() -> :start | :end | :wall | :slot)) :: any()
  def new(%Grid{} = grid, cell_type_fn) do
    starting = get_cell(grid, cell_type_fn, @start_tag)
    graph = build_graph(Graph.new(), grid, cell_type_fn, [starting], MapSet.new())
    IO.puts("")

    %__MODULE__{
      graph: graph,
      grid: grid,
      cell_type_fn: cell_type_fn
    }
  end

  def print(%Maze{grid: grid, cell_type_fn: cell_type_fn}, path \\ []) do
    grid = if path != [], do: overlay(grid, cell_type_fn, path), else: grid
    print_grid(grid)
  end

  defp overlay(grid, cell_type_fn, path) do
    startting_point = get_cell(grid, cell_type_fn, :start) |> Cell.point()
    ending_point = get_cell(grid, cell_type_fn, :end) |> Cell.point()

    Enum.reduce(path, grid, fn point, grid ->
      tag =
        cond do
          point == startting_point -> @start_path_tag
          point == ending_point -> @end_path_tag
          true -> @path_tag
        end

      Grid.replace(grid, point, tag)
    end)
  end

  defp print_grid(grid) do
    Grid.print(grid, fn %Cell{value: type} ->
      case type do
        @start_tag -> "S"
        @end_tag -> "E"
        @wall_tag -> "#"
        @slot_tag -> "."
        @path_tag -> "O" |> AOC.Text.yellow()
        @start_path_tag -> "S" |> AOC.Text.blue()
        @end_path_tag -> "E" |> AOC.Text.blue()
        @label_point_tag -> "X" |> AOC.Text.red()
      end
    end)
  end

  def label_point(%Maze{grid: grid} = maze, %Point{} = point) do
    grid = Grid.replace(grid, point, @label_point_tag)

    %Maze{
      grid: grid,
      cell_type_fn: maze.cell_type_fn,
      graph: maze.graph
    }
  end

  def get_cell(%__MODULE__{grid: grid, cell_type_fn: cell_type_fn}, type) do
    get_cell(grid, cell_type_fn, type)
  end

  defp get_cell(%Grid{} = grid, cell_type_fn, type) do
    cells =
      Grid.get_cells(grid, fn %Cell{} = cell ->
        cell_type_fn.(cell) == type
      end)

    if cells == [] do
      []
    else
      hd(cells)
    end
  end

  defp build_graph(graph, _grid, _cell_type_fn, next_cells, _visited) when next_cells == [] do
    graph
  end

  defp build_graph(graph, grid, cell_type_fn, next_cells, visited) do
    ProgressBar.render(MapSet.size(visited), Grid.no_of_cells(grid), suffix: :count)

    Enum.map(next_cells, fn %Cell{point: source_point} = source_cell ->
      Grid.get_neighbors(grid, source_cell, [:up, :down, :left, :right])
      |> Enum.map(&elem(&1, 1))
      |> Enum.reject(fn cell ->
        is_nil(cell) or cell_type_fn.(cell) == @wall_tag
      end)
      |> Enum.map(fn %Cell{point: to_point} ->
        {source_point, to_point}
      end)
    end)
    |> List.flatten()
    |> Enum.reduce({graph, visited, []}, fn {from_point, to_point},
                                            {graph, visited, next_cells} ->
      graph = Graph.add_edge(graph, from_point, to_point)
      visited = MapSet.put(visited, from_point)

      next_cells =
        if MapSet.member?(visited, to_point) do
          next_cells
        else
          [to_point | next_cells]
        end

      {graph, visited, next_cells}
    end)
    |> then(fn {graph, visited, next_cells} ->
      next_cells = Enum.map(next_cells, &Grid.get_cell(grid, &1)) |> Enum.uniq()
      build_graph(graph, grid, cell_type_fn, next_cells, visited)
    end)
  end

  def is_point_in_board?(%Maze{grid: grid}, %Point{} = point) do
    Grid.in_bound?(grid, point)
  end

  def dijkstra(%Maze{graph: graph} = maze, from \\ nil) do
    if is_nil(from) do
      IO.puts("nil from found")
    end

    starting_point =
      AOC.if_nil(from, fn ->
        get_cell(maze, @start_tag) |> Cell.point()
      end)

    ending_point = get_cell(maze, @end_tag) |> Cell.point()
    Graph.dijkstra(graph, starting_point, ending_point)
  end

  def add_wall(%Maze{graph: graph, grid: grid} = maze, %Point{} = point, wall_value_fn) do
    graph = Graph.delete_vertex(graph, point)
    new_wall_cell_value = wall_value_fn.(Grid.get_cell(grid, point))
    grid = Grid.replace(grid, point, new_wall_cell_value)

    %Maze{
      graph: graph,
      cell_type_fn: maze.cell_type_fn,
      grid: grid
    }
  end

  def remove_wall(
        %Maze{graph: graph, grid: grid, cell_type_fn: cell_type_fn} = maze,
        %Point{} = point,
        slot_value_fn \\ AOC.f1(:slot)
      ) do
    if Maze.get_cell(maze, @end_tag) |> Cell.point() == point do
      maze
    else
      new_slot_cell_value = slot_value_fn.(Grid.get_cell(grid, point))
      grid = Grid.replace(grid, point, new_slot_cell_value)

      graph =
        Grid.get_neighbors(grid, Grid.get_cell(grid, point), [:up, :down, :left, :right])
        |> Enum.reject(fn {_, cell} -> is_nil(cell) end)
        |> Enum.reject(fn {_, %Cell{} = cell} ->
          cell_type_fn.(cell) == :wall
        end)
        |> Enum.reduce(graph, fn {_, %Cell{point: from_point}}, graph ->
          Graph.add_edge(graph, from_point, point)
          |> Graph.add_edge(point, from_point)
        end)

      %Maze{
        graph: graph,
        cell_type_fn: cell_type_fn,
        grid: grid
      }
    end
  end
end
