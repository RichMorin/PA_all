defmodule InfoToml.Parser do
#
# Public functions
#
#   parse/2
#     Read and parse (aka decode) a TOML file.
#
# Private functions
#
#   parse_h1/2
#     Read the file, check for valid Unicode, and (maybe) parse it.
#   parse_h2/2
#     Check for annoying codepoints and (maybe) parse it.

  @moduledoc """
  This module handles reading and parsing of data from a TOML file.
  """

  use Common,   :common
  use InfoToml, :common
  use InfoToml.Types

  @doc """
  Read and parse (aka decode) a TOML file, given an absolute path.
  The real work is done by `Toml.decode/2`, including the conversion
  of string-encoded keys into atoms, as directed by `atom_key`.

  Returns an empty Map if the file is missing or unparseable.
  """

  @spec parse(String.t, atom) :: map

  def parse(file_abs, atom_key) do
    trim_path   = Regex.replace(~r{ ^ .* / PA_toml / }x, file_abs, ".../")

    read_fn     = fn file_abs ->
      if File.exists?(file_abs) do
        parse_h1(file_abs, atom_key)
      else
        ii(file_abs, "file_abs") #T
        trace = Process.info(self(), :current_stacktrace)
        ii(trace, "trace") #T
        { :error, "File not found." }
      end
    end

    file_abs                            # "/.../.../*.toml"
    |> read_fn.()                       # { <status>, <results> }
    |> filter(trim_path)                # nil || <results>
  end

  # Private functions

  @spec filter( {atom, any}, String.t) :: map

  defp filter( {status, payload}, trim_path) do
  #
  # Filter the parsing results, reporting and removing cruft.
  # If a problem is detected, report it and return an empty Map.
  # Otherwise, return the parsed data.

    cond do
      status == :error ->
        IO.puts "\nIgnored: " <> trim_path
        IO.puts "Because: " <> inspect(payload)
        %{}

      !is_map(payload)  ->
        IO.puts "\nIgnored: " <> trim_path
        IO.puts "Because: Payload is not a Map."
        %{}
      
      Enum.empty?(payload) ->
        IO.puts "\nIgnored: " <> trim_path
        IO.puts "Because: Payload is empty."
        %{}

      true -> payload
    end
  end

  @spec parse_h1(s, atom) :: item_map | {atom, s} when s: String.t

  defp parse_h1(file_abs, atom_key) do
  #
  # Read the file, check for valid Unicode, and (maybe) parse it.

    file_text   = file_abs |> File.read!()      # "<TOML file text>"

    if String.valid?(file_text) do
      parse_h2(file_text, atom_key)
    else
      { :error, "File string is not valid Unicode." }
    end
  end

  @spec parse_h2(String.t, atom) :: {atom, s} when s: String.t

  defp parse_h2(file_text, atom_key) do
  #
  # Check for annoying codepoints and (maybe) parse it.

    bogons    = [   # List of bogus (ie, annoying) codepoints
      "\u200b",     # ZERO WIDTH SPACE
    ]

    filter_fn = fn cp -> Enum.member?(bogons, cp) end

    bogus_cps = file_text
    |> String.codepoints()
    |> Enum.uniq()
    |> Enum.filter(filter_fn)

    if Enum.empty?(bogus_cps) do
      file_text
      |> String.replace(~r{ +$}m, "")     # Remove trailing spaces.
      |> Toml.decode(keys: atom_key)      # { <status>, <results> }
    else
      { :error, "File string contains annoying codepoints." }
    end
  end

end
