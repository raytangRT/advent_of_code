defmodule Year2024.Day23.Part1 do
  def run(mode \\ :sample) do
    graph = read(mode)

    Graph.vertices(graph)
    |> Enum.filter(&String.starts_with?(&1, "t"))
    |> Enum.map(fn vertex ->
      step(graph, vertex, 3, vertex, [])
      |> ListUtils.flatten()
      |> Enum.map(&Enum.sort/1)
      |> Enum.uniq()
    end)
    |> ListUtils.flatten()
    |> Enum.count()
  end

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day23")
    |> Enum.map(&String.split(&1, "-"))
    |> Enum.reduce(Graph.new(), fn [left, right], result ->
      Graph.add_edge(result, left, right)
      |> Graph.add_edge(right, left)
    end)
  end

  def _walk(graph, num_of_node) do
    vertices = Graph.vertices(graph)

    vertices
    |> Enum.filter(&String.starts_with?(&1, "t"))
    |> Enum.with_index()
    |> Enum.map(fn {v, idx} ->
      ProgressBar.render(idx, length(vertices), suffix: :count)

      Graph.Pathfinding.all(graph, v, v)
      |> Enum.filter(&(length(&1) == num_of_node + 1))
    end)
    |> ListUtils.flatten()
    |> Enum.map(&Enum.sort/1)
    |> Enum.uniq()
  end

  def step(graph, current, step_count, target, result \\ [])

  def step(_graph, current, step_count, target, result)
      when step_count == 0 and current == target do
    result
  end

  def step(_graph, current, step_count, target, _result)
      when step_count == 0 and current != target,
      do: []

  def step(graph, current, step_count, target, result) do
    result = [current | result]

    Graph.neighbors(graph, current)
    |> Enum.map(fn neighbor ->
      step(graph, neighbor, step_count - 1, target, result)
    end)
  end
end
