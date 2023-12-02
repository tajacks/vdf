defmodule VDF.ReaderUtilTest do
  use ExUnit.Case, async: true

  import VDF.ReaderUtil

  test "can match closing brace" do
    assert is_closing_brace?("}") == true
    assert is_closing_brace?("    }") == true
    assert is_closing_brace?("    }    ") == true
    assert is_closing_brace?("} // Comment") == true
    assert is_closing_brace?("   } // Comment ") == true
  end

  test "do not match on invalid closing brace" do
    assert is_closing_brace?("{") == false
    assert is_closing_brace?("// Comment }") == false
    assert is_closing_brace?("    // Comment }") == false
    assert is_closing_brace?("t}") == false
    assert is_closing_brace?("} t") == false
  end

  test "can match opening brace" do
    assert is_opening_brace?("{") == true
    assert is_opening_brace?("    {") == true
    assert is_opening_brace?("    {    ") == true
    assert is_opening_brace?("{ // Comment") == true
    assert is_opening_brace?("   { // Comment ") == true
  end

  test "do not match on invalid opening brace" do
    assert is_opening_brace?("}") == false
    assert is_opening_brace?("// Comment {") == false
    assert is_opening_brace?("    // Comment {") == false
    assert is_opening_brace?("t{") == false
    assert is_opening_brace?("{ t") == false
  end

  test "can match empty line" do
    assert is_empty?("") == true
    assert is_empty?("  \n  ") == true
    assert is_empty?("  \t  ") == true
  end

  test "do not match on invalid empty line" do
    assert is_empty?("t") == false
    assert is_empty?("    t") == false
    assert is_empty?("t  ") == false
    assert is_empty?("t  \n  ") == false
    assert is_empty?("t  \t  ") == false
  end

  test "can match comment line" do
    assert is_comment?("// Comment") == true
    assert is_comment?("// Comment ") == true
    assert is_comment?("  // Comment") == true
    assert is_comment?("  // Comment  ") == true
    assert is_comment?("  // Comment  \t") == true
  end

  test "do not match on invalid comment line" do
    assert is_comment?("t") == false
    assert is_comment?("") == false
    assert is_comment?("  ") == false
    assert is_comment?("{ // Comment") == false
  end

  test "can determine if line is skippable" do
    assert is_skippable?("  ") == true
    assert is_skippable?("") == true
    assert is_skippable?("// Comment") == true
    assert is_skippable?("{") == false
    assert is_skippable?("}") == false
    assert is_skippable?("anything") == false
  end

  test "can match single key" do
    assert key("\"orangutan\"") == {:ok, "orangutan"}
    assert key("\"orangutan\" // Comment") == {:ok, "orangutan"}
    assert key("  \"orangutan\"  ") == {:ok, "orangutan"}
    assert key("\"orangutan banana\"") == {:ok, "orangutan banana"}
  end

  test "single key matching does not match on other lines" do
    assert key("  ") == nil
    assert key("") == nil
    assert key("// Comment") == nil
    assert key("{") == nil
    assert key("}") == nil
    assert key("anything") == nil
    assert key("\"orangutan\" \"banana\"") == nil
  end

  test "can match key value" do
    assert key_value("\"orangutan\" \"banana\"") == {:ok, {"orangutan", "banana"}}
    assert key_value("\"orangutan\" \"banana\" // Comment") == {:ok, {"orangutan", "banana"}}
    assert key_value("  \"orangutan\"  \"banana\"  ") == {:ok, {"orangutan", "banana"}}
    assert key_value("\"orangutan\" \"banana apple\"") == {:ok, {"orangutan", "banana apple"}}
  end

  test "key value matching does not match on other lines" do
    assert key_value("  ") == nil
    assert key_value("") == nil
    assert key_value("// Comment") == nil
    assert key_value("{") == nil
    assert key_value("}") == nil
    assert key_value("anything") == nil
    assert key_value("\"orangutan\"") == nil
    assert key_value("\"orangutan\" \"banana\" \"apple\"") == nil
    assert key_value("\"orangutan\"") == nil
    assert key_value("\"orangutan\"") == nil
    assert key_value("\"orangutan\" // Comment") == nil
    assert key_value("  \"orangutan\"  ") == nil
  end
end
