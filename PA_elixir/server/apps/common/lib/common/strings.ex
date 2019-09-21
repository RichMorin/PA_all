# common/strings.ex

defmodule Common.Strings do
#
# Public functions
#
#   add_s/2
#     Perform naive pluralization: "0 cats", "1 cat", "2 cats", ...
#   base_26/2
#     Generate an alphabetic ID string, using base-26 arithmetic.
#   csv_split/1
#     Split a comma-delimited string into a list of trimmed strings.
#   fmt_list/1
#     Join a list of strings into a (mostly) comma-delimited string.
#
# Private functions
#
#   jl/[12]
#     Helper functions for fmt_list/1

  @moduledoc """
  This module contains string-handling functions for common use.
  """

  # Public functions

  @doc """
  Perform naive pluralization on a noun, adding "s" if the number is 1.
  
      iex> add_s(0, "cat")
      "0 cats"
      iex> add_s(1, "cat")
      "1 cat"
      iex> add_s(2, "cat")
      "2 cats"
  """

  @spec add_s(integer, st) :: st
    when st: String.t

  def add_s(1, string), do: "#{ 1 } #{ string }"
  def add_s(n, string), do: "#{ n } #{ string }s"

  @doc """
  Generate an alphabetic ID string, using base-26 arithmetic.
  (e.g., `1 => a`, `2 => b`, ..., `26 => z`, `27 => aa`, ...)

      iex> base_26(1)
      "a"
      iex> base_26(26)
      "z"
      iex> base_26(27)
      "aa"
  """

  @spec base_26(non_neg_integer, st) :: st
    when st: String.t

  def base_26(ndx_inp, letters \\ "")
  def base_26(ndx_inp, _letters) when ndx_inp <  0, do: "?"
  def base_26(ndx_inp, _letters) when ndx_inp == 0, do: ""

  def base_26(ndx_inp, letters) do
    a2z_str   = "abcdefghijklmnopqrstuvwxyz"
    ndx_rem   = rem(ndx_inp-1, 26)
    ndx_div   = div(ndx_inp-1, 26)
    letter    = String.at(a2z_str, ndx_rem)
    base_26(ndx_div, letters) <> letter
  end

  @spec csv_split(st) :: [st, ...]
    when st: String.t

  @doc """
  Split a comma-delimited string into a list of trimmed field strings,
  discarding any empty strings.  Honor backslash-based escaping of commas.

      iex> s = " , foo,  , a\\\\, b  , bar,  "
      " , foo,  , a\\\\, b  , bar,  "
      iex> csv_split(s)
      [ "foo", "a, b", "bar" ]
  """

  def csv_split(in_str) do

    comma_fn    = fn str -> String.replace(str, "\a", ",") end
    #
    # Convert BEL characters (escaped commas) to commas.

    empty_fn    = fn str -> str == "" end
    #
    # Discard empty strings.

    in_str                            # " , foo,  , a\\, b  , bar,  "
    |> String.replace("\\,", "\a")    # " , foo,  , a\a b  , bar,  "
    |> String.split(",")              # [ " ", " foo", "  ", " a\a b  ", ... ]
    |> Enum.map(&String.trim/1)       # [ "", "foo", "", "a\a b", "bar", "" ]
    |> Enum.map(comma_fn)             # [ "", "foo", "", "a, b", "bar", "" ]
    |> Enum.reject(empty_fn)          # [ "foo", "a, b", "bar" ]
  end

  @doc """
  Format a list of strings, adding "and" and commas where appropriate.
  Follow English rules (e.g., the Oxford Comma).

      iex> fmt_list( [1] )
      "1"
      iex> fmt_list( [1, 2] )
      "1 and 2"
      iex> fmt_list( [1, 2, 3] )
      "1, 2, and 3"
      iex> fmt_list( [1, 2, 3, 4] )
      "1, 2, 3, and 4"
  """

  @spec fmt_list( [st, ...] ) :: st
    when st: String.t

  def fmt_list(str_list), do: fl(str_list)
  #
  # Note: If and when we internationalize the site, we might want
  # to consider using Cldr (https://github.com/kipcole9/cldr) for
  # this sort of thing (specifically, cldr_lists).
  #
  # Anyone who is interested in this as a programming challenge should
  # visit the Elixir Forum topic Rich started: https://elixirforum.com/t/
  #   formatting-a-list-of-strings-am-i-missing-anything/18593/10
  # Interesting discussion and really great help!

  @spec sew(st, st) :: boolean
    when st: String.t

  @doc """
  Shorthand call for `String.ends_with?/2`.

      iex> sew("beer", "bar")
      false
      iex> sew("rebar", "bar")
      true
  """

  def sew(target, test), do: String.ends_with?(target, test)

  @spec ssw(st, st) :: boolean
    when st: String.t

  @doc """
  Shorthand call for `String.starts_with?/2`.

      iex> ssw("beer", "bar")
      false
      iex> ssw("food", "foo")
      true
  """

  def ssw(target, test), do: String.starts_with?(target, test)

  # Private functions

  @spec fl( [st, ...] ) :: st
    when st: String.t

  # Do the heavy lifting for fmt_list/1.

  defp fl([]),            do: ""
  defp fl([a]),           do: "#{ a }"
  defp fl([a, b]),        do: "#{ a } and #{ b }"
  defp fl(list),          do: fl(list, [])

  @spec fl( [st], [st] ) :: st
    when st: String.t

  defp fl([last], strl),  do: to_string( [ strl, 'and ', "#{ last }" ] )
  defp fl([h | t], strl), do: fl(t, [ strl, "#{ h }", ', '] )

end
