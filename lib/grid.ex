defmodule Grid.Cell do
  use TypedStruct

  typedstruct enforced: true do
    field(:point, Point.t())
    field(:value, term())
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

  def value(%__MODULE__{value: value}), do: value
  def point(%__MODULE__{point: point}), do: point
  def decompose(%__MODULE__{point: point, value: value}), do: {point, value}
end

defmodule Grid do
  alias Grid.Cell
  require Logger
  defstruct [:width, :height, :cells]

  @type t :: %__MODULE__{cells: %{Point.t() => Cell.t()}}

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

  def parse_from_list(list, cell_fn \\ &identity/3) do
    cells =
      Enum.with_index(list)
      |> Enum.map(fn {line, y} ->
        String.graphemes(line)
        |> Enum.with_index()
        |> Enum.map(fn {char, x} ->
          value = cell_fn.(x, y, char)
          Cell.new(x, y, value)
        end)
      end)

    %__MODULE__{
      width: Enum.count(cells),
      height: Enum.count(hd(cells)),
      cells:
        List.flatten(cells)
        |> Enum.reduce(%{}, fn item, m ->
          Map.put(m, item.point, item)
        end)
    }
  end

  def no_of_cells(%__MODULE__{width: width, height: height}), do: width * height

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

  defp prepare_content(%Grid{cells: cells}, cell_fn) do
    Map.keys(cells)
    |> Enum.sort_by(fn p -> {p.y, p.x} end)
    |> Enum.chunk_by(fn p -> p.y end)
    ## a list of list with x sorted
    |> Enum.reduce([], fn list, output ->
      line =
        Enum.map(list, fn item ->
          cell = Map.get(cells, item)

          cell_fn.(cell)
        end)
        |> Enum.reduce("", fn item, str -> str <> item end)

      [line | output]
    end)
    |> Enum.reverse()
    |> Enum.join("\r\n")
  end

  def print_to_file(%__MODULE__{} = grid, file_name, cell_fn) do
    content = prepare_content(grid, cell_fn)

    File.write!(file_name, content)
  end

  def print(grid, cell_fn) do
    prepare_content(grid, cell_fn) |> IO.puts()
  end

  @spec get_cells(Grid.t(), (Cell.t() -> boolean)) :: [Cell.t()]
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

  def swap(grid, %Point{} = point1, %Point{} = point2) do
    point1_value = Grid.get_cell_value(grid, point1)
    point2_value = Grid.get_cell_value(grid, point2)

    replace(grid, point1, point2_value)
    |> replace(point2, point1_value)
  end

  @top {0, -1}
  @bottom {0, 1}
  @left {-1, 0}
  @right {1, 0}
  @top_left {-1, -1}
  @top_right {1, -1}
  @bottom_right {1, 1}
  @bottom_left {-1, 1}

  @direction_map %{up: {0, -1}, down: {0, 1}, left: {-1, 0}, right: {1, 0}}
  def neighbors(grid, cell, opt)

  def neighbors(grid, cell, opt) when is_boolean(opt) do
    directions =
      [@top, @bottom, @left, @right] ++
        if opt do
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

  def get_neighbors(%__MODULE__{} = grid, cell, directions) when is_list(directions) do
    Enum.map(directions, fn direction ->
      {direction, Grid.get_cell(grid, move_point(cell, direction))}
    end)
  end

  defp move_point(%Cell{point: point}, direction) do
    Point.move(point, Map.get(@direction_map, direction))
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
