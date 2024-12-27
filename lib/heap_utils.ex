defmodule HeapGuards do
  defguard is_heap(heap) when is_struct(heap, Heap)

  defguard is_empty_heap(heap) when is_heap(heap) and heap.size == 0
end
