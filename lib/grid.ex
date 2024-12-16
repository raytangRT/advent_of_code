defmodule Grid do
  require Logger
  defstruct [:width, :height, :cells]

  def parse(file_path, cell_fn) do
    cells =
      AOC.read_file(file_path)
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

  def get_cell(grid, x, y) when is_integer(x) and is_integer(y) do
    get_cell(grid, Point.new(x, y))
  end

  def get_cell(grid, point) do
    Map.get(grid.cells, point)
  end

  def in_bound?(grid, x, y) when is_integer(x) and is_integer(y) do
    cond do
      x < 0 or x >= grid.width -> false
      y < 0 or y >= grid.height -> false
      true -> true
    end
  end

  def in_bound?(grid, point) do
    {x, y} = Point.to_tuple(point)
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

  def get_cells(grid, filter) do
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
end

defmodule Grid.Cell do
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
end
