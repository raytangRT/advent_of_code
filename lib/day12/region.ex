defmodule Day12.Region do
  alias Day12.Plot
  require Logger
  defstruct [:value, :plots]

  def new(value, plots \\ []) do
    %__MODULE__{
      value: value,
      plots: plots
    }
  end

  def area(%__MODULE__{plots: plots}) do
    Enum.count(plots)
  end

  def perimeter(grid, %__MODULE__{plots: plots}) do
    Enum.map(plots, fn plot ->
      cell = Grid.get_cell(grid, plot.point)

      neighbor_count =
        Grid.neighbors(grid, cell)
        |> Enum.map(&Grid.Cell.value/1)
        |> Enum.map(&elem(&1, 1))
        |> Enum.count(&(&1.value == plot.value))

      4 - neighbor_count
    end)
    |> Enum.sum()
  end

  def in_region?(%__MODULE__{plots: plots}, target_cell_location) do
    Enum.find(plots, fn plot ->
      target_cell_location == Plot.location(plot)
    end) != nil
  end

  def sides(%__MODULE__{value: value, plots: plots} = region, grid) do
    count_convex = fn neighbors ->
      [
        Enum.all?([:left, :top], &Map.get(neighbors, &1)),
        Enum.all?([:top, :right], &Map.get(neighbors, &1)),
        Enum.all?([:left, :bottom], &Map.get(neighbors, &1)),
        Enum.all?([:bottom, :right], &Map.get(neighbors, &1))
      ]
      |> Enum.count(& &1)
    end

    count_concave = fn neighbors ->
      [
        Enum.map([:top, :right, :top_right], &Map.get(neighbors, &1)),
        Enum.map([:right, :bottom, :bottom_right], &Map.get(neighbors, &1)),
        Enum.map([:left, :top, :top_left], &Map.get(neighbors, &1)),
        Enum.map([:left, :bottom, :bottom_left], &Map.get(neighbors, &1))
      ]
      |> Enum.map(&(&1 == [false, false, true]))
      |> Enum.count(& &1)
    end

    Enum.map(plots, fn plot ->
      neighbors =
        Grid.neighbors_with_direction(grid, Grid.get_cell(grid, plot.point))
        |> Enum.map(fn {key, cell} ->
          value =
            if is_nil(cell) do
              true
            else
              plot_value = Grid.Cell.value(cell) |> elem(1) |> Plot.value()
              plot_location = Grid.Cell.value(cell) |> elem(1) |> Plot.location()
              plot_value != value or not in_region?(region, plot_location)
            end

          {key, value}
        end)
        |> Map.new()

      count_convex.(neighbors) + count_concave.(neighbors)
    end)
    |> Enum.sum()
  end
end
