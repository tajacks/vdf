# VDF

## Reading 

Reading and parsing a VDF file utilized the `VDF.Reader` module. Two functions are available,
`parse_string/1` and `parse_enum/1`. `parse_string/1` is to be supplied a String which will be 
split on new lines and parsed. `parse_enum/1` accepts an enumerable and acts identically to `parse_string/1` 
except it assumes that each element in the enumerable is a String and a new line of a VDF file. The useful use 
case here is with `File.stream!` to avoid loading a large VDF file entirely into memory before parsing.

### Result Types

The result of all reading operations is a Map. This map will treat all keys as strings, and all 
values as one of the following possible types:

1. String 
2. Map 
3. List (containing either Strings or Maps)

A value that is a String represents the value in a Key/Value pair. A value as a Map represents 
a nested value that may contain further Strings, Maps, or Lists. A list is used when a single level 
of nesting has a duplicate key. Keys are initially entered as either Maps or Strings depending on 
if the current line is a Key/Value pair, or, the start of a nested continuation. If a duplicate key is 
present when inserting into the map, the value is then converted to a list containing the original value 
as well as the value that was just inserted. This means that if in a single level of nesting there are duplicate 
keys of multiple types, the resulting list may contain both Strings and Maps.


## Installation

This package can be installed by adding `vdf` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:vdf, "~> 0.1.0"}
  ]
end
```

## Copywrite 

The source code of this project is licenced under GPLv3. The `*.txt` files present under 
`test/resources/` are copywrite Valve Corporation.
