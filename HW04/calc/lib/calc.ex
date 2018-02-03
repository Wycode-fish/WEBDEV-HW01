defmodule Calc do

  def eval(expression) do
    if expression|>String.length==1 and expression|>isNumeric? do
      expression;
    else
      expression = expression|>String.trim
                      |>String.split("(")|>concatParen("(")
                      |>String.split(")")|>concatParen(")");
      if expression|>String.trim|>String.split(" ")|>valid?() do
        expression|>String.trim|>String.split(" ")
                  |>removeParen([])|>calculate|>Float.to_string;
      else
        "oops, invalid expression."
      end
    end
  end

  def concatParen(exprList, paren) do
    if paren=="(" do
      exprList|>Enum.join("( ");
    else
      exprList|>Enum.join(" )");
    end
  end

  def removeParen(exprList, storage) do
    if Enum.empty?(exprList) do
      storage;
    else

      fst = List.first(exprList);
      cond do
        not isParenthesis?(fst) ->
          addToStorage(exprList, storage);
        isParenthesis?(fst) ->
          atLeftParen(exprList, storage);
      end
    end
  end

  def atLeftParen(exprList, storage) do
    if exprList|>Enum.slice(1..-1)|>Enum.any?(fn(x) -> x=="(" end) do
      lstLength = exprList|>Enum.count;
      currRightIdx =  findRightMatchIdx(exprList, 0, 0, 0);
      inner = exprList|>Enum.slice(1..currRightIdx-1)|>removeParen([]);
      inner = inner|>calculate|>Float.to_string|>List.wrap;
      storage = storage ++ inner;
      if currRightIdx+1>=lstLength do
        storage;
      else
        exprList = exprList|>Enum.slice(currRightIdx+1..-1);
        removeParen(exprList, storage);
      end
    else
      tailIdx = exprList|>Enum.find_index(fn(x) -> x==")" end);
      resultWrap = exprList|>Enum.slice(1..tailIdx-1)|>calculate
                |>Float.to_string|>List.wrap;
      storage++resultWrap;
    end
  end

  def parenMatch?(exprList, stk) do
    if (exprList|>Enum.empty?) do
      stk|>Enum.empty?;
    else
      cond do
        exprList|>Enum.at(0) == "(" ->
          parenMatch?(exprList|>Enum.slice(1..-1), stk++List.wrap("("));
        exprList|>Enum.at(0) == ")" ->
          parenMatch?(exprList|>Enum.slice(1..-1), stk|>Enum.slice(0..-2));
        true ->
          parenMatch?(exprList|>Enum.slice(1..-1), stk);
      end
    end
  end

  def valid?(exprList) do
    match? =  parenMatch?(exprList, []);
    details? = detailValid?(exprList);
    match? and details?;
  end

  def detailValid?(exprList) do
    cond do
      exprList|>Enum.count == 1 ->
        true;
      exprList|>Enum.at(0) == "(" ->
        isNumeric?(exprList|>Enum.at(1)) and detailValid?(exprList|>Enum.slice(1..-1));
      exprList|>Enum.at(0) == ")" ->
        exprList|>Enum.at(1)!="(" and detailValid?(exprList|>Enum.slice(1..-1));
      isOperator?(exprList|>Enum.at(0)) ->
        rightParen? = exprList|>Enum.at(1)==")";
        operator? = exprList|>Enum.at(1)|>isOperator?;
        (not rightParen?) and (not operator?) and detailValid?(exprList|>Enum.slice(1..-1));
      isNumeric?(exprList|>Enum.at(0)) ->
        num? = isNumeric?(exprList|>Enum.at(1));
        (not num?) and detailValid?(exprList|>Enum.slice(1..-1));
      true ->
        detailValid?(exprList|>Enum.slice(1..-1));
    end
  end

  def isOperator?(str) do
    str=="+" or str=="-" or str=="*" or str=="/";
  end

  def findRightMatchIdx(exprList, left, right, idx) do
    equal? = left==right;
    notZero? = right != 0;
    if equal? and notZero? do
      idx - 1;
    else
      cond do
        exprList|>Enum.at(0)=="(" ->
          findRightMatchIdx(exprList|>Enum.slice(1..-1), left+1, right, idx+1);
        exprList|>Enum.at(0)==")" ->
          findRightMatchIdx(exprList|>Enum.slice(1..-1), left, right+1, idx+1);
        true ->
          findRightMatchIdx(exprList|>Enum.slice(1..-1), left, right, idx+1);
      end
    end
  end


  def addToStorage(exprList, storage) do
    fst = List.first(exprList);
    newExprList = exprList|>Enum.slice(1..-1);
    newStorage = storage++List.wrap(fst);
    removeParen(newExprList, newStorage);
  end

  def calculate(exprList) do
    if exprList|>Enum.count == 3 do
      exprList|>calcNoOrder;
    else
      exprList|>replaceMulDiv([])|>calcNoOrder;
    end
  end

  def calcNoOrder(exprList) do
    operands = Enum.filter(exprList, fn(x) -> x|>isNumeric? end);
    if operands|>Enum.empty? do
      IO.puts "operand error!";
      main();
    end
    operators = Enum.filter(exprList, fn(x) -> not isNumeric?(x) end);
    result = operands|>Enum.at(0)|>Float.parse|>elem(0);
    operands = operands|>Enum.slice(1..-1);
    calcNoOrderHelper(operands, operators, result);
  end

  def calcNoOrderHelper(operands, operators, result) do
    if Enum.empty?(operators) do
      result;
    else
      newResult =
        cond do
          String.equivalent?(operators|>Enum.at(0), "+") ->
            op = Float.parse(operands|>Enum.at(0))|>elem(0);
            result + op;
          String.equivalent?(operators|>Enum.at(0), "-") ->
            op = Float.parse(operands|>Enum.at(0))|>elem(0);
            result - op;
          String.equivalent?(operators|>Enum.at(0), "*") ->
            op = Float.parse(operands|>Enum.at(0))|>elem(0);
            result * op;
          String.equivalent?(operators|>Enum.at(0), "/") ->
            op = Float.parse(operands|>Enum.at(0))|>elem(0);
            result / op;
          true ->
            IO.puts "operator error!";
            main();
        end
      operands = operands|>Enum.slice(1..-1);
      operators = operators|>Enum.slice(1..-1);
      calcNoOrderHelper(operands, operators, newResult);
    end
  end

  def replaceMulDiv(exprList, storage) do
    cond do
      exprList|>Enum.empty? ->
        storage;
      exprList|>Enum.count == 1 ->
        storage++exprList;
      true ->
        firstOpt = exprList|>Enum.at(1);
        mulOrDiv? = firstOpt=="*" or firstOpt=="/";
        cond do
          not mulOrDiv? ->
            replaceNothing(exprList, storage);
          mulOrDiv? ->
            replace(exprList, storage);
        end
    end
  end

  def replaceNothing(exprList, storage) do
    firstOp = exprList|>Enum.slice(0..1);
    storage = storage++firstOp;
    exprList = exprList|>Enum.slice(2..-1);
    replaceMulDiv(exprList, storage);
  end

  def replace(exprList, storage) do
    result = exprList|>Enum.slice(0..2)|>calcNoOrder;
    resultStrList = Float.to_string(result)|>List.wrap;
    newStorage = storage ++ resultStrList;
    newExprList = exprList|>Enum.slice(3..-1);
    replaceMulDiv(newExprList, newStorage);
  end

  def isParenthesis?(expr1) do
    String.equivalent?(expr1,"(") or String.equivalent?(expr1,")");
  end

  def isNumeric?(str) do
    isInt? =
      case Integer.parse(str) do
        {_num, ""} -> true
        _          -> false
      end
    isFloat? =
      case Float.parse(str) do
        {_num, ""} -> true
        _          -> false
      end
    isInt? or isFloat?;
  end

  def main do
    expr = IO.gets "> ";
    if expr == "" do
      main();
    else
      result = expr|>eval;
      IO.puts result;
      main();
    end
  end

end
