defmodule Day19.Part2 do
  require Logger

  def run(mode \\ :sample) do
    {towels, patterns} = read(mode)

    max_length = if mode == :actual, do: 8, else: 3
    total_patterns = length(patterns)

    cache =
      patterns
      |> Enum.with_index()
      |> Enum.reduce(towels, fn {pattern, idx}, towels ->
        ProgressBar.render(idx, total_patterns, suffix: :count)
        check_resursivly(pattern, max_length, towels)
      end)

    Enum.map(patterns, fn pattern ->
      build(pattern, cache)
      |> Enum.map(&flatten/1)
    end)
  end

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day19")
    |> Enum.reject(&(&1 == ""))
    |> Enum.reduce({%{}, []}, fn line, {towels, patterns} ->
      if Enum.empty?(towels) do
        towels =
          String.split(line, ", ")
          |> Enum.map(&{&1, [{&1}]})
          |> Map.new()

        {towels, patterns}
      else
        {towels, [line | patterns]}
      end
    end)
  end

  def combine_inner(head, [h | _r] = list) when is_list(h) do
    Enum.map(list, fn i ->
      combine(head, i)
    end)
  end

  def combine_inner(head, [h | _r] = list) when not is_list(h) do
    [head] ++ list
  end

  def combine(head, [h | _r] = rest) when is_list(h) do
    result =
      ListUtils.cross_join([head], rest)
      |> Enum.map(fn {l, r} ->
        combine_inner(l, r)
      end)

    IO.puts("combining from #{inspect(head)} and #{inspect(rest)} = #{inspect(result)}")

    if length(result) == 1 do
      result |> hd()
    else
      result
    end
  end

  def combine(head, rest) do
    result = [head] ++ rest
    IO.puts("combining from #{inspect(head)} | #{inspect(rest)} = #{inspect(result)}")
    result
  end

  def flatten({item1}) when is_bitstring(item1), do: [item1]

  def flatten({item1, item2}) when is_bitstring(item1) and is_bitstring(item2), do: [item1, item2]

  def flatten({item1, item2}) when is_bitstring(item1) and is_list(item2) do
    Enum.map(flatten(item2), fn item ->
      combine(item1, item)
    end)
  end

  def flatten(list) when is_list(list) do
    Enum.map(list, fn item ->
      flatten(item)
    end)
  end

  def build({l} = pattern, _cache) when is_tuple(pattern) and tuple_size(pattern) == 1 do
    l
  end

  def build({l, r} = pattern, cache) when is_tuple(pattern) and tuple_size(pattern) == 2 do
    l_list =
      Map.get(cache, l)
      |> Enum.map(&build(&1, cache))

    r_list =
      Map.get(cache, r)
      |> Enum.map(&build(&1, cache))

    ListUtils.cross_join(l_list, r_list)
  end

  def build(pattern, cache) when is_bitstring(pattern) do
    Map.get(cache, pattern)
    |> AOC.if_nil([])
    |> Enum.reduce([], fn item, list ->
      r = build(item, cache)
      list ++ r
    end)
  end

  def pattern_exists?(pattern, idx, cache) do
    composition = String.split_at(pattern, idx)

    Map.has_key?(cache, pattern) and
      case Map.get(cache, pattern) do
        value -> value == :basic or composition in value
      end
  end

  def check_resursivly(pattern, _max_length, cache) when pattern == "" do
    cache
  end

  def check_resursivly(pattern, max_length, cache) do
    1..min(max_length, String.length(pattern))
    |> Enum.reduce(cache, fn idx, cache ->
      {head, rest} = String.split_at(pattern, idx)

      if Map.has_key?(cache, head) and not pattern_exists?(pattern, idx, cache) do
        new_cache = check_resursivly(rest, max_length, cache)

        if Map.has_key?(new_cache, rest) do
          Map.update(new_cache, pattern, [{head, rest}], &[{head, rest} | &1])
        else
          new_cache
        end
      else
        cache
      end
    end)
  end
end
