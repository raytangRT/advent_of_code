defmodule Year2024.Day21.ArrowPad do
  @arrow_pad [
               {:up, [:press, :down]},
               {:press, [:up, :right]},
               {:left, [:down]},
               {:down, [:left, :up, :right]},
               {:right, [:press, :down]}
             ]
             |> Enum.reduce(Graph.new(), fn {from, to_list}, graph ->
               Enum.reduce(to_list, graph, fn to, graph -> Graph.add_edge(graph, from, to) end)
             end)
  @arrow_keys [:up, :down, :left, :right, :press]
  @arrow_keys_combos ListUtils.cross_join(@arrow_keys, @arrow_keys)

  @arrow_keys_map [
                    {:up, {1, 0}},
                    {:press, {2, 0}},
                    {:left, {0, 1}},
                    {:down, {1, 1}},
                    {:right, {2, 1}}
                  ]
                  |> Enum.map(fn {i, p} -> {i, Point.new(p)} end)
                  |> BiMap.new()

  defp get_path(from, to) when from == to, do: []

  defp get_path(from, to) do
    paths = Graph.Pathfinding.all(@arrow_pad, from, to)

    min_length =
      Enum.min_by(paths, &length/1)

    directional_paths =
      Enum.reject(paths, &(length(&1) > min_length))
      |> Enum.map(fn path ->
        Enum.chunk_every(path, 2, 1, :discard)
        |> Enum.map(fn [from, to] ->
          from = BiMap.get(@arrow_keys_map, from)
          to = BiMap.get(@arrow_keys_map, to)
          Point.relative_to(from, to)
        end)
      end)

    min_score =
      Enum.min_by(directional_paths, &score_path/1)

    Enum.filter(directional_paths, &(score_path(&1) <= min_score))
  end

  def score_path(path) do
    Enum.chunk_every(path, 2, 1, :discard)
    |> Enum.reduce(0, fn [left, right], score ->
      if left == right, do: score, else: score + 100
    end)
  end

  def all_paths() do
    Enum.map(@arrow_keys_combos, fn {from, to} ->
      {{from, to}, get_path(from, to)}
    end)
    |> Map.new()
  end

  def solve(path) do
    starting = BiMap.get(@arrow_keys_map, :press)

    Enum.reduce(path, {[], starting}, fn step, {result, current} ->
      if step == :press do
        IO.inspect(current)
        {[BiMap.get_key(@arrow_keys_map, current) | result], current}
      else
        new_current =
          case step do
            :up -> Point.move_up(current)
            :down -> Point.move_down(current)
            :left -> Point.move_left(current)
            :right -> Point.move_right(current)
          end

        IO.puts("#{inspect(current)} -> #{inspect(new_current)} || #{inspect(step)}")
        {result, new_current}
      end
    end)
    |> elem(0)
    |> Enum.reverse()
  end
end
