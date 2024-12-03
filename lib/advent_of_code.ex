defmodule AOC do
  def read_file(file_path) do
    Path.expand(file_path)
    |> File.stream!([:line])
    |> Stream.map(&String.trim/1)
  end

  def not_nil_do(input, f) do
    input
    |> case do
      nil -> nil
      ^input -> f.(input)
    end
  end

  def list_to_integer(list) do
    Enum.map(list, &String.to_integer/1)
  end
end
