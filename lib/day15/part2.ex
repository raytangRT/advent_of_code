defmodule Day15.Part2 do
  require Logger
  alias Grid.Cell

  def run(mode \\ :sample) do
    {grid, movements} = read(mode)

    {grid, grids} = walk(grid, movements)
    score(grid)
  end

  def read(mode \\ :sample) do
    grid =
      AOC.read_file(mode, "day15")
      |> Enum.map(fn str ->
        String.graphemes(str)
        |> Enum.map(fn char ->
          case char do
            "#" -> ["#", "#"]
            "O" -> ["[", "]"]
            "." -> [".", "."]
            "@" -> ["@", "."]
          end
        end)
        |> Enum.join()
      end)
      |> Grid.parse_from_list(fn _x, _y, value ->
        case value do
          "#" -> :wall
          "[" -> :box_start
          "]" -> :box_end
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
    Grid.get_cells(grid, fn cell -> Cell.value(cell) in [:box_start] end)
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
    walk(grid, rest, current, next, [{next, grid}])
  end

  def print_grids(grids, time \\ 100) do
    Enum.with_index(grids)
    |> Enum.each(fn {{movement, grid}, idx} ->
      ProgressBar.render(idx, length(grids), suffix: :count)
      IO.puts(" ")
      print_grid(grid)

      IO.puts("===========next = #{movement}")
      :timer.sleep(time)
    end)
  end

  def print_grid(grid) do
    Grid.print(grid, fn cell ->
      cell_value = Cell.value(cell)

      case cell_value do
        :wall -> "#"
        :empty_space -> "."
        :box_start -> "["
        :box_end -> "]"
        :current -> "@"
        :up -> "^"
        :down -> "v"
        :left -> "<"
        :right -> ">"
      end
    end)
  end

  def move_to_next_empty_slot(grid, current, next_cell_point, direction) do
    {
      Grid.replace(grid, Cell.point(current), direction)
      |> Grid.swap(Cell.point(current), next_cell_point),
      Cell.new(next_cell_point, :current)
    }
  end

  def walk(%Grid{} = grid, movements, current, next_step, grids) do
    # print_grid(grid)
    # List.duplicate(next_step, 10) |> Enum.join(" ") |> IO.puts()
    # AOC.clear_terminal()
    {next_cell, next_cell_point, next_cell_value} = next(grid, current, next_step)

    {grid, new_current} =
      cond do
        next_cell_value == :wall ->
          {grid, current}

        next_cell_value == :empty_space ->
          move_to_next_empty_slot(grid, current, next_cell_point, next_step)

        {next_step, next_cell_value} == {:left, :box_end} or
          {next_step, next_cell_value} == {:right, :box_start} or
            (next_step in [:up, :down] and next_cell_value in [:box_start, :box_end]) ->
          {can_move?, new_grid} = move_boxes(grid, get_box(grid, next_cell), next_step)

          if can_move? do
            move_to_next_empty_slot(new_grid, current, next_cell_point, next_step)
          else
            {grid, current}
          end

        true ->
          # Logger.info("next = #{next_step} and next_cell_value = #{inspect(next_cell_value)}")
          {grid, current}
      end

    if length(movements) > 0 do
      [next | rest] = movements
      walk(grid, rest, new_current, next, [{next, grid} | grids])
    else
      {grid, [{:end, grid} | grids] |> Enum.reverse()}
    end
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

  def get_box(grid, half_box) do
    cell_value = Cell.value(half_box)
    cell_point = Cell.point(half_box)

    case cell_value do
      :box_start -> {half_box, Grid.get_cell(grid, Point.move_right(cell_point))}
      :box_end -> {Grid.get_cell(grid, Point.move_left(cell_point)), half_box}
    end
  end

  def move_boxes(grid, current_box, direction)

  def move_boxes(grid, {box_start, box_end}, direction) when direction in [:up, :down] do
    {box_start_next_cell, box_start_next_cell_point, box_start_next_cell_value} =
      next(grid, box_start, direction)

    {box_end_next_cell, box_end_next_cell_point, box_end_next_cell_value} =
      next(grid, box_end, direction)

    next_cell_values = {box_start_next_cell_value, box_end_next_cell_value}

    cond do
      box_start_next_cell_value == :wall or box_end_next_cell_value == :wall ->
        {false, nil}

      next_cell_values == {:empty_space, :empty_space} ->
        new_grid =
          Grid.swap(grid, Cell.point(box_start), box_start_next_cell_point)
          |> Grid.swap(Cell.point(box_end), box_end_next_cell_point)

        {true, new_grid}

      next_cell_values == {:box_end, :box_start} ->
        {can_left_move?, new_grid} =
          move_boxes(grid, get_box(grid, box_start_next_cell), direction)

        {can__right_move?, _} =
          move_boxes(grid, get_box(grid, box_end_next_cell), direction)

        if can_left_move? and can__right_move? do
          {_, new_grid} = move_boxes(new_grid, get_box(grid, box_end_next_cell), direction)

          new_grid =
            Grid.swap(new_grid, Cell.point(box_start), box_start_next_cell_point)
            |> Grid.swap(Cell.point(box_end), box_end_next_cell_point)

          {true, new_grid}
        else
          {false, nil}
        end

      next_cell_values in [{:box_end, :empty_space}, {:box_start, :box_end}] ->
        {can_move?, new_grid} = move_boxes(grid, get_box(grid, box_start_next_cell), direction)

        if can_move? do
          new_grid =
            Grid.swap(new_grid, Cell.point(box_start), box_start_next_cell_point)
            |> Grid.swap(Cell.point(box_end), box_end_next_cell_point)

          {true, new_grid}
        else
          {false, nil}
        end

      next_cell_values == {:empty_space, :box_start} ->
        {can_move?, new_grid} = move_boxes(grid, get_box(grid, box_end_next_cell), direction)

        if can_move? do
          new_grid =
            Grid.swap(new_grid, Cell.point(box_start), box_start_next_cell_point)
            |> Grid.swap(Cell.point(box_end), box_end_next_cell_point)

          {true, new_grid}
        else
          {false, nil}
        end
    end
  end

  def move_boxes(grid, {box_start, box_end} = current_box, direction)
      when direction in [:left, :right] do
    {next_cell, next_cell_point, next_cell_value} =
      case direction do
        :right -> next(grid, box_end, direction)
        :left -> next(grid, box_start, direction)
      end

    box_start_point = Cell.point(box_start)
    box_end_point = Cell.point(box_end)

    cond do
      next_cell_value == :wall ->
        {false, nil}

      next_cell_value == :empty_space ->
        new_grid =
          case direction do
            :right ->
              Grid.swap(grid, next_cell_point, box_end_point)
              |> Grid.swap(box_end_point, box_start_point)

            :left ->
              Grid.swap(grid, next_cell_point, box_start_point)
              |> Grid.swap(box_start_point, box_end_point)
          end

        {true, new_grid}

      next_cell_value in [:box_start, :box_end] ->
        {can_move?, new_grid} = move_boxes(grid, get_box(grid, next_cell), direction)

        if can_move? do
          move_boxes(new_grid, current_box, direction)
        else
          {false, nil}
        end
    end
  end
end
