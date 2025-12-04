defmodule Year2024.Day12.Plot do
  defstruct [:point, :value]

  def new(x, y, value) do
    %__MODULE__{
      point: Point.new(x, y),
      value: value
    }
  end

  def travel(%__MODULE__{point: point, value: value}) do
    %__MODULE__{
      point: point,
      value: value
    }
  end

  def value(%__MODULE__{value: value}), do: value

  def location(%__MODULE__{point: point}), do: point
end
