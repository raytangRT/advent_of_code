defmodule Day21.Helpers do
  @numpad_paths Day21.Numpad.all_paths()
  @arrowpad_paths Day21.ArrowPad.all_paths()

  def get_numpad_paths(from, to) do
    Map.get(@numpad_paths, {from, to})
    |> Enum.map(fn path ->
      path ++ [:press]
    end)
  end

  def get_arrowpad_paths(from, to), do: Map.get(@arrowpad_paths, {from, to})

  def execute_on_arrowpad(path) do
    paths =
      Enum.reduce(path, {[], :press}, fn to, {result, from} ->
        paths =
          if from == to do
            [[:press]]
          else
            if get_arrowpad_paths(from, to) == nil do
              IO.warn("nill for #{from} -> #{to}")
            end

            Enum.map(get_arrowpad_paths(from, to), fn path ->
              path ++ [:press]
            end)
          end

        {[paths | result], to}
      end)
      |> elem(0)
      |> Enum.reverse()

    [head | rest] =
      paths

    Enum.reduce(rest, head, fn paths, result ->
      ListUtils.cross_join(result, paths)
      |> Enum.map(fn {left, right} -> left ++ right end)
    end)
  end
end
