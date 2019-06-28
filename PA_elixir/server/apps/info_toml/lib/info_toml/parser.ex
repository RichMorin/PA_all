# info_toml/parser.ex

defmodule InfoToml.Parser do
#
# Public functions
#
#   parse/2
#     Read and parse (aka decode) a TOML file.
#
# Private functions
#
#   add_offsets/2
#     Add line number offsets for `access` and `verbose` data.
#   decode/2
#     Wrapper for Toml.decode/1; allows :string as `atom_key`.
#   filter/2
#     Filter the parsing results, reporting and removing cruft.
#   parse_h1/2
#     Read the file, check for valid Unicode, and (maybe) parse it.
#   parse_h2/2
#     Check for annoying codepoints and (maybe) parse it.

  @moduledoc """
  This module handles reading and parsing of data from a TOML file.
  """

  use Common.Types

  import Common, warn: false, only: [ii: 2]

  # Public functions

  @doc """
  Read and parse (aka decode) a TOML file, given an absolute path.
  The real work is done by `Toml.decode/2`, including the conversion
  of string-encoded keys into atoms, as directed by `atom_key`.

  Returns an empty map if the file is missing or unparseable.
  """

  @spec parse(String.t, atom) :: map

  def parse(file_abs, atom_key) do
    trim_patt   = ~r{ ^ .* / PA_toml / }x
    trim_path   = Regex.replace(trim_patt, file_abs, ".../")

    parse_fn     = fn file_abs ->
    #
    # Read and parse the specified file, with a bit of error checking.

      if File.exists?(file_abs) do
        parse_h1(file_abs, atom_key)
      else
#       ii(file_abs, "file_abs") #T
#       trace = Process.info(self(), :current_stacktrace)
#       ii(trace, "trace") #T
        { :error, "File not found." }
      end
    end

    file_abs                            # "/.../.../*.toml"
    |> parse_fn.()                      # { <status>, <results> }
    |> filter(trim_path)                # nil || <results>
  end

  # Private functions

  @spec add_offsets(String.t, map) :: map

  defp add_offsets(file_text, payload) do
  #
  # Add line number offsets for `access` and `verbose` data.

    reduce_fn = fn {line, ndx}, acc ->
    #
    # Put the stringified version of the line number offset into the map.

      case line do
        ~r{ ^ \s+ access  \s+ = \s+ }x ->
          gi_list   = [ :meta, :o_access ]
          put_in(acc, gi_list, "#{ ndx }")

        ~r{ ^ \s+ verbose \s+ = \s+ }x ->
          gi_list   = [ :meta, :o_verbose ]
          put_in(acc, gi_list, "#{ ndx }")

        _ -> acc
      end
    end

    file_text
    |> String.split("\n")
    |> Enum.with_index()
    |> Enum.reduce(payload, reduce_fn)
  end

  @spec decode(String.t, atom) :: tuple

  defp decode(inp_str, atom_key) do
  #
  # Wrapper for Toml.decode/1; allows :string as `atom_key`.

    if atom_key == :string do
      Toml.decode(inp_str)                    # { <status>, <results> }
    else
      Toml.decode(inp_str, keys: atom_key)    # { <status>, <results> }
    end
  end

  @spec filter({atom, any}, String.t) :: map #W

  defp filter({status, payload}, trim_path) do
  #
  # Filter the parsing results, reporting and removing cruft.
  # If a problem is detected, report it and return an empty map.
  # Otherwise, return the parsed data.

    bogon_fn  = fn reason ->
    #
    # Print a nastygram and return an empty map.

      IO.puts "\nIgnored: Because (#{ status }): #{ trim_path }"
      IO.puts reason
      %{}
    end

    cond do
      status != :ok        -> bogon_fn.("#{ inspect(payload) }")
      Enum.empty?(payload) -> bogon_fn.("Payload is empty.")
      true -> payload
    end
  end

  @spec parse_h1(s, atom) :: {atom, item_map|s} when s: String.t

  defp parse_h1(file_abs, atom_key) do
  #
  # Read the file, check for valid Unicode, and (maybe) parse it.

    file_text   = file_abs |> File.read!()      # "<TOML file text>"

    if String.valid?(file_text) do
      {status, payload} = tuple = parse_h2(file_text, atom_key)

      if status == :ok do
        { status, add_offsets(file_text, payload) }
      else
        tuple
      end

    else
      { :error, "File string is not valid Unicode." }
    end
  end

  @spec parse_h2(s, atom) :: {atom, item_map|s} when s: String.t

  defp parse_h2(file_text, atom_key) do
  #
  # Check for annoying codepoints and (maybe) parse it.

    bogons    = [   # List of bogus (ie, annoying) codepoints
      "\u200b",     # ZERO WIDTH SPACE
    ]

    filter_fn = fn codepoint ->
    #
    # Return true if the codepoint is contained in the bogons list.

      Enum.member?(bogons, codepoint)
    end

    bogus_cps = file_text
    |> String.codepoints()
    |> Enum.uniq()
    |> Enum.filter(filter_fn)

    if Enum.empty?(bogus_cps) do
      file_text
      |> String.replace(~r{ +$}m, "")     # Remove trailing spaces.
      |> decode(atom_key)                 # { <status>, <results> }
    else
      { :error, "File string contains annoying codepoints." }
    end
  end

end
