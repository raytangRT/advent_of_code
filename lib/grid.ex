defmodule Grid do
  alias Grid.Cell
  require Logger
  defstruct [:width, :height, :cells]

  def identity(_x, _y, value), do: value

  def new(width, height, cell_fn) when is_number(width) and is_number(height) do
    cells =
      Enum.reduce(0..width, [], fn column_idx, list ->
        Enum.reduce(0..height, list, fn row_idx, list ->
          [Cell.new(column_idx, row_idx, cell_fn.(column_idx, row_idx)) | list]
        end)
      end)

    %__MODULE__{
      width: width,
      height: height,
      cells:
        List.flatten(cells)
        |> Enum.reduce(%{}, fn item, m ->
          Map.put(m, item.point, item)
        end)
    }
  end

  def new(file_stream, cell_fn \\ &identity/3) do
    cells =
      file_stream
      |> Enum.with_index()
      |> Enum.map(fn {line, y} ->
        String.graphemes(line)
        |> Enum.with_index()
        |> Enum.map(fn {char, x} ->
          value = cell_fn.(x, y, char)
          Grid.Cell.new(x, y, value)
        end)
      end)

    %__MODULE__{
      width: Enum.count(cells),
      height: Enum.count(hd(cells)),
      cells:
        cells
        |> List.flatten()
        |> Enum.reduce(%{}, fn item, m ->
          Map.put(m, item.point, item)
        end)
    }
  end

  def parse(file_path, cell_fn \\ &identity/3) do
    new(AOC.read_file(file_path), cell_fn)
  end

  def iterator(%__MODULE__{cells: cells}) do
    Enum.sort(cells)
  end

  def get_cell(grid, x, y) when is_integer(x) and is_integer(y) do
    get_cell(grid, Point.new(x, y))
  end

  def get_cell(grid, point) do
    Map.get(grid.cells, point)
  end

  def get_cell_value(%__MODULE__{cells: cells}, point) do
    value = Map.get(cells, point)

    if not is_nil(value) do
      Cell.value(value)
    end
  end

  def in_bound?(grid, x, y) when is_integer(x) and is_integer(y) do
    cond do
      x < 0 or x >= grid.width -> false
      y < 0 or y >= grid.height -> false
      true -> true
    end
  end

  def keys(%__MODULE__{cells: cells}) do
    Map.keys(cells) |> Enum.sort()
  end

  def in_bound?(grid, %Point{x: x, y: y}) do
    in_bound?(grid, x, y)
  end

  def print(grid, cell_fn) do
    Map.keys(grid.cells)
    |> Enum.sort_by(fn p -> {p.y, p.x} end)
    |> Enum.chunk_by(fn p -> p.y end)
    ## a list of list with x sorted
    |> Enum.each(fn list ->
      Enum.map(list, fn item ->
        cell = Map.get(grid.cells, item)

        cell_fn.(cell)
      end)
      |> Enum.reduce("", fn item, str -> str <> item end)
      |> IO.puts()
    end)
  end

  def get_cells(grid, filter \\ & &1) do
    grid.cells
    |> Map.values()
    |> Enum.filter(filter)
  end

  def replace(grid, point, value) do
    %__MODULE__{
      width: grid.width,
      height: grid.height,
      cells: Map.replace(grid.cells, point, Grid.Cell.new(point, value))
    }
  end

  @top {0, -1}
  @bottom {0, 1}
  @left {-1, 0}
  @right {1, 0}
  @top_left {-1, -1}
  @top_right {1, -1}
  @bottom_right {1, 1}
  @bottom_left {-1, 1}

  def neighbors(grid, cell, include_diagonals? \\ false) do
    directions =
      [@top, @bottom, @left, @right] ++
        if include_diagonals? do
          [@top_left, @top_right, @bottom_left, @bottom_right]
        else
          []
        end

    Enum.reduce(directions, [], fn direction, neighbors ->
      cell = Grid.get_cell(grid, Point.move(cell.point, direction))

      if not is_nil(cell) do
        [cell | neighbors]
      else
        neighbors
      end
    end)
  end

  def neighbors_with_direction(%__MODULE__{} = grid, cell) do
    move = fn direction ->
      Grid.get_cell(grid, Point.move(cell.point, direction))
    end

    Map.new()
    |> Map.put(:top, move.(@top))
    |> Map.put(:bottom, move.(@bottom))
    |> Map.put(:left, move.(@left))
    |> Map.put(:right, move.(@right))
    |> Map.put(:top_left, move.(@top_left))
    |> Map.put(:top_right, move.(@top_right))
    |> Map.put(:bottom_left, move.(@bottom_left))
    |> Map.put(:bottom_right, move.(@bottom_right))
  end
end

defmodule Grid.Cell do
  alias Grid.Cell
  defstruct [:point, :value]

  defimpl String.Chars, for: Grid.Cell do
    def to_string(cell) do
      "Cell(#{cell.point}), value = #{inspect(cell.value)}"
    end
  end

  def new(point, value) do
    %__MODULE__{
      point: point,
      value: value
    }
  end

  def new(x, y, value) do
    %__MODULE__{
      point: Point.new(x, y),
      value: value
    }
  end

  def value(%Cell{value: value}), do: value
end
