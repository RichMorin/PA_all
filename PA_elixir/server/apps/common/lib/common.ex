# common.ex

defmodule Common do

  @moduledoc """
  This module defines the external API for the Common component.  Each
  "function" actually delegates to a public function in `common/*.ex`.
  """

  # Define the public interface.

  alias Common.{Maps, Sorting, Strings, Tracing, Zoo}

  @doc """
  Naive pluralizer: add an "s" to the end of `string` if `n` is 1.
  ([`Strings`](Common.Strings.html#add_s/2))
  """
  defdelegate add_s(n, string),                   to: Strings

  @doc """
  Generate an alphabetic ID string, using base-26 arithmetic.
  ([`Strings`](Common.Strings.html#base_26/1))
  """
  defdelegate base_26(n),                         to: Strings

  @doc """
  Generate an alphabetic ID string, using base-26 arithmetic.
  ([`Strings`](Common.Strings.html#base_26/2))
  """
  defdelegate base_26(n, letters),                to: Strings

  @doc """
  Determine whether the user is local, based on the IP address.
  ([`Zoo`](Common.Zoo.html#chk_local/1))
  """
  defdelegate chk_local(conn),                    to: Zoo

  @doc """
  Join a list of strings into a comma-delimited string.
  ([`Strings`](Common.Strings.html#fmt_list/1))
  """
  defdelegate fmt_list(str_list),                 to: Strings

  @doc """
  Split a comma-delimited string into a list of trimmed strings.
  ([`Strings`](Common.Strings.html#csv_split/1))
  """
  defdelegate csv_split(in_str),                  to: Strings

  @doc """
  Get a string indicating the current HTTP PORT.
  ([`Zoo`](Common.Zoo.html#get_http_port/0))
  """
  defdelegate get_http_port(),                    to: Zoo

  @doc """
  Get the maximum value of a map.
  ([`Maps`](Common.Maps.html#get_map_max/1))
  """
  defdelegate get_map_max(inp_map),               to: Maps

  @doc """
  Convert an absolute file path into a relative path.
  ([`Zoo`](Common.Zoo.html#get_rel_path/2))
  """
  defdelegate get_rel_path(tree_abs, file_abs),   to: Zoo

  @doc """
  Get an atom indicating the current run mode.
  ([`Zoo`](Common.Zoo.html#get_run_mode/0))
  """
  defdelegate get_run_mode(),                     to: Zoo

  @doc """
  Get the absolute file path for the base directory.
  ([`Zoo`](Common.Zoo.html#get_tree_base/0))
  """
  defdelegate get_tree_base(),                    to: Zoo

  @doc """
  Wrap `IO.inspect/2`, making it less painful to use.
  ([`Tracing`](Common.Tracing.html#ii/2))
  """
  defdelegate ii(thing, label),                   to: Tracing

  @doc """
  Get the keys to a map and return them in sorted order.
  ([`Maps`](Common.Maps.html#keyss/1))
  """
  defdelegate keyss(map),                         to: Maps

  @doc """
  Print a labeled time stamp.
  ([`Tracing`](Common.Tracing.html#lts/1))
  """
  defdelegate lts(label),                         to: Tracing

  @doc """
  Sort a list by an indexed element.
  ([`Sorting`](Common.Sorting.html#sort_by_elem/2))
  """
  defdelegate sort_by_elem(tuples, index, mode),  to: Sorting

  @doc """
  Sort a list by an indexed element, in a specified mode.
  ([`Sorting`](Common.Sorting.html#sort_by_elem/3))
  """
  defdelegate sort_by_elem(tuples, index),        to: Sorting

  @doc """
  Shorthand call for `String.starts_with?/2`.
  ([`Strings`](Common.Strings.html#ssw/2))
  """
  defdelegate ssw(target, test),                  to: Strings

  @doc """
  Get an atom indicating the data type of the argument.
  ([`Zoo`](Common.Zoo.html#type_of/1))
  """
  defdelegate type_of(thing),                     to: Zoo

end