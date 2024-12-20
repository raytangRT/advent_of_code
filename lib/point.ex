defmodule Point do
  require Logger
  defstruct [:x, :y]

  # defimpl String.Chars, for: Point do
  #   def to_string(point) do
  #     "Point(#{point.x}, #{point.y})"
  #   end
  # end

  def new(x, y) do
    %__MODULE__{
      x: round(x),
      y: round(y)
    }
  end

  def string(%__MODULE__{x: x, y: y}) do
    "(#{x}, #{y})"
  end

  def slope(%__MODULE__{x: x1, y: y1}, %__MODULE__{x: x2, y: y2}) do
    if x2 == x1 do
      # Slope is undefined for vertical lines
      :undefined
    else
      (y2 - y1) / (x2 - x1)
    end
  end

  def distance(%__MODULE__{x: x1, y: y1}, %__MODULE__{x: x2, y: y2}) do
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end

  def mid_point(%__MODULE__{x: x1, y: y1}, %__MODULE__{x: x2, y: y2}) do
    midpoint_x = x1 + div(x2 - x1, 2)
    midpoint_y = y1 + div(y2 - y1, 2)

    Point.new(midpoint_x, midpoint_y)
  end

  def move(%__MODULE__{x: x, y: y}, delta) do
    {delta_x, delta_y} = delta
    Point.new(x + delta_x, y + delta_y)
  end

  def move_top(%__MODULE__{x: x, y: y}), do: Point.new(x, y - 1)
  def move_left(%__MODULE__{x: x, y: y}), do: Point.new(x - 1, y)
  def move_right(%__MODULE__{x: x, y: y}), do: Point.new(x + 1, y)
  def move_down(%__MODULE__{x: x, y: y}), do: Point.new(x, y + 1)

  def diff(p1, p2) do
    {p1.x - p2.x, p1.y - p2.y}
  end

  def extend(%__MODULE__{x: x, y: y}, delta) do
    {delta_x, delta_y} = delta

    [Point.new(x + delta_x, y + delta_y), Point.new(x - delta_x, y - delta_y)]
  end

  def extend(%__MODULE__{x: x0, y: y0}, slope, distance) do
    theta = :math.atan(slope)

    # Calculate the coordinates of the new points
    x1 = x0 + distance * :math.cos(theta)
    y1 = y0 + distance * :math.sin(theta)

    x2 = x0 - distance * :math.cos(theta)
    y2 = y0 - distance * :math.sin(theta)
    [Point.new(x1, y1), Point.new(x2, y2)]
  end
end
