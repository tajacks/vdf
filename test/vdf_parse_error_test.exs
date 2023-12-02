defmodule VDF.ParseErrorTest do
  use ExUnit.Case, async: true

  test "can create error at EOF" do
    assert VDF.ParseError.unexpected_eof() == %VDF.ParseError{
             line_number: nil,
             message: "unexpectedly reached end of file while within nested block"
           }
  end

  test "can create error at line" do
    assert VDF.ParseError.unexpected_line(6, :key) == %VDF.ParseError{
             line_number: 6,
             message: "received unexpected line of type `key`"
           }
  end
end
