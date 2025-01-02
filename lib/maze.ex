defmodule Maze do
  alias Grid.Cell
  defstruct [:graph, :grid, :cell_type_fn]

  @start_tag :start
  @end_tag :end
  @wall_tag :wall
  @slot_tag :slot
  @path_tag :path

  @spec new(%Grid{}, (Cell.t() -> :start | :end | :wall | :slot)) :: any()
  def new(%Grid{} = grid, cell_type_fn) do
    starting = get_cell(grid, cell_type_fn, @start_tag)
    graph = build_graph(Graph.new(), grid, cell_type_fn, [starting], MapSet.new())

    %__MODULE__{
      graph: graph,
      grid: grid,
      cell_type_fn: cell_type_fn
    }
  end

  def print(%Maze{grid: grid}, path \\ []) do
    grid = if path != [], do: overlay(grid, path), else: grid
    print_grid(grid)
  end

  defp overlay(grid, path) do
    Enum.reduce(path, grid, fn point, grid ->
      Grid.replace(grid, point, :path)
    end)
  end

  defp print_grid(grid) do
    Grid.print(grid, fn %Cell{value: type} ->
      case type do
        @start_tag -> "S"
        @end_tag -> "E"
        @wall_tag -> "W"
        @slot_tag -> "."
        @path_tag -> "O" |> AOC.Text.yellow()
      end
    end)
  end

  def get_cell(%__MODULE__{grid: grid, cell_type_fn: cell_type_fn}, type) do
    get_cell(grid, cell_type_fn, type)
  end

  defp get_cell(%Grid{} = grid, cell_type_fn, type) do
    Grid.get_cells(grid, fn %Cell{} = cell ->
      cell_type_fn.(cell) == type
    end)
    |> hd()
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

  def dijkstra(%Maze{graph: graph} = maze) do
    starting_point = get_cell(maze, @start_tag) |> Cell.point()
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
end
