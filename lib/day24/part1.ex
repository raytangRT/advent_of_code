defmodule Day24.Part1 do
  @re ~r"(?<lhs>\w+) (?<op>\w+) (?<rhs>\w+) -> (?<output>\w+)"
  def run(mode \\ :sample) do
    {map, ops} = read(mode)

    do_work(map, ops)
    |> Enum.filter(fn {key, _} ->
      String.starts_with?(key, "z")
    end)
    |> Enum.sort(:desc)
    |> Enum.map(&elem(&1, 1))
    |> Enum.join()
    |> Integer.parse(2)
    |> elem(0)
  end

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day24")
    |> Enum.reduce({%{}, BiMultiMap.new()}, fn line, {map, ops} ->
      cond do
        String.contains?(line, ": ") ->
          [left, right] = String.split(line, ": ")
          {Map.put(map, left, String.to_integer(right)), ops}

        String.contains?(line, " -> ") ->
          %{"lhs" => lhs, "op" => op, "output" => output, "rhs" => rhs} =
            Regex.named_captures(@re, line)

          op =
            case op do
              "AND" -> &Bitwise.band/2
              "XOR" -> &Bitwise.bxor/2
              "OR" -> &Bitwise.bor/2
            end

          ops = BiMultiMap.put(ops, {lhs, rhs}, {op, output})
          {map, ops}

        true ->
          {map, ops}
      end
    end)
  end

  def do_work(map, %BiMultiMap{size: size}) when size == 0 do
    map
  end

  def do_work(map, ops) do
    keys = find_next(map, ops)

    if keys == [] and BiMultiMap.size(ops) > 0 do
      raise "Empty keys while non-empty ops"
    end

    {map, ops} =
      Enum.reduce(keys, {map, ops}, fn {lhs, rhs} = key, {map, ops} ->
        result =
          BiMultiMap.get(ops, key)
          |> Enum.reduce(map, fn {op, output}, result ->
            lhs = Map.get(map, lhs)
            rhs = Map.get(map, rhs)
            r = op.(lhs, rhs)
            Map.put(result, output, r)
          end)

        ops = BiMultiMap.delete_key(ops, key)
        {result, ops}
      end)

    do_work(map, ops)
  end

  def find_next(map, ops) do
    BiMultiMap.keys(ops)
    |> Enum.filter(fn {lhs, rhs} ->
      Map.has_key?(map, lhs) and Map.has_key?(map, rhs)
    end)
  end
end
