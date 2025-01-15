defmodule Year2024.Day8 do
  require Logger
  # 283 -> too low
  # 300 -> too high
  def run(part \\ :part1, mode \\ :sample) do
    file_path = if mode == :actual, do: "day8.txt", else: "day8.sample.txt"

    grid =
      Grid.parse(file_path, fn _, _, value ->
        cond do
          value == "." -> :void
          true -> {:antenna, value}
        end
      end)

    Grid.get_cells(grid, &(&1.value != :void))
    |> Enum.group_by(& &1.value)
    |> Enum.reduce(%{}, fn {{_, antenna_label}, cells}, antinodes ->
      antennas = Enum.map(cells, & &1.point)

      Map.put(
        antinodes,
        {:antinode, antenna_label},
        calculate_antinodes(antennas, part, grid)
      )
    end)
    |> Enum.reduce(grid, fn item, grid ->
      update_grid(item, grid)
    end)
  end

  def update_grid({antinode, antinodes}, grid) do
    antinodes
    |> Enum.reduce(grid, fn point, grid ->
      if not Grid.in_bound?(grid, point) do
        grid
      else
        cell = Grid.get_cell(grid, point)
        cell_value = cell.value

        cond do
          cell_value == :void ->
            Grid.replace(grid, point, [antinode])

          is_tuple(cell_value) and elem(cell_value, 0) == :antenna ->
            {_, antenna_label} = cell_value
            {_, source_antenna_label} = antinode

            if antenna_label != source_antenna_label do
              Grid.replace(grid, point, [antinode, cell_value])
            else
              # antinodes overlapped on the same frequence's antenna
              grid
            end

          is_list(cell_value) ->
            antenna = Enum.find(cell_value, fn v -> elem(v, 0) == :antenna end)

            if is_nil(antenna) or elem(antenna, 1) == elem(antinode, 1) do
              Grid.replace(grid, point, [antinode | cell_value])
            else
              # antinode overlapped on the same frequence's antenna
              grid
            end

          true ->
            grid
        end
      end
    end)
  end

  def print_map(map) do
    Grid.print(map, fn cell ->
      value = cell.value

      concat = fn list ->
        Enum.reduce(list, "", fn a, s -> elem(a, 1) <> s end)
      end

      char =
        cond do
          value == :void -> "."
          is_list(value) -> "\e[35m[#{concat.(value)}]\e[0m"
          is_tuple(value) -> elem(value, 1)
          true -> value
        end

      char <> "||"
    end)
  end

  def count(grid, part \\ :part1) do
    grid
    |> Grid.get_cells(fn cell ->
      cond do
        is_list(cell.value) ->
          true

        part == :part2 ->
          is_tuple(cell.value) and elem(cell.value, 0) == :antenna

        true ->
          false
      end
    end)
    |> Enum.count()
  end

  def calculate_antinodes(nodes, part \\ :part1, grid) do
    nodes = Enum.with_index(nodes)
    antinodes = []

    if part == :part1 do
      for {point1, index1} <- nodes,
          {point2, index2} <- nodes,
          index1 < index2 do
        diff = Point.diff(point1, point2)

        Point.extend(point1, diff) ++ Point.extend(point2, diff) ++ antinodes
      end
    else
      for {point1, index1} <- nodes,
          {point2, index2} <- nodes,
          index1 < index2 do
        diff = Point.diff(point1, point2)

        extend_points(point1, diff, grid, []) ++
          extend_points(point2, diff, grid, []) ++ antinodes
      end
    end
    |> List.flatten()
    |> Enum.uniq()
  end

  def extend_points(point, {delta_x, delta_y}, grid, points, increment \\ 1) do
    extended_points = Point.extend(point, {delta_x * increment, delta_y * increment})

    if(Enum.all?(extended_points, &(not Grid.in_bound?(grid, &1)))) do
      points
    else
      extend_points(point, {delta_x, delta_y}, grid, extended_points ++ points, increment + 1)
    end
  end
end
