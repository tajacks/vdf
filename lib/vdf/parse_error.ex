defmodule VDF.ParseError do
  defexception message: "parsing error", line_number: nil

  @type t :: %__MODULE__{
          message: String.t(),
          line_number: non_neg_integer() | nil
        }

  @spec unexpected_line(non_neg_integer(), atom()) :: t()
  def unexpected_line(line_number, unexpected_type)
      when is_integer(line_number) and is_atom(unexpected_type) do
    %__MODULE__{
      message: "received unexpected line of type `" <> Atom.to_string(unexpected_type) <> "`",
      line_number: line_number
    }
  end

  @spec unexpected_eof() :: t()
  def unexpected_eof() do
    %__MODULE__{
      message: "unexpectedly reached end of file while within nested block",
      line_number: nil
    }
  end
end
