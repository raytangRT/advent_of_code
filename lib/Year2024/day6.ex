defmodule Year2024.Day6 do
  require Logger

  def run(mode \\ :sample) do
    map = build_map(mode)
    no_of_location = length(Map.keys(map))
    side_length = trunc(no_of_location ** 0.5)

    Enum.map(0..(side_length - 1), fn x ->
      Enum.map(0..(side_length - 1), fn y ->
        Task.async(fn ->
          result = walk(map, {x, y})
          Logger.info("completed ... (#{x}, #{y})")
          result
        end)
      end)
      |> Task.await_many(100_000)
      |> Enum.count(&(elem(&1, 0) == :cyclic_detected))
    end)
    |> Enum.sum()

    # map = Map.put(map, {3, 6}, :obstruction)
    # walk(map)
    # |> elem(0) ==
    #   :cyclic_detected
  end

  def walk(map, {x, y}) do
    Logger.info("checking ... (#{x}, #{y})")
    target = locate(map, x, y)

    cond do
      target == :void ->
        map = Map.put(map, {x, y}, :obstruction)
        travel(map, first(map, :north), Graph.new(), Map.new())

      target in [:north, :obstruction] ->
        {:done}

      true ->
        {:done}
    end
  end

  def build_map(mode \\ :sample) do
    file_path = if mode == :actual, do: "day6.txt", else: "day6.sample.txt"

    AOC.read_file(file_path)
    |> Enum.with_index()
    |> Enum.map(fn {line, y} ->
      String.graphemes(line)
      |> Enum.with_index()
      |> Enum.map(fn {char, x} ->
        type =
          cond do
            char == "#" -> :obstruction
            char == "^" -> :north
            true -> :void
          end

        {x, y, type}
      end)
    end)
    |> List.flatten()
    |> Enum.reduce(%{}, fn {x, y, type}, map ->
      Map.put(map, {x, y}, type)
    end)
  end

  def first(map, type) do
    Map.to_list(map)
    |> Enum.filter(&(elem(&1, 1) == type))
    |> Enum.at(0)
  end

  def locate(map, x, y) do
    Map.get(map, {x, y})
  end

  def turn(direction) do
    cond do
      direction == :north -> :east
      direction == :east -> :south
      direction == :south -> :west
      direction == :west -> :north
      true -> raise("unknown direction, #{inspect(direction)}")
    end
  end

  def step({x, y}, direction) do
    {delta_x, delta_y} =
      cond do
        direction == :north -> {0, -1}
        direction == :east -> {1, 0}
        direction == :south -> {0, 1}
        direction == :west -> {-1, 0}
        true -> raise("unknown direction, #{inspect(direction)}")
      end

    {x + delta_x, y + delta_y}
  end

  def contains_loop?(loops) do
    if length(Map.keys(loops)) <= 0 do
      false
    else
      Map.keys(loops)
      |> Enum.map(fn key ->
        length(Map.get(loops, key))
      end)
      |> Enum.max() >= 10
    end
  end

  def travel(map, current, graph, loops) do
    cond do
      is_nil(current) ->
        {:done, map, loops}

      contains_loop?(loops) ->
        {:cyclic_detected, map, loops}

      true ->
        {{x, y}, type} = current
        # check next step's tile
        # if it is an :obstruction, turn
        # if it is a void, step in and travel
        {next_x, next_y} = step({x, y}, type)
        next_tile = locate(map, next_x, next_y)

        cond do
          is_nil(next_tile) ->
            {:done, map, loops}

          next_tile == :obstruction ->
            map = Map.put(map, {x, y}, turn(type))
            travel(map, {{x, y}, locate(map, x, y)}, graph, loops)

          true ->
            map = Map.put(map, {next_x, next_y}, type)
            graph = Graph.add_edge(graph, {x, y}, {next_x, next_y})

            {graph, loops} =
              cond do
                Graph.is_cyclic?(graph) ->
                  loops =
                    Map.update(loops, {next_x, next_y}, [graph], fn value ->
                      [graph | value]
                    end)

                  {Graph.new(), loops}

                true ->
                  {graph, loops}
              end

            travel(map, {{next_x, next_y}, type}, graph, loops)
        end
    end
  end
end
