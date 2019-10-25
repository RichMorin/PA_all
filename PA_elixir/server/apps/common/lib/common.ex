# common.ex

defmodule Common do

  @moduledoc """
  This module defines the external API for the Common component.  Each
  "function" actually delegates to a public function in `common/*.ex`.
  """

  # Define the public interface.

  alias Common.{Maps, Sorting, Strings, Tracing, Zoo}

  ## Maps

  @doc delegate_to: {Maps, :get_map_max, 1}
  defdelegate get_map_max(inp_map),               to: Maps

  @doc delegate_to: {Maps, :keyss, 1}
  defdelegate keyss(map),                         to: Maps

  ## Sorting

  @doc delegate_to: {Strings, :sort_by_elem, 3}
  defdelegate sort_by_elem(tuples, index, mode),  to: Sorting

  @doc delegate_to: {Strings, :sort_by_elem, 2}
  defdelegate sort_by_elem(tuples, index),        to: Sorting

  ## Strings

  @doc delegate_to: {Strings, :add_s, 2}
  defdelegate add_s(n, string), to: Strings

  @doc delegate_to: {Strings, :base_26, 1}
  defdelegate base_26(n), to: Strings

  @doc delegate_to: {Strings, :base_26, 2}
  defdelegate base_26(n, letters), to: Strings

  @doc delegate_to: {Strings, :csv_split, 1}
  defdelegate csv_split(in_str), to: Strings

  @doc delegate_to: {Strings, :fmt_list, 1}
  defdelegate fmt_list(str_list), to: Strings

  @doc delegate_to: {Strings, :sew, 2}
  defdelegate sew(target, test), to: Strings

  @doc delegate_to: {Strings, :ssw, 2}
  defdelegate ssw(target, test), to: Strings

  ## Tracing

  @doc delegate_to: {Tracing, :ii, 2}
  defdelegate ii(thing, label), to: Tracing

  @doc delegate_to: {Tracing, :lts, 2}
  defdelegate lts(label), to: Tracing

  ## Zoo

  @doc delegate_to: {CntCode, :chk_local, 1}
  defdelegate chk_local(conn), to: Zoo

  @doc delegate_to: {Zoo, :get_http_port, 0}
  defdelegate get_http_port(), to: Zoo

  @doc delegate_to: {Zoo, :get_rel_path, 1}
  defdelegate get_rel_path(tree_abs, file_abs), to: Zoo

  @doc delegate_to: {Zoo, :get_run_mode, 0}
  defdelegate get_run_mode(), to: Zoo

  @doc delegate_to: {Zoo, :get_tree_base, 0}
  defdelegate get_tree_base(), to: Zoo

  @doc delegate_to: {Zoo, :type_of, 1}
  defdelegate type_of(thing), to: Zoo

end