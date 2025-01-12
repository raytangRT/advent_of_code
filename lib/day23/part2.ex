defmodule Day23.Part2 do
  import Day23.Part1

  def run(mode \\ :sample) do
    graph = read(mode)

    map =
      Graph.vertices(graph)
      |> Enum.map(fn vertex ->
        step(graph, vertex, 3, vertex, [])
        |> ListUtils.flatten()
        |> Enum.map(&Enum.sort/1)
        |> Enum.uniq()
      end)
      |> ListUtils.flatten()
      |> Enum.reduce(Map.new(), fn [edge1, edge2, edge3] = edges, map ->
        graph =
          cond do
            Map.has_key?(map, edge1) -> Map.get(map, edge1)
            Map.has_key?(map, edge2) -> Map.get(map, edge2)
            Map.has_key?(map, edge3) -> Map.get(map, edge3)
            true -> Graph.new()
          end
          |> add_edges(edges)

        map
        |> Map.put(edge1, graph)
        |> Map.put(edge2, graph)
        |> Map.put(edge3, graph)
      end)

    map
    |> Enum.reduce(map, fn {key, graph}, map ->
      if not is_valid?(graph) do
        Map.delete(map, key)
      else
        map
      end
    end)
    |> Enum.map(fn {_, graph} ->
      Graph.vertices(graph)
    end)
    |> Enum.uniq()
    |> Enum.max_by(&length/1)
    |> Enum.sort()
    |> Enum.join(",")
  end

  def add_edges(graph, edges) do
    (edges ++ [hd(edges)])
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.reduce(graph, fn [left, right], graph ->
      graph
      |> Graph.add_edge(left, right)
      |> Graph.add_edge(right, left)
    end)
  end

  def is_valid?(graph) do
    r =
      Graph.vertices(graph)
      |> Enum.uniq_by(fn v -> Graph.neighbors(graph, v) |> length() end)
      |> length()

    r == 1
  end
end
