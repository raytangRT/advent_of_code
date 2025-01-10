defmodule Day21.Numpad do
  @numpad [
            {"7", ["4", "8"]},
            {"8", ["7", "5", "9"]},
            {"9", ["6", "8"]},
            {"4", ["1", "7", "5"]},
            {"5", ["2", "4", "6", "8"]},
            {"6", ["3", "5", "9"]},
            {"1", ["2", "4"]},
            {"2", ["0", "1", "3", "5"]},
            {"3", ["2", "6", "A"]},
            {"0", ["2", "A"]},
            {"A", ["0", "3"]}
          ]
          |> Enum.reduce(Graph.new(), fn {from, to_list}, graph ->
            Enum.reduce(to_list, graph, fn to, graph ->
              Graph.add_edge(graph, from, to)
            end)
          end)
  @numpad_keys ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A"]
  @numpad_combos ListUtils.cross_join(@numpad_keys, @numpad_keys)

  @numpad_map [
                {"7", {0, 0}},
                {"8", {1, 0}},
                {"9", {2, 0}},
                {"4", {0, 1}},
                {"5", {1, 1}},
                {"6", {2, 1}},
                {"1", {0, 2}},
                {"2", {1, 2}},
                {"3", {2, 2}},
                {"0", {1, 3}},
                {"A", {2, 3}}
              ]
              |> Enum.map(fn {i, p} -> {i, Point.new(p)} end)
              |> Map.new()

  def get_numpad_paths(from, to) when from == to, do: []

  def get_numpad_paths(from, to) do
    paths = Graph.Pathfinding.all(@numpad, from, to)

    min_length =
      Enum.reduce(paths, :inf, fn path, min_length ->
        if length(path) < min_length do
          length(path)
        else
          min_length
        end
      end)

    Enum.reject(paths, &(length(&1) > min_length))
    |> Enum.map(fn path ->
      Enum.chunk_every(path, 2, 1, :discard)
      |> Enum.map(fn [from, to] ->
        from = Map.get(@numpad_map, from)
        to = Map.get(@numpad_map, to)
        Point.relative_to(from, to)
      end)
    end)
  end

  def all_paths() do
    Enum.map(@numpad_combos, fn {from, to} ->
      {{from, to}, get_numpad_paths(from, to)}
    end)
    |> Map.new()
  end
end
