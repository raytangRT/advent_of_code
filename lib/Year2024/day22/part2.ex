defmodule Year2024.Day22.Part2 do
  import Year2024.Day22.Part1
  @cache :day22_part2

  def run(mode \\ :sample) do
    input = if mode == :actual, do: read(mode), else: [1, 2, 3, 2024]
    Cachex.start(@cache)

    try do
      [head | rest] = input
      seq = seq(head, 2000)

      rest
      |> Enum.reduce(seq, fn input, result ->
        seq(input, 2000)
        |> Enum.reduce(result, fn {sequence, score}, seq ->
          Map.update(seq, sequence, score, &(&1 + score))
        end)
      end)
      |> Map.values()
      |> Enum.sort(:desc)
      |> hd
    after
      Process.whereis(@cache) |> Process.exit(:normal)
    end
  end

  def seq(input, round, cache_name \\ @cache) do
    Enum.reduce(0..(round - 1), {[input |> Integer.mod(10)], input}, fn _, {seq, current} ->
      next_secret = cal_next_secret(current, cache_name)

      {[Integer.mod(next_secret, 10) | seq], next_secret}
    end)
    |> elem(0)
    |> Enum.reverse()
    |> Enum.chunk_every(5, 1, :discard)
    |> Enum.map(fn list ->
      score = List.last(list)

      seq =
        Enum.chunk_every(list, 2, 1, :discard) |> Enum.map(fn [left, right] -> right - left end)

      {seq, score}
    end)
    |> Enum.reduce(%{}, fn {seq, score}, result ->
      if not Map.has_key?(result, seq) do
        Map.put(result, seq, score)
      else
        result
      end
    end)
  end
end
