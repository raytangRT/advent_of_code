defmodule Day17.Part1.Test do
  use ExUnit.Case
  import Day17.Part1

  test "If register C contains 9, the program 2,6 would set register B to 1" do
    {registry, _output} = operate(%{C: 9}, [2, 6])
    assert Map.get(registry, :B) == 1
  end

  test "If register A contains 10, the program 5,0,5,1,5,4 would output 0,1,2." do
    {_register, output} = operate(%{A: 10}, [5, 0, 5, 1, 5, 4])
    assert output == "0,1,2"
  end

  test "If register A contains 2024, the program 0,1,5,4,3,0 would output 4,2,5,6,7,7,7,7,3,1,0 and leave 0 in register A." do
    {registry, output} = operate(%{A: 2024}, [0, 1, 5, 4, 3, 0])
    assert Map.get(registry, :A) == 0
    assert output == "4,2,5,6,7,7,7,7,3,1,0"
  end

  test "If register B contains 29, the program 1,7 would set register B to 26." do
    {registry, _output} = operate(%{B: 29}, [1, 7])
    assert Map.get(registry, :B) == 26
  end

  test "If register B contains 2024 and register C contains 43690, the program 4,0 would set register B to 44354." do
    {registers, _output} = operate(%{B: 2024, C: 43690}, [4, 0])
    assert Map.get(registers, :B) == 44354
  end

  test "sample" do
    {registers, program} = read()
    {_registers, output} = operate(registers, program)
    assert output == "4,6,3,5,6,3,5,2,1,0"
  end

  test "sample2" do
    {_registers, output} = operate(%{A: 117_440}, [0, 3, 5, 4, 3, 0])
    IO.puts("output = #{output}")
    assert true == false
  end
end
