defmodule Day20.Part2 do
  def run(mode \\ :sample) do
    maze = Day20.Part1.read(mode)
    path = Maze.dijkstra(maze)

    radius = if mode == :actual, do: 20, else: 6
    max_distance = if mode == :actual, do: 100, else: 50

    path_distances =
      Enum.reduce(0..(length(path) - 1), {%{}, path}, fn _, {path_distances, [head | rest]} ->
        path_distances = Map.put(path_distances, head, length(rest))
        {path_distances, rest}
      end)
      |> elem(0)

    result =
      path
      |> Enum.with_index()
      |> Enum.reduce(BiMultiMap.new(), fn {point, idx}, result ->
        remaining_distance = length(path) - idx - 1

        range(point, radius)
        |> Enum.filter(&Maze.is_point_in_board?(maze, &1))
        |> Enum.reduce(result, fn p, result ->
          maze = Maze.remove_wall(maze, p)
          new_remaining_path = Maze.dijkstra(maze, p) |> AOC.if_nil([])

          if new_remaining_path != [] do
            new_distance = new_remaining_path |> length

            distance_saved =
              remaining_distance - new_distance - Point.distance_manhattan(p, point) + 1

            if distance_saved >= max_distance do
              BiMultiMap.put(result, distance_saved, {point, p})
            else
              result
            end
          else
            result
          end
        end)
      end)

    target = 76

    BiMultiMap.get(result, target)
    |> Enum.each(fn {from, to} ->
      "#{inspect(from)} ||| #{inspect(to)}" |> IO.puts()
      path2 = clip_path(path, from, to)
      IO.inspect(path2)
      Maze.print(maze, path2)
      "===================================" |> IO.puts()
    end)
  end

  def range(%Point{x: x, y: y} = point, radius) do
    for dx <- -radius..radius, dy <- -radius..radius do
      x = x + dx
      y = y + dy

      if dx * dx + dy * dy <= radius * radius do
        Point.new(x, y)
      end
    end
    # Remove nil values from the list
    |> Enum.filter(& &1)
    |> Enum.reject(&(&1 == point))
  end

  def clip_path(path, from, to) do
    from_idx = Enum.find_index(path, &(&1 == from))
    to_idx = Enum.find_index(path, &(&1 == to))

    path
    |> Enum.with_index()
    |> Enum.reduce([], fn {item, idx}, result ->
      if idx <= from_idx or idx >= to_idx do
        [item | result]
      else
        result
      end
    end)
    |> Enum.reverse()
  end
end
