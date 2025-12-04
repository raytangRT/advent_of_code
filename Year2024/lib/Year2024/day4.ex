defmodule Year2024.Day4 do
  require Logger

  def run do
    AOC.read_file("day4.txt")
    |> Enum.reduce([], fn item, list -> [item | list] end)
    |> Enum.reverse()
    |> (&[count_horizontally(&1), count_vertically(&1), count_diagonally(&1)]).()
    |> Enum.sum()
  end

  @target ["XMAS", "SAMX"]

  def count_horizontally(input) do
    input
    |> Enum.map(fn str ->
      Enum.map(@target, fn substring ->
        str |> String.split(substring) |> Enum.drop(1) |> length()
      end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def count_vertically(input) do
    input
    |> Enum.map(&String.graphemes/1)
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.map(&Enum.join/1)
    |> count_horizontally()
  end

  def count_diagonally(input) do
    map = Enum.map(input, &String.graphemes/1)
    height = length(map)
    width = length(Enum.at(map, 0))

    [
      Enum.reduce(0..(width - 1), [], fn x, list ->
        [build_str(map, x, 0, height, [], 1) |> Enum.reject(&is_nil/1) |> List.to_string() | list]
      end)
      |> Enum.reverse()
      |> count_horizontally(),
      Enum.reduce(1..(height - 1), [], fn y, list ->
        [build_str(map, 0, y, height, [], 1) |> Enum.reject(&is_nil/1) |> List.to_string() | list]
      end)
      |> Enum.reverse()
      |> count_horizontally(),
      Enum.reduce((width - 1)..0, [], fn x, list ->
        [
          build_str(map, x, 0, height, [], -1) |> Enum.reject(&is_nil/1) |> List.to_string()
          | list
        ]
      end)
      |> Enum.reverse()
      |> count_horizontally(),
      Enum.reduce(1..(height - 1), [], fn y, list ->
        [
          build_str(map, width - 1, y, height, [], -1)
          |> Enum.reject(&is_nil/1)
          |> List.to_string()
          | list
        ]
      end)
      |> Enum.reverse()
      |> count_horizontally()
    ]
    |> Enum.sum()
  end

  def build_str(map, x, y, height, list, direction) do
    if y > height || x < 0 do
      list |> Enum.reverse()
    else
      build_str(map, x + direction, y + 1, height, [value(map, x, y) | list], direction)
    end
  end

  def value(map, x, y) do
    with row when not is_nil(row) <- Enum.at(map, y),
         cell when not is_nil(cell) <- Enum.at(row, x) do
      cell
    else
      _ -> nil
    end
  end

  # 2050 too high
  # 139 too low
  def run2 do
    map =
      AOC.read_file("day4.txt")
      |> Enum.reduce([], fn item, list -> [item | list] end)
      |> Enum.reverse()
      |> Enum.map(&String.graphemes/1)

    height = length(map)
    width = length(Enum.at(map, 0))

    Enum.map(1..(height - 1), fn y ->
      Enum.map(1..(width - 1), fn x ->
        cell = value(map, x, y)

        if cell == "A" do
          top_left = value(map, x - 1, y - 1)
          bottom_right = value(map, x + 1, y + 1)
          top_right = value(map, x + 1, y - 1)
          bottom_left = value(map, x - 1, y + 1)

          cond do
            is_nil(top_left) ->
              false

            is_nil(bottom_right) ->
              false

            is_nil(top_right) ->
              false

            is_nil(bottom_left) ->
              false

            (top_left <> bottom_right == "MS" or top_left <> bottom_right == "SM") and
                (top_right <> bottom_left == "MS" or top_right <> bottom_left == "SM") ->
              # Logger.info(
              #   "(#{x}, #{y}) - #{top_left} #{top_right} #{cell} #{bottom_left} #{bottom_right}"
              # )
              #
              {cell, x, y}
              true

            true ->
              false
          end
        else
          false
        end
      end)
      |> Enum.reject(&(&1 == false))
    end)
    |> Enum.concat()
    |> Enum.count()
  end
end
