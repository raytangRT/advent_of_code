defmodule Day18.Part1 do
  import HeapGuards
  alias Grid.Cell

  def run(mode \\ :sample) do
    width = if mode == :actual, do: 70, else: 6
    rows_to_take = if mode == :actual, do: 1024, else: 12

    grid =
      read(width, width, rows_to_take, mode)
      |> walk()

    get_cell(grid, :end)
  end

  def read(width, height, rows_to_take, mode \\ :sample) do
    AOC.read_file(mode, "day18")
    |> Enum.take(rows_to_take)
    |> Enum.reduce(Grid.new(width, height, AOC.f2({:inf, :safe})), fn pair, grid ->
      point = String.split(pair, ",") |> List.to_tuple() |> Point.new()
      Grid.replace(grid, point, {:inf, :corrupted})
    end)
    |> Grid.replace(Point.new(0, 0), {:inf, :end})
    |> Grid.replace(Point.new(width, height), {0, :start})
  end

  def print_grid(grid) do
    grid
    |> Grid.print(fn %Cell{value: {distance, value}} ->
      case value do
        :safe ->
          if distance == :inf,
            do: "...",
            else: distance |> Integer.to_string() |> String.pad_leading(3)

        :corrupted ->
          "###"

        :start ->
          "SSS"

        :end ->
          "EEE"

        :path ->
          "O"
      end
    end)
  end

  def get_cell(grid, type) do
    Grid.get_cells(
      grid,
      fn %Cell{value: {_, value}} ->
        value == type
      end
    )
    |> hd()
  end

  def walk(grid) when is_struct(grid, Grid) do
    starting_cell = get_cell(grid, :start)

    heap =
      Heap.new(fn %Cell{value: {l_distance, _}}, %Cell{value: {r_distance, _}} ->
        l_distance < r_distance
      end)
      |> Heap.push(starting_cell)

    walk({grid, heap})
  end

  def walk({grid, heap} = input) when is_tuple(input) and is_empty_heap(heap) do
    grid
  end

  def walk({grid, heap} = input) when is_tuple(input) and is_struct(grid, Grid) do
    {%Cell{point: point, value: {distance, _}}, heap} = Heap.split(heap)

    [
      Point.move_left(point),
      Point.move_right(point),
      Point.move_up(point),
      Point.move_down(point)
    ]
    |> Enum.map(&Grid.get_cell(grid, &1))
    |> Enum.reject(fn cell ->
      is_nil(cell) or Cell.value(cell) == {:inf, :corrupted}
    end)
    |> Enum.reduce({grid, heap}, fn %Cell{point: point, value: {current_distance, t}},
                                    {grid, heap} ->
      new_distance = distance + 1

      if current_distance > new_distance do
        grid = Grid.replace(grid, point, {new_distance, t})
        heap = Heap.push(heap, Grid.get_cell(grid, point))
        {grid, heap}
      else
        {grid, heap}
      end
    end)
    |> walk()
  end
end
