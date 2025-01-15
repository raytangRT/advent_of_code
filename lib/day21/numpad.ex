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
    [head | rest] = paths

    min_length =
      Enum.reduce(rest, length(head), fn path, min_length ->
        min(min_length, length(path))
      end)

    [head | rest] =
      directional_paths =
      Enum.filter(paths, fn path ->
        length(path) <= min_length
      end)
      |> Enum.map(fn path ->
        Enum.chunk_every(path, 2, 1, :discard)
        |> Enum.map(fn [from, to] ->
          from = Map.get(@numpad_map, from)
          to = Map.get(@numpad_map, to)
          Point.relative_to(from, to)
        end)
      end)

    min_score =
      Enum.reduce(rest, score_path(head), fn path, score ->
        min(score, score_path(path))
      end)

    directional_paths
    # directional_paths |> Enum.filter(fn path -> score_path(path) == min_score end)
  end

  def score_path(path) do
    Enum.chunk_every(path, 2, 1, :discard)
    |> Enum.reduce(0, fn [left, right], score ->
      if left == right, do: score, else: score + 100
    end)
  end

  def all_paths() do
    Enum.map(@numpad_combos, fn {from, to} ->
      {{from, to}, get_numpad_paths(from, to)}
    end)
    |> Map.new()
  end
end
