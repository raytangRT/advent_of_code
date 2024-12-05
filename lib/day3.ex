defmodule Day3 do
  require Logger
  @input_path "day3.txt"
  @re ~r/mul\((?<left>\d+),(?<right>\d+)\)/U
  @re_boundary ~r/(don't\(\).*do\(\)|don't\(\).*$)/U

  def run do
    AOC.read_file(@input_path)
    |> Enum.map(&extract/1)
    |> Enum.concat()
    |> Enum.reduce(0, &accumulate/2)
  end

  def replace(input) do
    Logger.info(input, ansi_color: :blue)
    # extracted_text = Regex.scan(@re_boundary, input)
    # Logger.info(extracted_text, ansi_color: :red)
    new_input = String.replace(input, @re_boundary, "")
    Logger.info(new_input)
    new_input
  end

  def extract(input) do
    values = Regex.scan(@re, input, capture: :all_names)
    values
  end

  def accumulate(item, acc) do
    [left, right] = item
    acc + String.to_integer(left) * String.to_integer(right)
  end

  @re_run2 ~r/(?<token_dont>don't\(\))|(?<token_do>do\(\))|(mul\((?<left>\d{1,3}+),(?<right>\d{1,3})\))/U
  # 92082041
  def run2 do
    AOC.read_file(@input_path)
    # capture all the don't, do, and mul
    |> Enum.map(&Regex.scan(@re_run2, &1, capture: :all_names))
    # concat all captures for easier processing
    |> Enum.concat()
    # filter out unmatched groups (because Regex.scan returns ["", "", "", ""], each represent 1 match)
    |> Enum.reduce([], fn item, list ->
      [Enum.reject(item, &(&1 == "")) | list]
    end)
    # reverse the list after reduce
    |> Enum.reverse()
    |> Enum.flat_map(fn item ->
      cond do
        is_list(item) and length(item) > 1 -> [item]
        is_list(item) -> item
        true -> [item]
      end
    end)
    |> Enum.reduce({[], true}, &accumulate2/2)
    # elem to bridge the processing back to part 1's logic'
    |> then(&elem(&1, 0))
    |> Enum.reduce(0, &accumulate/2)
  end

  def accumulate2(item, {list, enabled}) do
    cond do
      item == "don't()" ->
        {list, false}

      item == "do()" ->
        {list, true}

      is_list(item) and enabled ->
        {[item | list], enabled}

      true ->
        {list, enabled}
    end
  end
end
