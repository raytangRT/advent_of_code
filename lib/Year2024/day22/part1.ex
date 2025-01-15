defmodule Year2024.Day22.Part1 do
  import Bitwise
  @cache :cache

  def run(mode \\ :sample) do
    {_, pid} = Cachex.start(@cache)

    result =
      read(mode)
      |> Enum.map(&cal_secret(&1, 2000))
      |> Enum.sum()

    Process.exit(pid, :normal)

    result
  end

  def read(mode \\ :sample) do
    AOC.read_file(mode, "day22")
    |> Enum.map(&Integer.parse(&1))
    |> Enum.map(&elem(&1, 0))
  end

  def cal_secret(input, round) when is_integer(round) do
    Enum.reduce(0..(round - 1), input, fn _, value ->
      cal_next_secret(value)
    end)
  end

  def cal_next_secret(input, cache_name \\ @cache) when is_atom(cache_name) do
    if Cachex.exists?(cache_name, input) == {:ok, true} do
      Cachex.get!(cache_name, input)
    else
      result =
        input
        |> step_1()
        |> step_2()
        |> step_3()

      Cachex.put!(cache_name, input, result)
      result
    end
  end

  def step_1(input) do
    (input * 64)
    |> bxor(input)
    |> Integer.mod(16_777_216)
  end

  def step_2(input) do
    div(input, 32)
    |> bxor(input)
    |> Integer.mod(16_777_216)
  end

  def step_3(input) do
    (input * 2048)
    |> bxor(input)
    |> Integer.mod(16_777_216)
  end
end
