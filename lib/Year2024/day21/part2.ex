defmodule Year2024.Day21.Part2 do
  def run() do
    data =
      Day21.Part1.read(:actual)
      |> Enum.map(&String.graphemes/1)
      |> Enum.map(&travel/1)
  end

  def travel(code) do
    Enum.chunk_every(["A"] ++ code, 2, 1, :discard)
    |> Enum.map(fn [from, to] ->
      {[from, to], Day21.Helpers.get_numpad_paths(from, to)}
    end)
  end
end
