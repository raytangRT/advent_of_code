defmodule Day9.Part2 do
  require Logger

  # 8780071174064 too high
  # 115897298587 too low
  # 6345453697710 not correct
  # 6377400869326
  def run(mode \\ :sample) do
    read(mode)
    |> fold()
    |> calculate_check_sum()
  end

  def calculate_check_sum(list) do
    list
    |> Enum.map(fn {{start, end_location}, file_id} ->
      Enum.map(start..end_location, fn i -> i * file_id end)
      |> Enum.sum()
    end)
    |> Enum.sum()
  end

  def read(mode \\ :sample) do
    file_path = if mode == :actual, do: "day9.txt", else: "day9.sample.txt"

    AOC.read_file(file_path)
    |> Enum.map(&String.graphemes/1)
    |> hd
    |> Enum.with_index()
    |> Enum.map(fn {c, idx} ->
      width = String.to_integer(c)

      cond do
        rem(idx, 2) == 0 ->
          {:file, div(idx, 2), width}

        width > 0 ->
          {:empty_space, 0, width}

        true ->
          nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.map_reduce(0, fn item, idx ->
      width = elem(item, 2)
      {{idx, item}, idx + width}
    end)
    |> elem(0)
  end

  def fold(memory_blocks) do
    end_location = Enum.sort(memory_blocks, :desc) |> hd |> elem(0)

    files_to_fold =
      Enum.reject(memory_blocks, fn {_, {type, _, _}} -> type == :empty_space end)
      # Sort by file_id in descending order
      |> Enum.sort_by(fn {_, {:file, file_id, _}} -> -file_id end)

    empty_blocks =
      Enum.reject(memory_blocks, fn {_, {type, _, _}} -> type == :files end)
      |> BiMultiMap.new()

    Enum.reduce(files_to_fold, {%{}, empty_blocks}, fn {file_location_start,
                                                        {:file, file_id, file_width}},
                                                       {map, empty_blocks} ->
      ProgressBar.render(end_location - file_location_start, end_location)
      empty_slot = look_for_empty_space(empty_blocks, file_location_start, file_width)

      if is_nil(empty_slot) do
        {Map.put(map, file_location_start, {:file, file_id, file_width}), empty_blocks}
      else
        {slot_starting_idx, slot} = empty_slot
        empty_blocks = BiMultiMap.delete(empty_blocks, slot_starting_idx, slot)

        map = Map.put(map, slot_starting_idx, {:file, file_id, file_width})
        slot_width = elem(slot, 2)

        empty_blocks =
          if slot_width > file_width do
            BiMultiMap.put(
              empty_blocks,
              slot_starting_idx + file_width,
              {:empty_space, 0, slot_width - file_width}
            )
          else
            empty_blocks
          end

        {map, empty_blocks}
      end
    end)
    |> elem(0)
    |> Enum.sort()
    |> Enum.map(fn {idx, {_, file_id, width}} ->
      {{idx, idx + width - 1}, file_id}
    end)
  end

  def look_for_empty_space(empty_blocks, empty_space_before_idx, size) do
    max_slot_size = BiMultiMap.values(empty_blocks) |> Enum.map(&elem(&1, 2)) |> Enum.max()

    if size > max_slot_size do
      nil
    else
      slot_size_to_search = {:empty_space, 0, size}

      empty_spaces =
        BiMultiMap.get_keys(empty_blocks, slot_size_to_search)
        |> Enum.reject(&(&1 > empty_space_before_idx))
        |> Enum.sort()

      if length(empty_spaces) == 0 do
        look_for_empty_space(empty_blocks, empty_space_before_idx, size + 1)
      else
        {hd(empty_spaces), slot_size_to_search}
      end
    end
  end
end
