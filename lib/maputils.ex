defmodule MapUtils do
  def swap_value(map, key1, key2) do
    value1 = Map.get(map, key1)
    value2 = Map.get(map, key2)

    map
    |> Map.put(key1, value2)
    |> Map.put(key2, value1)
  end

  def get_or_put(map, key, value_fn) do
    if Map.has_key?(map, key) do
      {Map.get(map, key), map}
    else
      value = value_fn.(key)
      {value, Map.put(map, key, value)}
    end
  end
end
