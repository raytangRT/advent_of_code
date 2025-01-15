defmodule Year2024.Day17.Part1 do
  require Logger

  def run(mode \\ :sample) do
    read(mode)
    |> then(fn {registers, program} -> operate(registers, program) end)
  end

  def read(mode \\ :sampple) do
    AOC.read_file(mode, "day17")
    |> Enum.reduce({Map.new(), []}, fn line, {registers, programs} ->
      cond do
        String.starts_with?(line, "Register ") ->
          {MapUtils.put(
             registers,
             String.replace(line, ":", "")
             |> String.split()
             |> tl()
             |> Enum.map(fn input ->
               case Integer.parse(input) do
                 {v, _} -> v
                 _ -> String.to_atom(input)
               end
             end)
           ), programs}

        String.starts_with?(line, "Program: ") ->
          {registers,
           String.split(line)
           |> Enum.at(1)
           |> String.split(",")
           |> Enum.map(&String.to_integer/1)}

        true ->
          {registers, programs}
      end
    end)
  end

  def operate(registers, program) do
    operate(registers, program, program, [])
  end

  def operate(registers, remaining_programs, _full_programs, output)
      when length(remaining_programs) == 0 do
    {registers, output |> Enum.reject(&is_nil/1) |> Enum.reverse() |> Enum.join(",")}
  end

  def operate(registers, remaining_programs, full_programs, output) do
    [opcode | [operand | remaining_programs]] = remaining_programs

    action =
      case opcode do
        0 -> &adv/2
        1 -> &bxl/2
        2 -> &bst/2
        3 -> :jump
        4 -> &bxc/2
        5 -> &out/2
        6 -> &bdv/2
        7 -> &cdv/2
      end

    {new_register, new_output, remaining_programs} =
      if action == :jump do
        if Map.get(registers, :A) != 0 do
          new_remaining = Enum.slice(full_programs, operand..-1//1)
          {registers, nil, new_remaining}
        else
          {registers, nil, remaining_programs}
        end
      else
        action.(registers, operand)
        |> Tuple.append(remaining_programs)
      end

    output = if not is_nil(new_output), do: [new_output | output], else: output
    operate(new_register, remaining_programs, full_programs, output)
  end

  defp combo(operand, registers) do
    case operand do
      0 -> 0
      1 -> 1
      2 -> 2
      3 -> 3
      4 -> Map.get(registers, :A)
      5 -> Map.get(registers, :B)
      6 -> Map.get(registers, :C)
      7 -> raise("not valid input")
    end
  end

  defp adv(%{A: value} = registers, input) do
    input = combo(input, registers)
    new_value = div(value, Integer.pow(2, input))
    {Map.put(registers, :A, new_value), nil}
  end

  defp bxl(%{B: value} = register, input) do
    new_value = Bitwise.bxor(value, input)
    {Map.put(register, :B, new_value), nil}
  end

  defp bst(registers, input) do
    input = combo(input, registers)
    new_value = rem(input, 8)
    {Map.put(registers, :B, new_value), nil}
  end

  defp bxc(%{B: b_value, C: c_value} = registers, _input) do
    new_value = Bitwise.bxor(b_value, c_value)
    {Map.put(registers, :B, new_value), nil}
  end

  defp out(register, input) do
    input = combo(input, register)
    {register, rem(input, 8)}
  end

  defp bdv(%{A: value} = registers, input) do
    input = combo(input, registers)
    new_value = div(value, Integer.pow(2, input))
    {Map.put(registers, :B, new_value), nil}
  end

  defp cdv(%{A: value} = registers, input) do
    input = combo(input, registers)
    new_value = div(value, Integer.pow(2, input))
    {Map.put(registers, :C, new_value), nil}
  end
end
