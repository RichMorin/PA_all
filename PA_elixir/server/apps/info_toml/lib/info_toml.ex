# info_toml.ex

defmodule InfoToml do

  @moduledoc """
  This module defines the external API for the InfoToml component.  See
  `info_toml/*.ex` for the implementation code.
  """

  alias InfoToml.{AccessData, AccessKeys, Common, Emitter,
    Reffer, Server, Tagger, Trees}

  # Define the public interface.

  ## AccessData

  defdelegate get_item(item_key),                 to: AccessData
  defdelegate get_item_tuples(key_base),          to: AccessData
  defdelegate get_map(),                          to: AccessData
  defdelegate get_part(key_list),                 to: AccessData
  defdelegate get_toml(item_key),                 to: AccessData
  defdelegate put_item(key, item),                to: AccessData

  ## AccessKeys

  defdelegate get_area_key(item_key),             to: AccessKeys
  defdelegate get_area_names(),                   to: AccessKeys
  defdelegate get_area_names(area),               to: AccessKeys
  defdelegate get_keys(levels),                   to: AccessKeys
  defdelegate keys_by_tag(tag_val),               to: AccessKeys

  ## Common

  defdelegate exp_prefix(inp_str),                to: Common
  defdelegate get_area_name(area_key),            to: Common
  defdelegate get_file_abs(file_rel),             to: Common
  defdelegate get_tree_abs(),                     to: Common

  ## Emitter

  defdelegate emit_toml(base_path, insert, toml_text), to: Emitter
  defdelegate get_item_toml(gi_bases, item_map),  to: Emitter

  ## Reffer

  defdelegate get_ref_info(),                     to: Reffer

  ## Server

  defdelegate reload(),                           to: Server

  ## Tagger

  defdelegate get_tag_info(),                     to: Tagger

  ## Trees

  defdelegate leaf_paths(tree),                   to: Trees
  defdelegate our_tree(map),                      to: Trees
  defdelegate our_tree(map, strict),              to: Trees

end