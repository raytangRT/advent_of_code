defmodule Day9 do
  require Logger
  # 10691786548005 too hgih
  # 8780071174064 too high
  # 115897298587 too low
  def run(mode \\ :sample) do
    read(mode)
    |> fold()
    |> Enum.map(&elem(&1, 1))
    |> Enum.reject(&(&1 == :empty_space))
    |> calculate_check_sum()
  end

  def read(mode \\ :sample) do
    file_path = if mode == :actual, do: "day9.txt", else: "day9.sample.txt"

    AOC.read_file(file_path)
    |> Enum.map(&String.graphemes/1)
    |> Enum.at(0)
    |> Enum.with_index()
    |> Enum.reduce([], fn {c, idx}, l ->
      if rem(idx, 2) == 0 do
        file_id = div(idx, 2) |> Integer.to_string()
        List.duplicate(file_id, String.to_integer(c))
      else
        List.duplicate(:empty_space, String.to_integer(c))
      end
      |> Enum.concat(l)
    end)
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.map(fn {v, idx} -> {idx, v} end)
    |> Map.new()
  end

  def calculate_check_sum(input) do
    input
    |> Enum.with_index()
    |> Enum.reduce(0, fn {c, idx}, acc ->
      if c == "." do
        0
      else
        String.to_integer(c)
      end *
        idx + acc
    end)
  end

  def fold(input_map) do
    fold_recur(input_map, 0, Enum.count(input_map) - 1)
    |> Map.to_list()
    |> Enum.sort()
  end

  def fold_recur(map, left, right) do
    if left == right or left > Enum.count(map) do
      map
    else
      lhs = Map.get(map, left)
      rhs = Map.get(map, right)

      cond do
        lhs == :empty_space and rhs != :empty_space ->
          map = MapUtils.swap_value(map, left, right)
          fold_recur(map, left + 1, right - 1)

        lhs == :empty_space and rhs == :empty_space ->
          fold_recur(map, left, right - 1)

        lhs != :empty_space and rhs == :empty_space ->
          fold_recur(map, left + 1, right - 1)

        lhs != :empty_space and rhs != :empty_space ->
          fold_recur(map, left + 1, right)
      end
    end
  end

  def fold_part2(map) do
    empty_spaces =
      Enum.filter(map, fn {_, value} -> elem(value, 0) == :empty_space end)
      |> Enum.group_by(fn {_, {:empty_space, count}} -> count end, fn {key, _} -> key end)

    Enum.reject(map, fn {_, value} -> elem(value, 0) == :empty_space end)
    |> Enum.sort()
    |> Enum.reverse()
    |> Enum.reduce({map, empty_spaces}, fn {key, {_file_id, width}}, {map, empty_spaces} ->
      slot = look_for_empty_space(empty_spaces, width)

      if is_nil(slot) do
        {map, empty_spaces}
      else
        {slot_width, {slot_start, slot_end}} = slot
        {file_spec, map} = Map.pop(map, key)
        {_, map} = Map.pop(map, {slot_start, slot_end})

        if slot_width > width do
          new_slot_end = slot_start + width - 1
          new_file_spec_location = {slot_start, new_slot_end}
          new_slot_location = {new_slot_end, new_slot_end + slot_width - width}
          new_slot_spec = {:empty_space, slot_width - width}

          map =
            map
            |> Map.put(new_file_spec_location, file_spec)
            |> Map.put(new_slot_location, new_slot_spec)
            |> Map.put(key, {:empty_space, width})

          empty_spaces =
            Map.update!(
              empty_spaces,
              slot_width - width,
              fn l ->
                [new_slot_location | l] |> Enum.sort()
              end
            )
            |> Map.update!(slot_width, &tl/1)

          {map, empty_spaces}
        else
          map =
            map
            |> Map.put({slot_start, slot_end}, file_spec)
            |> Map.put(key, {:empty_space, width})

          empty_spaces = Map.update!(empty_spaces, slot_width, &tl/1)
          {map, empty_spaces}
        end
      end
    end)
  end

  def look_for_empty_space(empty_spaces, size) do
    if Enum.max_by(empty_spaces, &elem(&1, 0)) |> elem(0) < size do
      nil
    else
      spaces = Map.get(empty_spaces, size)

      if spaces == nil or length(spaces) == 0 do
        look_for_empty_space(empty_spaces, size + 1)
      else
        {size, hd(spaces)}
      end
    end
  end
end
