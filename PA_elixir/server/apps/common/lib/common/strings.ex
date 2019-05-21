# common/strings.ex

defmodule Common.Strings do
#
# Public functions
#
#   add_s/2
#     Perform naive pluralization: "0 cats", "1 cat", "2 cats", ...
#   base_26/2
#     Generate an alphabetic ID string, using base-26 arithmetic.
#   csv_join/1
#     Join a list of strings into a (mostly) comma-delimited string.
#   csv_split/1
#     Split a comma-delimited string into a list of trimmed strings.
#
# Private functions
#
#   jl/[12]
#     Helper functions for csv_join/1

  @moduledoc """
  This module contains String-handling functions for common use.
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

  @spec add_s(integer, s) :: s when s: String.t

  def add_s(1, string), do: "#{ 1 } #{ string }"
  def add_s(n, string), do: "#{ n } #{ string }s"

  @doc """
  Generate an alphabetic ID string, using base-26 arithmetic.
  (eg, 1 => a, 2 => b, ..., 26 => z, 27 => aa, ...)

    iex> base_26(1)
    "a"

    iex> base_26(26)
    "z"

    iex> base_26(27)
    "aa"
  """

  @spec base_26(integer, s) :: s when s: String.t

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

  @doc """
  Join a list of strings into a (mostly) comma-delimited string.
  Include "and" where appropriate. 
  """

  @spec csv_join( [ s ] ) :: s when s: String.t #W

  def csv_join(str_list), do: jl(str_list)
  #
  # Note: If and when we internationalize the site, we might want
  # to consider using Cldr (https://github.com/kipcole9/cldr) for
  # this sort of thing (specifically, cldr_lists).  Finally, anyone
  # who is interested in this as a programming challenge should visit
  # the Elixir Forum topic Rich started: https://elixirforum.com/t/
  #   formatting-a-list-of-strings-am-i-missing-anything/18593/10
  # Interesting discussion and really great help!

  @spec csv_split(s) :: [ s ] when s: String.t

  @doc """
  Split a comma-delimited string into a list of trimmed strings, discarding any
  empty strings.

      iex> s = " , foo,  , a\\\\, b  , bar,  "
      " , foo,  , a\\\\, b  , bar,  "
      iex> csv_split(s)
      [ "foo", "a, b", "bar" ]
  """

  def csv_split(in_str) do
    map_fn      = fn str -> String.replace(str, "\a", ",") end
    reject_fn   = fn str -> str == "" end

    in_str                            # " , foo,  , a\\, b  , bar,  "
    |> String.replace("\\,", "\a")    # " , foo,  , a\a b  , bar,  "
    |> String.split(",")              # [ " ", " foo", "  ", " a\a b  ", ... ]
    |> Enum.map(&String.trim/1)       # [ "", "foo", "", "a\a b", "bar", "" ]
    |> Enum.map(map_fn)               # [ "", "foo", "", "a, b", "bar", "" ]
    |> Enum.reject(reject_fn)         # [ "foo", "a, b", "bar" ]
  end

  # Private functions

  @spec jl(list) :: String.t #W

  defp jl([]),            do: ""
  defp jl([a]),           do: "#{ a }"
  defp jl([a, b]),        do: "#{ a } and #{ b }"
  defp jl(list),          do: jl(list, [])

  @spec jl(list, [ String.t ] ) :: String.t #W

  defp jl([last], strl),  do: to_string( [ strl, 'and ', "#{ last }" ] )
  defp jl([h | t], strl), do: jl(t, [ strl, "#{ h }", ', '] )

end
