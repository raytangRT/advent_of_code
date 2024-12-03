defmodule Day3 do
  @input_path "./input/day3.txt"
  @re ~r/mul\((?<left>\d+),(?<right>\d+)\)/

  def run do
    AOC.read_file(@input_path)
    |> Enum.map(&Regex.scan(@re, &1, capture: :all_names))
    |> Enum.concat()
    |> Enum.reduce(0, fn item, acc ->
      [left, right] = item
      acc + String.to_integer(left) * String.to_integer(right)
    end)
  end
end
