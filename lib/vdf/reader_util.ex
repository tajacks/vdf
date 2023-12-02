defmodule VDF.ReaderUtil do
  @type classification ::
          :skippable
          | :opening_brace
          | :closing_brace
          | :unknown
          | {:key, String.t()}
          | {:key_value, {String.t(), String.t()}}

  @moduledoc false

  @spec classify(String.t()) :: classification
  def classify(line) when is_bitstring(line) do
    case classify_value(line) do
      nil -> classify_other(line)
      val -> val
    end
  end

  @spec classify_value(String.t()) ::
          nil | {:key_value, {String.t(), String.t()}} | {:key, String.t()}
  defp classify_value(line) do
    case key_value(line) do
      {:ok, kv} ->
        {:key_value, kv}

      nil ->
        case key(line) do
          {:ok, k} -> {:key, k}
          nil -> nil
        end
    end
  end

  @spec classify_other(String.t()) :: :skippable | :opening_brace | :closing_brace | :unknown
  defp classify_other(line) do
    cond do
      is_comment?(line) or is_empty?(line) -> :skippable
      is_opening_brace?(line) -> :opening_brace
      is_closing_brace?(line) -> :closing_brace
      true -> :unknown
    end
  end

  @spec is_skippable?(String.t()) :: boolean
  def is_skippable?(line) when is_bitstring(line) do
    is_comment?(line) || is_empty?(line)
  end

  @spec is_comment?(String.t()) :: boolean
  def is_comment?(line) when is_bitstring(line) do
    String.match?(line, ~r/^\s*\/\/.*$/)
  end

  @spec is_empty?(String.t()) :: boolean
  def is_empty?(line) when is_bitstring(line) do
    String.match?(line, ~r/^\s*$/)
  end

  @spec is_opening_brace?(String.t()) :: boolean
  def is_opening_brace?(line) when is_bitstring(line) do
    String.match?(line, ~r/^\s*{\s*(\/\/.*)?$/)
  end

  @spec is_closing_brace?(String.t()) :: boolean
  def is_closing_brace?(line) when is_bitstring(line) do
    String.match?(line, ~r/^\s*}\s*(\/\/.*)?$/)
  end

  @spec key(String.t()) :: {:ok, String.t()} | nil
  def key(line) when is_bitstring(line) do
    case Regex.run(~r/^\s*"(?<k>(?:\\"|[^"])*)"\s*(\/\/.*)?$/, line, capture: ["k"]) do
      [key] -> {:ok, key}
      _ -> nil
    end
  end

  @spec key_value(String.t()) :: {:ok, {String.t(), String.t()}} | nil
  def key_value(line) do
    case Regex.run(~r/^\s*"(?<k>(?:\\"|[^"])*)"\s+"(?<v>(?:\\"|[^"])*)"\s*(\/\/.*)?$/, line,
           capture: ["k", "v"]
         ) do
      [key, value] -> {:ok, {key, value}}
      _ -> nil
    end
  end
end
