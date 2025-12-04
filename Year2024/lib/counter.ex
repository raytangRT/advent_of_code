defmodule Counter do
  require Logger
  defstruct [:storage]

  def new(list \\ []) do
    storage =
      Enum.reduce(list, %{}, fn item, acc ->
        Map.update(acc, item, 1, &(&1 + 1))
      end)

    %Counter{
      storage: storage
    }
  end

  def add(%Counter{storage: storage}, item, count \\ 1) do
    new_storage = Map.update(storage, item, count, &(&1 + count))

    %Counter{
      storage: new_storage
    }
  end

  def keys(%Counter{storage: storage}) do
    Map.keys(storage)
  end

  def values(%Counter{storage: storage}) do
    Map.values(storage)
  end

  def total(%Counter{storage: storage}) do
    Map.values(storage) |> Enum.sum()
  end
end

defimpl Enumerable, for: Counter do
  @doc """
  Reduces the Counter using the given accumulator and reducer function.
  """
  def reduce(%Counter{storage: storage}, acc, fun) do
    Enumerable.reduce(storage, acc, fun)
  end

  @doc """
  Returns the number of key-value pairs in the Counter.
  """
  def count(%Counter{storage: storage}) do
    {:ok, map_size(storage)}
  end

  @doc """
  Checks if a given element exists as a key in the Counter.
  """
  def member?(%Counter{storage: storage}, {key, value}) do
    case Map.fetch(storage, key) do
      {:ok, ^value} -> {:ok, true}
      _ -> {:ok, false}
    end
  end

  def member?(%Counter{storage: storage}, key) do
    {:ok, Map.has_key?(storage, key)}
  end

  @doc """
  Slicing is not supported for Counter.
  """
  def slice(_counter) do
    {:error, __MODULE__}
  end
end
