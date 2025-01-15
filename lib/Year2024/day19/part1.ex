defmodule Year2024.Day19.Part1 do
  # 314 -> too low
  def run(mode \\ :sample) do
    {towels, patterns} = read(mode)

    max_length = Map.keys(towels) |> Enum.max()

    result =
      patterns
      |> Enum.with_index()
      |> Enum.map(fn {pattern, idx} ->
        ProgressBar.render(idx, length(patterns), suffix: :count)
        check_resursive(pattern, towels, max_length)
      end)
      |> Enum.count(&(&1 == :ok))

    IO.puts("\r\nresult = #{result}")
  end

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day19")
    |> Enum.reject(&(&1 == ""))
    |> Enum.reduce({%{}, []}, fn line, {towels, patterns} ->
      if Enum.empty?(towels) do
        towels =
          String.split(line, ", ")
          |> Enum.group_by(&String.length/1, &String.reverse/1)

        {towels, patterns}
      else
        {towels, [line |> String.reverse() | patterns]}
      end
    end)
  end

  def check_resursive(pattern, _towels, _max_length) when pattern == "" do
    :ok
  end

  def check_resursive(pattern, towels, max_length) do
    for idx <- 1..max_length do
      {head, rest} = String.split_at(pattern, idx)

      if head in Map.get(towels, idx) do
        rest
      end
    end
    |> Enum.reject(&is_nil/1)
    |> Enum.reduce_while(:failed, fn pattern, _ ->
      if :ok == check_resursive(pattern, towels, max_length) do
        {:halt, :ok}
      else
        {:cont, :failed}
      end
    end)
  end
end
