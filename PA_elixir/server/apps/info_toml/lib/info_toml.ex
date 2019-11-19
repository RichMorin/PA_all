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

  @doc delegate_to: {AccessData, :get_item, 1}
  defdelegate get_item(item_key), to: AccessData

  @doc delegate_to: {AccessData, :get_item_tuples, 1}
  defdelegate get_item_tuples(key_base), to: AccessData

  @doc delegate_to: {AccessData, :get_map, 0}
  defdelegate get_map(), to: AccessData

  @doc delegate_to: {AccessData, :get_part, 1}
  defdelegate get_part(key_list), to: AccessData

  @doc delegate_to: {AccessData, :get_toml, 1}
  defdelegate get_toml(item_key), to: AccessData

  @doc delegate_to: {AccessData, :put_item, 2}
  defdelegate put_item(key, item), to: AccessData

  ## AccessKeys

  @doc delegate_to: {AccessKeys, :get_area_key, 1}
  defdelegate get_area_key(item_key), to: AccessKeys

  @doc delegate_to: {AccessKeys, :get_area_names, 0}
  defdelegate get_area_names(), to: AccessKeys

  @doc delegate_to: {AccessKeys, :get_area_names, 1}
  defdelegate get_area_names(area), to: AccessKeys

  @doc delegate_to: {AccessKeys, :get_keys, 1}
  defdelegate get_keys(levels), to: AccessKeys

  @doc delegate_to: {AccessKeys, :keys_by_tag, 1}
  defdelegate keys_by_tag(tag_val), to: AccessKeys

  ## Common

  @doc delegate_to: {Common, :exp_prefix, 1}
  defdelegate exp_prefix(inp_str),  to: Common

  @doc delegate_to: {Common, :get_area_name, 1}
  defdelegate get_area_name(area_key), to: Common

  @doc delegate_to: {Common, :get_file_abs, 1}
  defdelegate get_file_abs(file_rel), to: Common

  @doc delegate_to: {Common, :get_tree_abs, 1}
  defdelegate get_tree_abs(), to: Common

  ## Emitter

  @doc delegate_to: {Emitter, :emit_toml, 3}
  defdelegate emit_toml(base_path, insert, toml_text), to: Emitter

  @doc delegate_to: {Emitter, :get_item_toml, 2}
  defdelegate get_item_toml(gi_bases, item_map), to: Emitter

  ## Reffer

  @doc delegate_to: {Reffer, :get_ref_info, 0}
  defdelegate get_ref_info(), to: Reffer

  ## Server

  @doc delegate_to: {Server, :reload, 0}
  defdelegate reload(), to: Server

  ## Tagger

  @doc delegate_to: {Tagger, :get_tag_info, 0}
  defdelegate get_tag_info(), to: Tagger

  ## Trees

  @doc delegate_to: {Trees, :leaf_paths, 1}
  defdelegate leaf_paths(tree), to: Trees

  @doc delegate_to: {Trees, :our_tree, 1}
  defdelegate our_tree(map), to: Trees

  @doc delegate_to: {Trees, :our_tree, 2}
  defdelegate our_tree(map, strict), to: Trees

end