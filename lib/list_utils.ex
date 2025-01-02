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
end
