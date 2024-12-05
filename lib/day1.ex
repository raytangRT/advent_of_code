defmodule Day1 do
  require Logger
  require AOC

  @delimiator "   "
  @input_path "day1.txt"

  def run() do
    AOC.read_file(@input_path)
    |> Stream.map(&String.split(&1, @delimiator))
    |> Enum.reduce({[], []}, fn [left, right], {list1, list2} ->
      {[String.to_integer(left) | list1], [String.to_integer(right) | list2]}
    end)
    |> then(fn {l1, l2} -> [Enum.sort(l1), Enum.sort(l2)] end)
    |> List.zip()
    |> Enum.reduce(0, fn {l, r}, acc -> acc + abs(l - r) end)
  end

  def run2_attemp1 do
    AOC.read_file(@input_path)
    |> Stream.map(&String.split(&1, @delimiator))
    |> Enum.reduce({[], %{}}, fn [left, right], {list, map} ->
      left_num = String.to_integer(left)
      right_num = String.to_integer(right)
      map = Map.update(map, right_num, 1, &(&1 + 1))
      {[left_num | list], map}
    end)
    |> then(fn {l, m} ->
      l
      |> Enum.reduce(0, fn item, result ->
        result + item * Map.get(m, item, 0)
      end)
    end)
  end

  def run2_attemp2 do
    AOC.read_file(@input_path)
    |> Stream.map(&String.split(&1, @delimiator))
    |> Enum.reduce({[], []}, fn [left, right], {list1, list2} ->
      {[String.to_integer(left) | list1], [String.to_integer(right) | list2]}
    end)
    |> then(fn {l1, l2} ->
      f = Enum.frequencies(l2)

      Enum.reduce(l1, 0, fn item, result ->
        result + item * Map.get(f, item, 0)
      end)
    end)
  end

  def run2_attemp3 do
    AOC.read_file(@input_path)
    |> Stream.map(&String.split(&1, @delimiator))
    |> Enum.reduce({%{}, %{}}, fn [left, right], {map1, map2} ->
      map1 = Map.update(map1, left, 1, &(&1 + 1))
      map2 = Map.update(map2, right, 1, &(&1 + 1))
      {map1, map2}
    end)
    |> then(fn {map1, map2} ->
      Map.keys(map1)
      |> Enum.reduce(0, fn key, acc ->
        acc + Map.get(map1, key, 0) * String.to_integer(key) * Map.get(map2, key, 0)
      end)
    end)
  end
end
