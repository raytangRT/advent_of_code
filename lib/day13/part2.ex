defmodule Day13.Part2 do
  require Logger
  alias Okasaki.Protocols.Deque
  alias Okasaki.Deque
  @re_button ~r"X\+(?<x>\d+).*Y\+(?<y>\d+)"
  @re_prize ~r"X=(?<x>\d+).*Y=(?<y>\d+)"
  # 98958951401151 to high
  def read(mode \\ :sample) do
    AOC.read_file(mode, "day13")
    |> Enum.reduce([], fn a, l -> [a | l] end)
    |> Enum.reject(&(&1 == ""))
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.map(&parse/1)
    |> Enum.map(fn {buttonA, buttonB, prize} ->
      {a, b} = math_approach(buttonA, buttonB, prize)

      cond do
        is_nil(a) and is_nil(b) ->
          0

        true ->
          a * 3 + b
      end
    end)
  end

  def parse([buttonA_str | [buttonB_str | [prize_str | _]]]) do
    %{"x" => buttonA_delta_x, "y" => buttonA_delta_y} =
      Regex.named_captures(@re_button, buttonA_str)

    %{"x" => buttonB_delta_x, "y" => buttonB_delta_y} =
      Regex.named_captures(@re_button, buttonB_str)

    %{"x" => prize_x, "y" => prize_y} =
      Regex.named_captures(@re_prize, prize_str)

    {{buttonA_delta_x |> String.to_integer(), buttonA_delta_y |> String.to_integer()},
     {buttonB_delta_x |> String.to_integer(), buttonB_delta_y |> String.to_integer()},
     {String.to_integer(prize_x) + 10_000_000_000_000,
      String.to_integer(prize_y) + 10_000_000_000_000}}
  end

  def math_approach({x1, y1}, {x2, y2}, {xp, yp}) do
    {b, remaining} =
      (fn ->
         u = x1 * yp - y1 * xp
         v = x1 * y2 - x2 * y1
         {div(u, v), rem(u, v)}
       end).()

    {a, a_remaining} =
      (fn ->
         u = xp - x2 * b
         v = x1
         {div(u, v), rem(u, v)}
       end).()

    cond do
      remaining != 0 or a_remaining != 0 ->
        {nil, nil}

      true ->
        {a, b}
    end
  end
end
