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

  def to_tuple(p) do
    {p.x, p.y}
  end

  def slope(p1, p2) do
    {x1, y1} = Point.to_tuple(p1)
    {x2, y2} = Point.to_tuple(p2)

    if x2 == x1 do
      # Slope is undefined for vertical lines
      :undefined
    else
      (y2 - y1) / (x2 - x1)
    end
  end

  def distance(p1, p2) do
    {x1, y1} = Point.to_tuple(p1)
    {x2, y2} = Point.to_tuple(p2)
    :math.sqrt(:math.pow(x2 - x1, 2) + :math.pow(y2 - y1, 2))
  end

  def mid_point(p1, p2) do
    {x1, y1} = p1
    {x2, y2} = p2

    midpoint_x = x1 + div(x2 - x1, 2)
    midpoint_y = y1 + div(y2 - y1, 2)

    Point.new(midpoint_x, midpoint_y)
  end

  def move(point, delta) do
    {x, y} = Point.to_tuple(point)
    {delta_x, delta_y} = delta
    Point.new(x + delta_x, y + delta_y)
  end

  def diff(p1, p2) do
    {p1.x - p2.x, p1.y - p2.y}
  end

  def extend(point, delta) do
    {x, y} = Point.to_tuple(point)
    {delta_x, delta_y} = delta

    [Point.new(x + delta_x, y + delta_y), Point.new(x - delta_x, y - delta_y)]
  end

  def extend(p, slope, distance) do
    {x0, y0} = Point.to_tuple(p)
    theta = :math.atan(slope)

    # Calculate the coordinates of the new points
    x1 = x0 + distance * :math.cos(theta)
    y1 = y0 + distance * :math.sin(theta)

    x2 = x0 - distance * :math.cos(theta)
    y2 = y0 - distance * :math.sin(theta)
    [Point.new(x1, y1), Point.new(x2, y2)]
  end
end
