defmodule Day7 do
  require Logger

  def run(mode \\ :sample) do
    file_name = if mode == :actual, do: "day7.txt", else: "day7.sample.txt"

    AOC.read_file(file_name)
    |> Enum.map(fn line ->
      line
      |> String.split(":")
      |> then(fn [left | [right | _]] ->
        {left |> String.to_integer(),
         right |> String.trim_leading() |> String.split(" ") |> Enum.map(&String.to_integer/1)}
      end)
    end)
    |> Enum.filter(&is_valid?(elem(&1, 0), elem(&1, 1)))
    |> Enum.map(&elem(&1, 0))
    |> Enum.sum()
  end

  def is_valid?(expected_value, numbers, label \\ :start) do
    # Logger.info("[#{label}||#{expected_value} = #{AOC.list(numbers)}")

    cond do
      is_integer(numbers) ->
        numbers == expected_value

      true ->
        is_valid?(expected_value, next(numbers, :add), :add) or
          is_valid?(expected_value, next(numbers, :mul), :mul) or
          is_valid?(expected_value, next(numbers, :concat), :concat)
    end
  end

  def next([left | [right | tail]], method) do
    next =
      cond do
        method == :add ->
          left + right

        method == :mul ->
          left * right

        method == :concat ->
          String.to_integer(Integer.to_string(left) <> Integer.to_string(right))

        true ->
          raise("unhandled")
      end

    if length(tail) == 0 do
      next
    else
      [next | tail]
    end
  end
end
