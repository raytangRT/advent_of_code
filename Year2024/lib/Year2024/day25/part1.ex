defmodule Year2024.Day25.Part1 do
  def run(mode \\ :sample) do
    %{
      :lock => locks,
      :key => keys
    } = read(mode)

    ListUtils.cross_join(locks, keys)
    |> Enum.filter(fn {{:lock, lock}, {:key, key}} ->
      lock_digits =
        Integer.digits(lock)
        |> pad_zeros(5)

      key_digits =
        Integer.digits(key)
        |> pad_zeros(5)

      verify_key_lock(lock_digits, key_digits)
    end)
    |> length()
  end

  def pad_zeros(list, length) do
    if length(list) < length do
      List.duplicate(0, length - length(list))
    else
      []
    end ++
      list
  end

  def verify_key_lock(lock_digits, key_digits) when lock_digits == [] and key_digits == [],
    do: true

  def verify_key_lock([head_lock | rest_lock], [head_key | rest_key]) do
    if verify_digit(head_lock, head_key) do
      verify_key_lock(rest_lock, rest_key)
    else
      false
    end
  end

  defp verify_digit(lock_digit, key_digit) do
    lock_digit + key_digit <= 5
  end

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day25")
    |> Enum.chunk_every(8)
    |> Enum.map(fn input ->
      input =
        if List.last(input) == "" do
          List.pop_at(input, -1) |> elem(1)
        else
          input
        end

      [type | _] = input
      last_row = List.last(input)

      value =
        Enum.map(input, fn v ->
          v
          |> String.replace("#", "1")
          |> String.replace(".", "0")
          |> Integer.parse()
          |> elem(0)
        end)
        |> Enum.sum()

      value = value - 11111

      cond do
        type == "#####" and last_row == "....." ->
          {:lock, value}

        type == "....." and last_row == "#####" ->
          {:key, value}
      end
    end)
    |> Enum.group_by(&elem(&1, 0))
  end
end
