defmodule Day14.Part2 do
  require Logger
  import Mogrify
  @re ~r"p=(?<px>\d+),(?<py>\d+) v=(?<vx>-?\d+),(?<vy>-?\d+)"

  @width 101
  @width_midpoint (@width - 1) / 2
  @height 103
  @height_midpoint (@height - 1) / 2

  def run() do
    read() |> walk_all()
  end

  def read() do
    AOC.read_file(:actual, "day14")
    |> Enum.map(fn line ->
      %{"px" => px, "py" => py, "vx" => vx, "vy" => vy} = Regex.named_captures(@re, line)

      [px, py, vx, vy]
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  def walk_all(robots, idx \\ 0, scores \\ [])

  def walk_all(_, idx, _) when idx > 1_000_000 do
    :ok
  end

  def walk_all(_, idx, scores) when length(scores) > 10000 do
    min_element = Enum.min_by(scores, &elem(&1, 0))
    {_, min_element_idx, robots} = min_element

    image =
      %Mogrify.Image{
        path: "./output/day14/#{min_element_idx}.png",
        ext: "png"
      }
      |> custom("size", "#{@width}x#{@height}")
      |> canvas("black")

    Enum.reduce(robots, image, fn {x, y, _, _}, img ->
      img
      |> custom("fill", "green")
      |> custom(
        "draw",
        "rectangle #{to_string(:io_lib.format("~g,~g ~g,~g", [x, y, x + 1, y + 1]))}"
      )
    end)
    |> create(path: "./output/day14/")

    Logger.info("min_score = #{inspect(min_element)}")
    walk_all(robots, idx, [min_element])
  end

  def walk_all(robots, idx, scores) do
    ProgressBar.render(idx, 1_000_000, suffix: :count)

    robots =
      Enum.reduce(robots, [], fn robot, list ->
        [walk(robot) | list]
      end)

    score = calculate_score(robots)
    walk_all(robots, idx + 1, [{score, idx, robots} | scores])
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
end
