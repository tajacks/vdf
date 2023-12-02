defmodule VDF.Reader do
  alias VDF.ParseError

  import VDF.ReaderUtil

  @moduledoc """
  This module is responsible for parsing VDF files into Elixir maps. 

  The public API consists of two functions: `parse_string/1` and `parse_enum/1`. Both functions 
  have identical parsing logic and differ based on the input type. `parse_string/1` accepts a 
  binary string which will be split on new lines for parsing. `parse_enum/1` accepts an 
  enumerable of strings which will be parsed line by line. The intent is to use `parse_enum/1` 
  when parsing large files, alongside File.stream!/1, to avoid loading the entire file into memory. 
  """

  @reduction_statistics %{
    stack: [{nil, %{}}],
    unexpected_state: MapSet.new([:opening_brace, :closing_brace])
  }

  @unexpected_after_key MapSet.new([:skippable, :key, :key_value, :closing_brace])

  @unexpected_after_key_value MapSet.new([:opening_brace])

  @unexpected_after_brace MapSet.new([:opening_brace])

  @type stack :: [{String.t(), map} | {nil, map}]

  # Public API #

  @doc """
  Parses a VDF string into an Elixir map. 

  This function will split the input string on new lines and parse each line individually.
  """
  @spec parse_string(binary) :: {:ok, map} | {:error, ParseError.t()}
  def parse_string(vdf) when is_bitstring(vdf) do
    vdf
    |> split_lines()
    |> parse_enum()
  end

  @doc """
  Parses an Enumerable of Strings representing a VDF into an Elixir map.

  This function will treat each string as a new line in the VDF file. This function is intended
  to be used with File.stream!/1 to avoid loading the entire file into memory.
  """
  @spec parse_enum(Enum.t()) :: {:ok, map} | {:error, ParseError.t()}
  def parse_enum(enum) do
    enum
    |> Stream.with_index()
    |> Enum.reduce_while(@reduction_statistics, &parse_line_helper/2)
    |> parse_result()
  end

  # Private API #

  @spec parse_line_helper({String.t(), integer}, map) :: {:cont, map} | {:halt, ParseError.t()}
  defp parse_line_helper({line, index}, acc) do
    type = classify(line)
    classifier = classified_value(type)
    # Make sure the current line isn't invalid based on previous line
    if MapSet.member?(acc[:unexpected_state], classifier) do
      {:halt, ParseError.unexpected_line(index + 1, classifier)}
    else
      # Attempt to parse the line & update state
      case action_line_type(type, acc) do
        {:ok, acc} -> {:cont, acc}
        :error -> {:halt, ParseError.unexpected_line(index + 1, classifier)}
      end
    end
  end

  defp parse_result(%ParseError{} = e) do
    {:error, e}
  end

  defp parse_result(%{stack: [{_key, map}]}) do
    {:ok, map}
  end

  @spec action_line_type(atom | tuple, map) :: {:ok, map} | :error
  defp action_line_type({:key_value, {key, value}}, acc) do
    {:ok,
     %{
       acc
       | stack: enter_kv(acc[:stack], key, value),
         unexpected_state: @unexpected_after_key_value
     }}
  end

  defp action_line_type({:key, key}, acc) do
    {:ok, %{acc | stack: enter_k(acc[:stack], key), unexpected_state: @unexpected_after_key}}
  end

  defp action_line_type(:skippable, acc) do
    {:ok, acc}
  end

  defp action_line_type(:opening_brace, acc) do
    {:ok, %{acc | unexpected_state: @unexpected_after_brace}}
  end

  defp action_line_type(:closing_brace, acc) do
    case pop_stack(acc[:stack]) do
      :error -> :error
      stack -> {:ok, %{acc | stack: stack, unexpected_state: @unexpected_after_brace}}
    end
  end

  @spec enter_k(stack(), any) :: stack()
  defp enter_k(stack, key) do
    [{key, %{}} | stack]
  end

  @spec enter_kv(stack(), any, any) :: stack()
  defp enter_kv([{current_key, map} | rest], key, value) do
    [{current_key, enter_map_value(map, key, value)} | rest]
  end

  @spec enter_map_value(map, any, any) :: map
  defp enter_map_value(map, key, value) do
    case Map.get(map, key) do
      nil -> Map.put(map, key, value)
      existing_value when is_list(existing_value) -> Map.put(map, key, [value | existing_value])
      existing_value -> Map.put(map, key, [value, existing_value])
    end
  end

  @spec pop_stack(stack()) :: stack() | :error
  defp pop_stack([{nil, _map}]) do
    :error
  end

  defp pop_stack([{key, map}, {upper_key, upper_map} | rest]) do
    [{upper_key, enter_map_value(upper_map, key, map)} | rest]
  end

  @spec split_lines(String.t()) :: [String.t()]
  defp split_lines(str), do: Regex.split(~r/\r\n|\r|\n/, str)

  @spec classified_value(atom | tuple) :: atom
  defp classified_value(val) when is_atom(val), do: val

  defp classified_value(val) when is_tuple(val), do: val |> elem(0)
end
