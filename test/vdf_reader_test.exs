defmodule VDF.ReaderTest do
  alias VDF.ParseError
  alias VDF.Reader

  use ExUnit.Case, async: true

  @vdf """

  // Outer Layer
  "root" //Comment
  {
    // Inner Layer
    "key1" "value1"
    "key2" "value2" //Comment
    "key3"
  {



      "key9"
      {
      }
      "key4" "value4"
      "key5" "value5"
      "key6"
      {
        "key7" "value7"
        "key8" "value8"
        "key7"          "nested value"
      }
      "key9" 
      {
        "n1" "v1"
      }
      "key9" 
      {
        "n1" "v1"
      }
    }
    // Another Comment
  }

  """

  test "can parse valid VDF" do
    assert Reader.parse_string(@vdf) ==
             {:ok,
              %{
                "root" => %{
                  "key1" => "value1",
                  "key2" => "value2",
                  "key3" => %{
                    "key4" => "value4",
                    "key5" => "value5",
                    "key6" => %{
                      "key7" => ["nested value", "value7"],
                      "key8" => "value8"
                    },
                    "key9" => [
                      %{"n1" => "v1"},
                      %{"n1" => "v1"},
                      %{}
                    ]
                  }
                }
              }}
  end

  test "can detect invalid VDF header" do
    invalid_vdf = """
    // Comment
    {
    """

    assert Reader.parse_string(invalid_vdf) ==
             {:error,
              %ParseError{
                line_number: 2,
                message: "received unexpected line of type `opening_brace`"
              }}
  end

  test "can detect unexpected line after key" do
    [
      {"""
       "key"

       """, "skippable"},
      {"""
       "key"
       // Comment
       """, "skippable"},
      {"""
       "key"
       "k" "v"
       """, "key_value"},
      {"""
       "key"
       "anotherKey"
       """, "key"},
      {"""
       "key"
       }
       """, "closing_brace"}
    ]
    |> Enum.each(fn {invalid_vdf, type} ->
      assert Reader.parse_string(invalid_vdf) ==
               {:error,
                %ParseError{
                  line_number: 2,
                  message: "received unexpected line of type `#{type}`"
                }}
    end)
  end

  test "can detect unexpected line after key value" do
    invalid = """
    "key"
    {
    "key1" "value1"
    {
    }
    }
    """

    assert Reader.parse_string(invalid) ==
             {:error,
              %ParseError{
                line_number: 4,
                message: "received unexpected line of type `opening_brace`"
              }}
  end

  test "can detect unexpected line after brace" do
    [
      """


      "key"
      {
      {
      """,
      """
      "key"
      {
      "k" "v1"
      }
      {
      """
    ]
    |> Enum.each(fn invalid_vdf ->
      assert Reader.parse_string(invalid_vdf) ==
               {:error,
                %ParseError{
                  line_number: 5,
                  message: "received unexpected line of type `opening_brace`"
                }}
    end)
  end

  test "can parse from dota heroes file" do
    result =
      File.stream!("test/resources/npc_heroes.txt")
      |> Reader.parse_enum()

    assert {:ok, map} = result
    assert is_map(map)
  end

  test "can parse from dota neutral items file" do
    result =
      File.stream!("test/resources/neutral_items.txt")
      |> Reader.parse_enum()

    assert {:ok, map} = result
    assert is_map(map)
  end
end
