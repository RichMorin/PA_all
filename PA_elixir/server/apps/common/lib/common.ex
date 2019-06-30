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
  ([`...Strings.add_s/2`](Common.Strings.html#add_s/2))
  """
  defdelegate add_s(n, string),                   to: Strings

  @doc """
  Generate an alphabetic ID string, using base-26 arithmetic.
  ([`...Strings.base_26/1`](Common.Strings.html#base_26/1))
  """
  defdelegate base_26(n),                         to: Strings

  @doc """
  Generate an alphabetic ID string, using base-26 arithmetic.
  ([`...Strings.base_26/2`](Common.Strings.html#base_26/2))
  """
  defdelegate base_26(n, letters),                to: Strings

  @doc """
  Join a list of strings into a comma-delimited string.
  ([`...Strings.fmt_list/1`](Common.Strings.html#fmt_list/1))
  """
  defdelegate fmt_list(str_list),                 to: Strings

  @doc """
  Split a comma-delimited string into a list of trimmed strings.
  ([`...Strings.csv_split/1`](Common.Strings.html#csv_split/1))
  """
  defdelegate csv_split(in_str),                  to: Strings

  @doc """
  Get a string indicating the current HTTP PORT.
  ([`...Zoo.get_http_port/0`](Common.Zoo.html#get_http_port/0))
  """
  defdelegate get_http_port(),                    to: Zoo

  @doc """
  Get the maximum value of a map.
  ([`...Maps.get_map_max/1`](Common.Maps.html#get_map_max/1))
  """
  defdelegate get_map_max(inp_map),               to: Maps

  @doc """
  Convert an absolute file path into a relative path.
  ([`...Zoo.get_rel_path/2`](Common.Zoo.html#get_rel_path/2))
  """
  defdelegate get_rel_path(tree_abs, file_abs),   to: Zoo

  @doc """
  Get an atom indicating the current run mode.
  ([`...Zoo.get_run_mode/0`](Common.Zoo.html#get_run_mode/0))
  """
  defdelegate get_run_mode(),                     to: Zoo

  @doc """
  Get the absolute file path for the base directory.
  ([`...Zoo.get_tree_base/0`](Common.Zoo.html#get_tree_base/0))
  """
  defdelegate get_tree_base(),                    to: Zoo

  @doc """
  Wrap `IO.inspect/2`, making it less painful to use.
  ([`...Tracing.ii/2`](Common.Tracing.html#ii/2))
  """
  defdelegate ii(thing, label),                   to: Tracing

  @doc """
  Get the keys to a map and return them in sorted order.
  ([`...Maps.keyss/1`](Common.Maps.html#keyss/1))
  """
  defdelegate keyss(map),                         to: Maps

  @doc """
  Get a list of paths for the leaf nodes of a tree of maps.
  ([`...Maps.leaf_paths/1`](Common.Maps.html#leaf_paths/1))
  """
  defdelegate leaf_paths(tree),                   to: Maps

  @doc """
  Print a labeled time stamp.
  ([`...Tracing.lts/1`](Common.Tracing.html#lts/1))
  """
  defdelegate lts(label),                         to: Tracing

  @doc """
  Is this our sort of Map tree?
  ([`...Maps.our_tree/1`](Common.Maps.html#our_tree/1))
  """
  defdelegate our_tree(map),                      to: Maps

  @doc """
  Is this our sort of map tree?
  ([`...Maps.our_tree/2`](Common.Maps.html#our_tree/2))
  """
  defdelegate our_tree(map, strict),              to: Maps

  @doc """
  Sort a list by an indexed element.
  ([`...Sorting.sort_by_elem/2`](Common.Sorting.html#sort_by_elem/2))
  """
  defdelegate sort_by_elem(tuples, index, mode),  to: Sorting

  @doc """
  Sort a list by an indexed element, in a specified mode.
  ([`...Sorting.sort_by_elem/3`](Common.Sorting.html#sort_by_elem/3))
  """
  defdelegate sort_by_elem(tuples, index),        to: Sorting

  @doc """
  Shorthand call for `String.starts_with?/2`.
  ([`...Strings.ssw/2`](Common.Strings.html#ssw/2))
  """
  defdelegate ssw(target, test),                  to: Strings

  @doc """
  Get an atom indicating the data type of the argument.
  ([`...Zoo.type_of/1`](Common.Zoo.html#type_of/1))
  """
  defdelegate type_of(thing),                     to: Zoo

end