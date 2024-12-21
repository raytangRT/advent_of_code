defmodule Day13.Part1 do
  require Logger
  alias Okasaki.Protocols.Deque
  alias Okasaki.Deque
  @re_button ~r"X\+(?<x>\d+).*Y\+(?<y>\d+)"
  @re_prize ~r"X=(?<x>\d+).*Y=(?<y>\d+)"

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day13")
    |> Enum.reduce([], fn a, l -> [a | l] end)
    |> Enum.reject(&(&1 == ""))
    |> Enum.reverse()
    |> Enum.chunk_every(3)
    |> Enum.map(&parse/1)
    |> Enum.map(&begin_walk/1)
    |> Enum.map(fn {left, right} -> min(left, right) end)
    |> Enum.reject(&is_nil/1)
    |> Enum.sum()
  end

  def parse([buttonA_str | [buttonB_str | [prize_str | _]]]) do
    %{"x" => buttonA_delta_x, "y" => buttonA_delta_y} =
      Regex.named_captures(@re_button, buttonA_str)

    %{"x" => buttonB_delta_x, "y" => buttonB_delta_y} =
      Regex.named_captures(@re_button, buttonB_str)

    %{"x" => prize_x, "y" => prize_y} =
      Regex.named_captures(@re_prize, prize_str)

    {{buttonA_delta_x |> String.to_integer(), buttonA_delta_y |> String.to_integer(), 3},
     {buttonB_delta_x |> String.to_integer(), buttonB_delta_y |> String.to_integer(), 1},
     {prize_x |> String.to_integer(), prize_y |> String.to_integer()}}
  end

  def begin_walk({buttonA, buttonB, prize}) do
    buttons_a = walk(init_path(buttonA, prize), buttonB, prize)
    buttons_b = walk(init_path(buttonB, prize), buttonA, prize)
    {buttons_a, buttons_b}
  end

  def init_path({button_x, button_y, _cost} = button, {prize_x, prize_y}) do
    scale =
      if button_x >= button_y do
        prize_x / button_x
      else
        prize_y / button_y
      end
      |> floor()

    buttons = List.duplicate(button, scale) |> Deque.new()
    current = calculate_current(buttons)
    {buttons, current}
  end

  def walk({buttons, current}, _button, prize) when current == prize do
    buttons = buttons |> Deque.to_list()

    cost =
      Enum.group_by(buttons, &elem(&1, 2))
      |> Enum.map(fn {key, list} -> key * length(list) end)
      |> Enum.sum()

    cost
  end

  def walk({buttons, {current_x, current_y}}, button, {prize_x, prize_y} = prize) do
    cond do
      Enum.all?(buttons, &(&1 == button)) ->
        nil

      true ->
        buttons =
          if current_x > prize_x or current_y > prize_y do
            {:ok, {_, buttons}} = Deque.remove_left(buttons)
            buttons
          else
            buttons
          end

        buttons = Deque.insert_right(buttons, button)
        new_current = calculate_current(buttons)

        walk({buttons, new_current}, button, prize)
    end
  end

  def calculate_current(buttons) do
    buttons
    |> Deque.to_list()
    |> Enum.reduce({0, 0}, fn {delta_x, delta_y, _cost}, {sum_x, sum_y} ->
      {sum_x + delta_x, sum_y + delta_y}
    end)
  end
end
