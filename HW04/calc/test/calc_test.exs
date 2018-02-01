defmodule CalcTest do
  use ExUnit.Case
  doctest Calc

  test "calc.ex test" do
    assert "-2 + (5 - (6 - (4 + 3))) + (3 - (4 + 6))"|>Calc.eval=="-3.0";
    assert "1 * 5"|>Calc.eval=="5.0";
    assert "2 + 3"|>Calc.eval=="5.0";
    assert "24 / 6 + (5 - 4)"|>Calc.eval=="5.0";
    assert "(4 - 6) * 3 + 8"|>Calc.eval=="-2.0";
  end
end
