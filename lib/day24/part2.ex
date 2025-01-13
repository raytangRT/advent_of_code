defmodule Day24.Part2 do
  @re ~r"(?<lhs>\w+) (?<op>\w+) (?<rhs>\w+) -> (?<output>\w+)"

  def run() do
    {map, ops} = read()

    expected_result =
      (get(map, "x") + get(map, "y"))
      |> Integer.to_string(2)

    IO.puts(expected_result |> String.graphemes() |> Enum.join("||"))

    processed_map =
      Day24.Part1.do_work(map, ops)

    actaul_result =
      processed_map
      |> Enum.filter(fn {key, _} ->
        String.starts_with?(key, "z")
      end)
      |> Enum.sort(:desc)
      |> Enum.reduce("", fn {_, v}, r ->
        r <> Integer.to_string(v)
      end)

    IO.puts(actaul_result |> String.graphemes() |> Enum.join("||"))
    graph = graphify(ops)

    expected_result
    |> Integer.parse(2)
    |> elem(0)
    |> Integer.to_string(2)
    |> String.graphemes()
    |> Enum.join("||")
    |> IO.puts()

    Bitwise.bxor(
      expected_result |> Integer.parse(2) |> elem(0),
      actaul_result |> Integer.parse(2) |> elem(0)
    )
    |> Integer.to_string(2)
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce([], fn {v, idx}, result ->
      if v == "0" do
        result
      else
        vertex = "z#{String.pad_leading(Integer.to_string(idx), 2, "0")}"
        expected_bit = if Map.get(processed_map, vertex) == 0, do: 1, else: 0
        [{vertex, expected_bit} | result]
      end
    end)
    |> Enum.map(fn {vertex, expected_bit} ->
      IO.puts("checking #{vertex}, #{expected_bit}")
      {vertex, check(graph, processed_map, vertex, expected_bit)}
    end)
  end

  def get(map, start_with) do
    Map.keys(map)
    |> Enum.filter(&String.starts_with?(&1, start_with))
    |> Enum.sort()
    |> Enum.reduce("", fn key, acc ->
      Integer.to_string(Map.get(map, key)) <> acc
    end)
    |> Integer.parse(2)
    |> elem(0)
  end

  def read() do
    AOC.read_file(:actual, "day24")
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

  def graphify(ops) do
    Enum.reduce(BiMultiMap.keys(ops), Graph.new(), fn {left, right} = key, graph ->
      BiMultiMap.get(ops, key)
      |> Enum.reduce(graph, fn {op, output}, graph ->
        op =
          if op == (&Bitwise.bor/2) do
            "OR"
          else
            if op == (&Bitwise.bxor/2) do
              "XOR"
            else
              "AND"
            end
          end

        graph
        |> Graph.add_edge(left, output, label: op)
        |> Graph.add_edge(right, output, label: op)
      end)
    end)
  end

  def check(graph, map, vertex, expected_bit) when is_bitstring(vertex) do
    if Map.get(map, vertex) == expected_bit or Graph.in_edges(graph, vertex) == [] do
      true
    else
      [left_edge, right_edge] = Graph.in_edges(graph, vertex)
      %Graph.Edge{v1: left_vertex} = left_edge
      %Graph.Edge{v1: right_vertex, label: op} = right_edge

      case op do
        "OR" -> check_or(graph, map, left_vertex, right_vertex, expected_bit)
        "AND" -> check_and(graph, map, left_vertex, right_vertex, expected_bit)
        "XOR" -> check_xor(graph, map, left_vertex, right_vertex, expected_bit)
      end
    end
  end

  def check_or(graph, map, left_vertex, right_vertex, expected_bit) do
    IO.puts("checking_or #{left_vertex} || #{right_vertex}")
    left_value = Map.get(map, left_vertex)
    right_value = Map.get(map, right_vertex)

    cond do
      expected_bit == 1 ->
        IO.puts("\texpected_bit == 1 ->")
        {:either_true, [left_vertex, right_vertex]}

      left_value == 1 and right_value == 1 ->
        IO.puts("\tleft_value == 1 and right_value == 1 ->")
        {:either_false, [left_vertex, right_vertex]}

      left_value == 1 ->
        IO.puts("\tleft_value == 1 ->")
        {:wrong, left_vertex}

      right_value == 1 ->
        IO.puts("\tright_value == 1 ->")
        check(graph, map, right_vertex, 0)
    end
  end

  def check_and(graph, map, left_vertex, right_vertex, expected_bit) do
    IO.puts("checking_and #{left_vertex} || #{right_vertex}")
    left_value = Map.get(map, left_vertex)
    right_value = Map.get(map, right_vertex)

    cond do
      expected_bit == 0 ->
        IO.puts("\texpected_bit == 0 ->")
        {check(graph, map, left_vertex, 0), check(graph, map, right_vertex, 0)}

      left_value == 0 and right_value == 0 ->
        IO.puts("\tleft_value == 0 and right_value == 0 ->")
        {:both_true, [left_vertex, right_vertex]}

      left_value == 0 ->
        IO.puts("\tleft_value == 0 ->")
        {:left_should_be_true, left_vertex}

      right_value == 0 ->
        IO.puts("\tright_value == 0 ->")
        {:right_should_be_true, right_vertex}
    end
  end

  def check_xor(graph, map, left_vertex, right_vertex, expected_bit) do
    IO.puts("checking_xor #{left_vertex} || #{right_vertex}")
    left_value = Map.get(map, left_vertex)
    right_value = Map.get(map, right_vertex)

    cond do
      expected_bit == 1 and left_value == 0 and right_value == 0 ->
        IO.puts("\texpected_bit == 1 and left_value == 0 and right_value == 0 ->")
        {:either_xor_true, [left_vertex, right_vertex]}

      expected_bit == 1 ->
        IO.puts("\texpected_bit == 1 ->")
        {:either_xor_false, [left_vertex, right_vertex]}

      left_value == 1 and right_value == 0 ->
        IO.puts("\tleft_value == 1 and right_value == 0 ->")
        {:either_xor, [{left_vertex, 0}, {right_vertex, 1}]}

      left_value == 0 and right_value == 1 ->
        IO.puts("\tleft_value == 0 and right_value == 1 ->")
        left_is_safe = check(graph, map, left_vertex, 1)
        right_is_safe = check(graph, map, right_vertex, 0)
        IO.inspect(left_is_safe)

        cond do
          not is_boolean(left_is_safe) ->
            {:xor_true, left_vertex, left_is_safe}

          not is_boolean(right_is_safe) ->
            {:xor_false, right_vertex, right_is_safe}

          true ->
            nil
        end
    end
  end
end
