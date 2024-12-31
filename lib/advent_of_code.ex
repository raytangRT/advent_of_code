defmodule AOC do
  require Logger

  def read_file(file_path) do
    Path.expand(Path.join(["./input", file_path]))
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end

  def read_file(mode, file_prefix) do
    file_path = if mode == :actual, do: "#{file_prefix}.txt", else: "#{file_prefix}.sample.txt"
    read_file(file_path)
  end

  def not_nil_do(input, f) do
    input
    |> case do
      nil -> nil
      ^input -> f.(input)
    end
  end

  def parse(str, delim \\ ",") when is_bitstring(str) do
    str |> String.split(delim) |> Enum.map(&String.to_integer/1)
  end

  def list_to_integer(list) when is_list(list) do
    Enum.map(list, &String.to_integer/1)
  end

  def in_range(target, lower, upper)
      when is_number(target) and is_number(lower) and is_number(upper) do
    lower <= target and target <= upper
  end

  def list(list) do
    inspect(list, charlists: :as_lists)
  end

  def print_list(list, prefix \\ "") do
    Logger.info("#{prefix} = #{AOC.list(list)}")
  end

  def remove_at(list, idx) when is_list(list) and is_number(idx) do
    {left, [_ | right]} = Enum.split(list, idx)
    left ++ right
  end

  def increasing?(list) do
    Enum.all?(Enum.zip(list, tl(list)), fn {a, b} -> a < b end)
  end

  def decreasing?(list) do
    Enum.all?(Enum.zip(list, tl(list)), fn {a, b} -> a > b end)
  end

  def intercept(item) do
    Logger.info("#{inspect(item)}")
    item
  end

  def intercept(item, f) do
    if f.(item) do
      intercept(item)
    end

    item
  end

  def list_to_file(list, file_path) do
    # Clear file before writing
    File.write!(file_path, "")

    Enum.each(Enum.with_index(list), fn {item, idx} ->
      ProgressBar.render(idx, length(list), suffix: :count)
      File.write!("output.txt", "#{inspect(item)}\n", [:append])
    end)
  end

  def clear_terminal do
    IO.puts(IO.ANSI.clear())
  end

  def if_nil(value, default) when is_nil(value), do: default
  def if_nil(value, _default), do: value
end

defmodule AOC.Text do
  import IO.ANSI

  def yellow(text) do
    yellow() <> text <> reset()
  end

  def red(text) do
    red() <> text <> reset()
  end

  def red(text, intensity) do
    color = "\e[38;2;#{rem(intensity, 255)};0;0m"
    color <> text <> reset()
  end

  def blue(text) do
    blue() <> text <> reset()
  end

  def green(text) do
    green() <> text <> reset()
  end

  def black(text) do
    black() <> text <> reset()
  end
end
