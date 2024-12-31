defmodule Day17.Part2 do
  require Logger
  import Day17.Part1
  import Bitwise

  @program [2, 4, 1, 7, 7, 5, 0, 3, 4, 0, 1, 7, 5, 5, 3, 0]
  @start_pnt 0o7777770000000000
  @end_point 0o7777777700000000
  def run() do
    expected_result = Enum.join(@program, ",")

    Enum.reduce_while(
      0o66160527..0o7777777777,
      0,
      fn v, _ ->
        actual_result = op(v)

        if actual_result |> String.starts_with?("0,3,4,0,1,7,5,5,3,0") do
          IO.puts("[#{v}] [#{Integer.to_string(v, 8)}] = #{inspect(actual_result)}")
        end

        if actual_result == expected_result do
          {:halt, v}
        else
          {:cont, 0}
        end
      end
    )
  end

  def op(value, program \\ @program) do
    registers = %{A: value}
    {_, output} = operate(registers, program)
    output
  end

  def oct(input) when input < 8 do
    [0, input]
  end

  def oct(input) do
    num = Integer.to_string(input, 8)

    String.split_at(num, -1)
    |> Tuple.to_list()
    |> Enum.map(&String.to_integer(&1, 8))
  end

  def act(ans, list \\ []) do
    [a1, d0] = oct(ans)
    c1 = ans >>> (7 - d0)
    res = bxor(c1, d0) |> band(7)
    list = [res |> Integer.to_string() | list]

    if a1 > 0 do
      act(a1, list)
    else
      list
    end
  end

  # kind of brute force
  def loop_guest() do
    guess = "726011052262"

    start_point =
      (guess <> "0000") |> Integer.parse(8) |> elem(0)

    end_point =
      (guess <> "7777") |> Integer.parse(8) |> elem(0)

    Enum.reduce_while(start_point..end_point, 0, fn input, _ ->
      ProgressBar.render(input, end_point, suffix: :count)
      result = op(input)

      if String.ends_with?(result, "2,4,1,7,7,5,0,3,4,0,1,7,5,5,3,0") do
        IO.puts("#{input |> Integer.to_string(8)}, #{result}")
      end

      {:cont, 0}
    end)
  end

  def guest(output, k) do
    for idx <- 0..7 do
      value = (output + 8 * k) |> bxor(idx) <<< (7 - idx)
      {idx, value, op(value)}
    end
  end
end
