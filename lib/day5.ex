defmodule Day5 do
  require Logger

  # 4027 too low
  def run(mode \\ :sample) do
    rules = load_rules(mode)

    file_name = if mode == :actual, do: "day5.queue.txt", else: "day5.sample.queue.txt"

    AOC.read_file(file_name)
    |> Enum.map(&AOC.parse/1)
    |> Enum.reject(&is_valid(&1, rules))
    |> Enum.map(&fix_pages(&1, rules))
    |> Enum.map(&mid/1)
    |> Enum.sum()
  end

  def load_rules(mode \\ :sample) do
    file_name = if mode == :actual, do: "day5.txt", else: "day5.sample.txt"

    AOC.read_file(file_name)
    |> Enum.map(fn line ->
      line
      |> String.split("|")
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
    |> Enum.reduce({%{}, MapSet.new()}, fn {left, right}, {m, l} ->
      m =
        Map.update(m, left, [right], fn value ->
          [right | value]
        end)

      l = MapSet.put(l, left) |> MapSet.put(right)
      {m, l}
    end)
    |> then(fn {m, l} ->
      MapSet.difference(l, MapSet.new(Map.keys(m)))
      |> Enum.reduce(m, fn item, m ->
        Map.put(m, item, [])
      end)
    end)
    |> graphifiy()
  end

  def graphifiy(rules) do
    Map.to_list(rules)
    |> Enum.map(fn {key, values} ->
      Enum.map(values, &Graph.Edge.new(key, &1))
    end)
    |> Enum.reduce(Graph.new(), fn edges, graph ->
      Graph.add_edges(graph, edges)
    end)
  end

  def is_valid(pages, graph) do
    if length(pages) <= 1 do
      true
    else
      [left | [right | tail]] = pages
      shortest_path = Graph.get_shortest_path(graph, left, right)

      if is_nil(shortest_path) or length(shortest_path) != 2 do
        false
      else
        is_valid([right | tail], graph)
      end
    end
  end

  def mid(list) do
    Enum.at(list, div(length(list), 2))
  end

  def fix_pages(pages, graph, retry_count \\ 100) do
    cond do
      is_valid(pages, graph) ->
        pages

      retry_count == 0 ->
        pages

      true ->
        fixed_pages = fix_pages_recur(pages, graph, []) |> Enum.reverse()
        fix_pages(fixed_pages, graph, retry_count - 1)
    end
  end

  def fix_pages_recur(pages, graph, list) do
    if length(pages) <= 1 do
      pages ++ list
    else
      [left | [right | tail]] = pages
      shortest_path = Graph.get_shortest_path(graph, left, right)

      if not is_nil(shortest_path) and length(shortest_path) == 2 do
        fix_pages_recur([right | tail], graph, [left | list])
      else
        fix_pages_recur([left | tail], graph, [right | list])
      end
    end
  end
end
