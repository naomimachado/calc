defmodule CalcTest do
  use ExUnit.Case
  doctest Calc

  test "testing simple expressions" do
    assert Calc.eval("( 5 + 6 )") == "11"
    assert Calc.eval("( 5 - 6 )") == "-1"
    assert Calc.eval("( 5 * 6 )") == "30"
    assert Calc.eval("( 5 / 6 )") == "0"
  end

  test "chain expressions" do
    assert Calc.eval("( 5 + 6 + 8)") == "19"
    assert Calc.eval("( 10 - 2 - 3 )") == "5"
    assert Calc.eval("( 5 * 6 * 6 )") == "180"
    assert Calc.eval("( 100 / 5 / 2 )") == "10"
  end

  test "mix expressions" do
    assert Calc.eval("( 5 + 6 * 4)") == "29"
    assert Calc.eval("( 5 + 6 -8 )") == "3"
    assert Calc.eval("( 5 * 2 / 2 )") == "5"
    assert Calc.eval("( 4 - 2 * 2 )") == "0"
  end

  test "bdmas" do
    assert Calc.eval("( (5 + 6) * (7 + 8) )") == "165"
    assert Calc.eval("( 1 * (2 -(5 + 8)))") == "-11"
    assert Calc.eval("( 24 / 6 + (5 - 4))") == "5"
    assert Calc.eval("( 1 + 3 * 3 + 1)") == "11"
  end

  test "odd expressions" do
    assert Calc.eval("( - 5 - 6 )") == "-11"
    assert Calc.eval("( 5 + -6 )") == "-1"
    assert Calc.eval("( -5 - -6 )") == "1"
    assert Calc.eval("( -5 + 6 )") == "1"
    assert Calc.eval("( -5 * -6 )") == "30"
    assert Calc.eval("( -10 / -5 )") == "2"
  end
end
