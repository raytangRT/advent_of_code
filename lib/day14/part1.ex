defmodule Day14.Part1 do
  require Logger
  @re ~r"p=(?<px>\d+),(?<py>\d+) v=(?<vx>-?\d+),(?<vy>-?\d+)"
  @width 101
  @width_midpoint (@width - 1) / 2
  @height 103
  @height_midpoint (@height - 1) / 2

  # 45120810 too low
  def run(mode \\ :sample) do
    robots = read(mode)

    robots
    |> Enum.map(fn robot ->
      Enum.reduce(1..100, robot, fn _, robot ->
        walk(robot)
      end)
    end)
    |> calculate_score()
  end

  def calculate_score(robots) do
    Enum.reject(robots, fn {x, y, _, _} ->
      x == @width_midpoint or y == @height_midpoint
    end)
    |> Enum.group_by(fn {x, y, _, _} ->
      left_right =
        cond do
          x >= 0 and x <= @width_midpoint - 1 -> :left
          true -> :right
        end

      top_bottom =
        cond do
          y >= 0 and y <= @height_midpoint - 1 -> :top
          true -> :bottom
        end

      {left_right, top_bottom}
    end)
    |> Enum.reduce(1, fn {_, value}, sum ->
      sum * length(value)
    end)
  end

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day14")
    |> Enum.map(fn line ->
      %{"px" => px, "py" => py, "vx" => vx, "vy" => vy} = Regex.named_captures(@re, line)

      [px, py, vx, vy]
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  def walk({px, py, vx, vy}) do
    px = px + vx
    py = py + vy
    {px |> wrap(@width - 1), py |> wrap(@height - 1), vx, vy}
  end

  defp wrap(input, upper_bound) do
    cond do
      input < 0 -> upper_bound + input + 1
      input > upper_bound -> (input - upper_bound - 1) |> rem(upper_bound + 1)
      true -> input
    end
  end
end
