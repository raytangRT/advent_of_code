defmodule ListUtils do
  def find_duplications(list1, list2) when is_list(list1) and is_list(list2) do
    list1
    # Find elements in both lists
    |> Enum.filter(&(&1 in list2))
    # Remove duplicates
    |> Enum.uniq()
  end

  def split_list(list) when is_nil(list), do: {nil, nil, nil}
  def split_list(list) when length(list) == 0, do: {nil, nil, nil}
  def split_list([head | rest]) when length(rest) == 0, do: {head, nil, nil}
  def split_list([head | rest]) when length(rest) == 1, do: {head, nil, hd(rest)}

  def split_list([first | rest]) do
    [last | middle] = Enum.reverse(rest)
    {first, Enum.reverse(middle), last}
  end

  def remove_by_value(list, target) do
    idx = Enum.find_index(list, &(&1 == target))

    if is_nil(idx) do
      {:no_change, list}
    else
      {front, [_ | rest]} = Enum.split(list, idx)
      {:ok, {front, rest}}
    end
  end

  def flatten(list, result) when list == [], do: result

  def flatten([h | _r] = list, result) when is_list(list) and is_list(h) do
    Enum.reduce(list, result, fn nested_list, result ->
      flatten(nested_list, result)
    end)
  end

  def flatten([h | _r] = list, result) when is_list(list) and not is_list(h) do
    MapSet.put(result, list)
  end

  def cross_join(list1, list2) when is_list(list1) and is_list(list2) do
    for item1 <- list1, item2 <- list2 do
      {item1, item2}
    end
  end

  def filter(list1, list2) when is_list(list1) and is_list(list2) do
    Enum.reject(list2, fn item ->
      item in list1
    end)
  end

  def remove_nils(list) do
    cleaned =
      list
      |> Enum.map(&clean_element/1)
      |> Enum.reject(&is_nil/1)

    # Only return non-nested lists
    if length(cleaned) == 1 and is_list(hd(cleaned)) do
      hd(cleaned)
    else
      cleaned
    end
  end

  defp clean_element(nil), do: nil

  defp clean_element(other) when is_list(other) do
    cleaned = remove_nils(other)
    if cleaned == [], do: nil, else: cleaned
  end

  defp clean_element(other), do: other

  def pop_front_and_last([head | tail] = list) when is_list(list) do
    {last, modified_tail} = List.pop_at(tail, -1)

    {head, modified_tail, last}
  end
end
