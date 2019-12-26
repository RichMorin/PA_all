# common.ex

defmodule Common do

  @moduledoc """
  This module defines the external API for the Common component.  Each
  "function" actually delegates to a public function in `common/*.ex`.
  """

  # Define the public interface.

  alias Common.{Maps, Sorting, Strings, Tracing, Zoo}

  ## Maps

  defdelegate get_map_max(inp_map),               to: Maps
  defdelegate keyss(map),                         to: Maps

  ## Sorting

  defdelegate sort_by_elem(tuples, index, mode),  to: Sorting
  defdelegate sort_by_elem(tuples, index),        to: Sorting

  ## Strings

  defdelegate add_s(n, string),                   to: Strings
  defdelegate base_26(n),                         to: Strings
  defdelegate base_26(n, letters),                to: Strings
  defdelegate csv_split(in_str),                  to: Strings
  defdelegate fmt_list(str_list),                 to: Strings
  defdelegate sew(target, test),                  to: Strings
  defdelegate ssw(target, test),                  to: Strings

  ## Tracing

  defdelegate ii(thing, label),                   to: Tracing
  defdelegate lts(label),                         to: Tracing

  ## Zoo

  defdelegate chk_local(conn),                    to: Zoo
  defdelegate get_http_port(),                    to: Zoo
  defdelegate get_rel_path(tree_abs, file_abs),   to: Zoo
  defdelegate get_run_mode(),                     to: Zoo
  defdelegate get_tree_base(),                    to: Zoo
  defdelegate type_of(thing),                     to: Zoo
end