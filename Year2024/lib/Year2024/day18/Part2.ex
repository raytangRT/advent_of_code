defmodule Year2024.Day18.Part2 do
  alias Grid.Cell

  def read(mode \\ :sample) do
    width = if mode == :actual, do: 70, else: 6
    memory_size = if mode == :actual, do: 1024, else: 12
    read(width, width, memory_size, mode)
  end

  def read(width, height, rows_to_take, mode \\ :sample) do
    AOC.read_file(mode, "day18")
    |> Enum.take(rows_to_take)
    |> Enum.reduce(Grid.new(width, height, AOC.f2(:slot)), fn pair, grid ->
      point = String.split(pair, ",") |> List.to_tuple() |> Point.new()
      Grid.replace(grid, point, :wall)
    end)
    |> Grid.replace(Point.new(0, 0), :end)
    |> Grid.replace(Point.new(width, height), :start)
  end

  def skip(rows_to_skip, mode \\ :sample) do
    AOC.read_file(mode, "day18")
    |> Enum.split(rows_to_skip)
    |> elem(1)
    |> Enum.map(&Point.new(String.split(&1, ",") |> List.to_tuple()))
  end

  def run(mode \\ :sample) do
    memory_size = if mode == :actual, do: 1024, else: 12
    grid = read(mode)

    maze =
      Maze.new(grid, &Cell.value/1)

    corrupting_memory = skip(memory_size, mode) |> Enum.with_index()

    result =
      Enum.reduce_while(corrupting_memory, maze, fn {memory_point, idx}, maze ->
        ProgressBar.render(idx, length(corrupting_memory), suffix: :count)
        new_maze = Maze.add_wall(maze, memory_point, AOC.f1(:wall))
        new_path = Maze.dijkstra(new_maze)

        cond do
          is_nil(new_path) ->
            {:halt, memory_point}

          true ->
            AOC.clear_terminal()
            Maze.print(new_maze, new_path)
            {:cont, new_maze}
        end
      end)

    IO.puts("\r\n\r\nresult = #{inspect(result)}")
  end
end
