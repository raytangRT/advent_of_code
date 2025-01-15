defmodule Year2024.Day15.Part1 do
  alias Grid.Cell

  def run(mode \\ :sample) do
    {grid, movements} = read(mode)

    walk(grid, movements)
    |> then(fn grid ->
      print_grid(grid)
      grid
    end)
    |> score()
  end

  def read(mode \\ :sample) do
    grid =
      AOC.read_file(mode, "day15")
      |> Grid.new(fn _x, _y, value ->
        case value do
          "#" -> :wall
          "O" -> :box
          "@" -> :current
          "." -> :empty_space
        end
      end)

    movements =
      AOC.read_file(mode, "day15.movement")
      |> Enum.map(&String.graphemes/1)
      |> List.flatten()
      |> Enum.map(fn c ->
        case c do
          "<" ->
            :left

          ">" ->
            :right

          "^" ->
            :up

          "v" ->
            :down
        end
      end)

    {grid, movements}
  end

  def score(grid) do
    Grid.get_cells(grid, fn cell -> Cell.value(cell) == :box end)
    |> Enum.map(&Cell.point/1)
    |> Enum.map(fn point -> point.y * 100 + point.x end)
    |> Enum.sum()
  end

  def walk(%Grid{} = grid, movements) when is_list(movements) do
    current =
      Grid.get_cells(grid, fn cell ->
        Cell.value(cell) == :current
      end)
      |> hd

    [next | rest] = movements
    walk(grid, rest, current, next)
  end

  defp print_grid(grid) do
    Grid.print(grid, fn cell ->
      cell_value = Cell.value(cell)

      case cell_value do
        :wall -> "#"
        :empty_space -> "."
        :box -> "O"
        :current -> "@"
      end
    end)
  end

  def walk(grid, movements, current, next_step)

  def walk(%Grid{} = grid, movements, _current, _next_step) when length(movements) == 0 do
    grid
  end

  def walk(%Grid{} = grid, movements, current, next_step) when is_list(movements) do
    # print_grid(grid)
    # List.duplicate(next_step, 10) |> Enum.join(" ") |> IO.puts()

    {next_cell, next_cell_point, next_cell_value} = next(grid, current, next_step)

    {grid, new_current} =
      case next_cell_value do
        :wall ->
          {grid, current}

        :empty_space ->
          grid =
            Grid.swap(grid, Cell.point(current), next_cell_point)

          {grid, Cell.new(next_cell_point, :current)}

        :box ->
          new_grid =
            move_boxes(grid, next_cell, next_step, next_cell_point)

          if is_nil(new_grid) do
            {grid, current}
          else
            new_grid = Grid.swap(new_grid, Cell.point(current), next_cell_point)
            {new_grid, Cell.new(next_cell_point, :current)}
          end
      end

    [next | rest] = movements
    walk(grid, rest, new_current, next)
  end

  defp next(grid, current, next_step) do
    next_location =
      case next_step do
        :up -> Point.move_top(Cell.point(current))
        :down -> Point.move_down(Cell.point(current))
        :left -> Point.move_left(Cell.point(current))
        :right -> Point.move_right(Cell.point(current))
      end

    next_cell = Grid.get_cell(grid, next_location)
    {next_cell_point, next_cell_value} = Cell.decompose(next_cell)
    {next_cell, next_cell_point, next_cell_value}
  end

  def move_boxes(grid, current, direction, first_box_point) do
    {next_cell, next_point, next_value} = next(grid, current, direction)

    case next_value do
      :box ->
        move_boxes(grid, next_cell, direction, first_box_point)

      :wall ->
        nil

      :empty_space ->
        Grid.swap(grid, next_point, first_box_point)
    end
  end
end
