defmodule Year2024.Day17.Part2 do
  require Logger
  import Year2024.Day17.Part1

  @program [2, 4, 1, 7, 7, 5, 0, 3, 4, 0, 1, 7, 5, 5, 3, 0]

  def guess() do
    programs = Enum.reverse(@program) |> Enum.map(&Integer.to_string/1)

    guess_recursively("", programs)
    |> List.flatten()
    |> Enum.sort()
    |> Enum.map(&String.to_integer(&1, 8))
  end

  defp op(value) do
    registers = %{A: value}
    {_, output} = operate(registers, @program)
    output
  end

  defp start_guessing(guess, expected) do
    starting_point = (guess <> "0") |> Integer.parse(8) |> elem(0)
    ending_point = (guess <> "7") |> Integer.parse(8) |> elem(0)

    Enum.map(starting_point..ending_point, fn input ->
      result = op(input)

      if String.ends_with?(result, expected) do
        input |> Integer.to_string(8)
      else
        nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  defp guess_recursively(v, list, expected \\ "")

  defp guess_recursively(v, list, _expected) when length(list) == 0 do
    v
  end

  defp guess_recursively(v, [head | tail], expected) do
    new_expected =
      if String.length(expected) > 0, do: [head, expected] |> Enum.join(","), else: head

    start_guessing(v, new_expected)
    |> Enum.map(fn next ->
      guess_recursively(next, tail, new_expected)
    end)
  end
end
