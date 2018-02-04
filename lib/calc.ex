
defmodule Calc do
  #regex expressions to handle positive number expressions
  @positive_regexes [
    *: ~r/(\d+)(\*)(\d+)/,
    /: ~r/(\d+)(\/)(\d+)/,
    +: ~r/(\d+)(\+)(\d+)/,
    -: ~r/(\d+)(\-)(\d+)/,
  ]

  #regex expression for checking brackets
  @brackets_regex ~r/\(([^()]+)\)/

  #regex expressions to handle negative numbers in expressions
  @neg_num_subtraction_regex ~r/(\-)(\d+)(\-)(\d+)/
  @neg_num_pos_num_expression_regex ~r/(\-)(\d+)(\+)(\d+)/
  @mul_div_neg_num_regex ~r/(\-)(\d+)(\*|\/)(\-)(\d+)/
  @subtraction_two_neg_num_regex ~r/(\-)(\d+)(\-)(\-)(\d+)/
  @subtraction_neg_neg_num_regex ~r/(\d+)(\-)(\-)(\d+)/
  @mul_div_pos_neg_regex ~r/(\d+)(\*|\/)(\-)(\d+)/
  @add_sub_expression_regex ~r/(\d+)(\+)(\-)(\d+)/
  @sign_regex ~r/(\+)(\-)(\d+)/
  @sign_regex2 ~r/(\-)(\+)(\d+)/
  @sign_regex3 ~r/(\+)(\d+)/
  @sign_regex4 ~r/(\(|\))(\d+)/

  #main function
  def main() do
    exp = IO.gets(">")
    exp1 = "(#{exp})"
    answer = eval(exp1)
    IO.puts("#{answer}")
    main()
  end

  #evaluate expression
  def eval(eq) do
    eq
    |>String.replace(" ","")
    |>neg_num_subtraction
    |>neg_num_pos_num_expression
    |>mul_div_neg_num
    |>subtraction_two_neg
    |>subtraction_neg_neg
    |>calculate_bdmas
    |>mul_div_pos_neg
    |>add_sub_expression
    |>final_sign
    |>final_sign2
    |>final_sign3
    |>check
  end

  #handling cases like -5-9
  def neg_num_subtraction(chunk) do
    if Regex.match?(@neg_num_subtraction_regex, chunk) do
      str = Regex.replace(@neg_num_subtraction_regex, chunk, fn _, _, l, _, r ->
        "-#{compute({to_int(r), "+", to_int(l)})}"
      end)
      eval(str)
    else
        chunk
    end
  end

  #handling cases like -5+9
  def neg_num_pos_num_expression(chunk) do
    if Regex.match?(@neg_num_pos_num_expression_regex, chunk) do
      str6 = Regex.replace(@neg_num_pos_num_expression_regex, chunk, fn _, _, l, _, r ->
        "+#{compute({to_int(r), "-", to_int(l)})}"
      end)
      eval(str6)
    else
        chunk
    end
  end

  #handling cases like -4*-9 or -5/-3
  def mul_div_neg_num(chunk) do
    if Regex.match?(@mul_div_neg_num_regex, chunk) do
      str2 = Regex.replace(@mul_div_neg_num_regex, chunk, fn _, _, l,op, _, r ->
        "+#{compute({to_int(l), op, to_int(r)})}"
      end)
      eval(str2)
    else
        chunk
    end
  end

  #handling cases like -5--9
  def subtraction_two_neg(chunk) do
    if Regex.match?(@subtraction_two_neg_num_regex, chunk) do
      str5 = Regex.replace(@subtraction_two_neg_num_regex, chunk, fn _, _, l, _, _, r ->
        "+#{compute({to_int(r), "-", to_int(l)})}"
      end)
      eval(str5)
    else
        chunk
    end
  end

  #handling cases like 5--9
  def subtraction_neg_neg(chunk) do
    if Regex.match?(@subtraction_neg_neg_num_regex, chunk) do
      str5 = Regex.replace(@subtraction_neg_neg_num_regex, chunk, fn _, l, _, _, r ->
        "+#{compute({to_int(r), "+", to_int(l)})}"
      end)
      eval(str5)
    else
        chunk
    end
  end

  #solving according bdmas
  def calculate_bdmas(equation) do
    solve(equation, :match)
  end

  #checking inner parens
  def solve(equation, :no_match), do: equation
  def solve(equation, :match) do
    solve(compute_inner(equation), match_found?(@brackets_regex, equation))
  end

  #finding inner parens
  def compute_inner(equation) do
    Regex.replace(@brackets_regex, equation, fn _, chunk ->
      bdmas(chunk, :start)
    end)
  end

  #solving according to bmas
  def bdmas(chunk, :done), do: chunk
  def bdmas(chunk, :start), do: bdmas(chunk, "*", :continue)
  def bdmas(chunk, op, :continue) do
    bdmas(chunk, op, match_found?(@positive_regexes[String.to_atom(op)], chunk))
  end
  def bdmas(chunk, op,  :match), do: bdmas(compute_answer(chunk, op), op, :continue)
  def bdmas(chunk, "*", :no_match), do: bdmas(chunk, "/", :continue)
  def bdmas(chunk, "/", :no_match), do: bdmas(chunk, "+", :continue)
  def bdmas(chunk, "+", :no_match), do: bdmas(chunk, "-", :continue)
  def bdmas(chunk, "-", :no_match), do: bdmas(chunk, :done)

  #calculating the answer inside parens
  def compute_answer(chunk, op) do
    Regex.replace(@positive_regexes[String.to_atom(op)], chunk, fn _, l, op, r ->
      "#{compute({to_int(l), op, to_int(r)})}"
    end)
  end

  #handling cases like 5*-9 or 8/-6
  def mul_div_pos_neg(chunk) do
    if Regex.match?(@mul_div_pos_neg_regex, chunk) do
      str4 = Regex.replace(@mul_div_pos_neg_regex, chunk, fn _, l, op1, _, r ->
        "-#{compute({to_int(l), op1, to_int(r)})}"
      end)
      eval(str4)
    else
        chunk
    end
  end

  #handling cases like 5+-9
  def add_sub_expression(chunk) do
    if Regex.match?(@add_sub_expression_regex, chunk) do
      str3 = Regex.replace(@add_sub_expression_regex, chunk, fn _, l, _, _, r ->
        "#{compute({to_int(l), "-", to_int(r)})}"
      end)
      eval(str3)
    else
        chunk
    end
  end

  #handling cases like +-9
  def final_sign(chunk) do
    if Regex.match?(@sign_regex, chunk) do
      str8 = Regex.replace(@sign_regex, chunk, fn _, _, _, r ->
        "-#{compute({to_int("0"), "+" , to_int(r)})}"
      end)
      eval(str8)
    else
        chunk
    end
  end

  #handling cases like -+6
  def final_sign2(chunk) do
    if Regex.match?(@sign_regex2, chunk) do
      str8 = Regex.replace(@sign_regex2, chunk, fn _, _, _, r ->
        "-#{compute({to_int("0"), "+" , to_int(r)})}"
      end)
      eval(str8)
    else
      chunk
    end
  end

  #handling cases like +6
  def final_sign3(chunk) do
    if Regex.match?(@sign_regex3, chunk) do
      str8 = Regex.replace(@sign_regex3, chunk, fn _, _, r ->
        "#{compute({to_int("0"), "+" , to_int(r)})}"
      end)
      eval(str8)
    else
      chunk
    end
  end

  def check(chunk) do
    if Regex.match?(@sign_regex4, chunk) do
      "ERROR"
    else
      chunk
    end
  end

  #finding matching patterns in the equation
  def match_found?(regex, chunk) do
    case Regex.match?(regex, chunk) do
      true -> :match
      false -> :no_match
    end
  end

  #convert string varable to Integer
  def to_int(str) do
    {num,_}=Integer.parse(str)
    num
  end

  #Basic math computations
  def compute({left, "*", right}), do: left * right
  def compute({left, "/", right}), do: div(left,right)
  def compute({left, "+", right}), do: left + right
  def compute({left, "-", right}), do: left - right

end
