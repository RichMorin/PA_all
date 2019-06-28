# info_toml.ex

defmodule InfoToml do

  @moduledoc """
  This module defines the external API for the InfoToml component.  See
  `info_toml/*.ex` for the implementation code.
  """

  alias InfoToml.{AccessData, AccessKeys, Common, Emitter,
    Reffer, Server, Tagger}

  # Define the public interface.

  @doc """
  Emit a TOML file.  Return path to the file.
  ([`...Emitter.emit_toml/2`](InfoToml.Emitter.html#emit_toml/2))
  """
  defdelegate emit_toml(base_path, insert, toml_text),  to: Emitter

  @doc """
  Expand prefixes (e.g., `cat_har|`, `ext_wp|`).
  ([`...Common.exp_prefix/0`](InfoToml.Common.html#exp_prefix/0))
  """
  defdelegate exp_prefix(inp_str),                      to: Common

  @doc """
  Return the most relevant area key, given a bogus item key.
  ([`...AccessKeys.get_area_key/1`](InfoToml.AccessKeys.html#get_area_key/1))
  """
  defdelegate get_area_key(item_key),                   to: AccessKeys

  @doc """
  Get the name of an Area, given a key in it.
  ([`...Common.get_area_name/1`](InfoToml.Common.html#get_area_name/1))
  """
  defdelegate get_area_name(area_key),                  to: Common

  @doc """
  Returns a list of Area names: [ "Catalog", ... ]
  ([`...AccessKeys.get_area_names/0`](InfoToml.AccessKeys.html#get_area_names/0))
  """
  defdelegate get_area_names(),                         to: AccessKeys

  @doc """
  Returns a list of Area (really, Section) names.
  ([`...AccessKeys.get_area_names/1`](InfoToml.AccessKeys.html#get_area_names/1))
  """
  defdelegate get_area_names(area),                     to: AccessKeys

  @doc """
  Return the data structure for an item, given its key.
  ([`...AccessData.get_item/1`](InfoToml.AccessData.html#get_item/1))
  """
  defdelegate get_item(item_key),                       to: AccessData

  @doc """
  Generate an IO list containing TOML for `item_map`.
  ([`...Emitter.get_item_toml/2`](InfoToml.Emitter.html#get_item_toml/2))
  """
  defdelegate get_item_toml(gi_bases, item_map),        to: Emitter

  @doc """
  Return a list of item tuples, given a base string for the key.
  ([`...AccessData.get_item_tuples/1`](InfoToml.AccessData.html#get_item_tuples/1))
  """
  defdelegate get_item_tuples(key_base),                to: AccessData

  @doc """
  Return a sorted and trimmed list of item keys.
  ([`...AccessKeys.get_keys/1`](InfoToml.AccessKeys.html#get_keys/1))
  """
  defdelegate get_keys(levels),                         to: AccessKeys

  @doc """
  Return the entire `toml_map` data structure.
  ([`...AccessData.get_map/0`](InfoToml.AccessData.html#get_map/0))
  """
  defdelegate get_map(),                                to: AccessData

  @doc """
  Return a specified portion of `toml_map`.
  ([`...AccessData.get_part/1`](InfoToml.AccessData.html#get_part/1))
  """
  defdelegate get_part(key_list),                       to: AccessData

  @doc """
  Return a map describing ref usage in the TOML files.
  ([`...Tagger.get_ref_info/0`](InfoToml.Reffer.html#get_ref_info/0))
  """
  defdelegate get_ref_info(),                           to: Reffer

  @doc """
  Return a map describing tag usage in the TOML files.
  ([`...Tagger.get_tag_info/0`](InfoToml.Tagger.html#get_tag_info/0))
  """
  defdelegate get_tag_info(),                           to: Tagger

  @doc """
  Return the TOML source code, given its key.
  ([`...AccessData.get_toml/1`](InfoToml.AccessData.html#get_toml/1))
  """
  defdelegate get_toml(item_key),                       to: AccessData

  @doc """
  Return a list of item keys, given a tag value.
  ([`...AccessKeys.keys_by_tag/1`](InfoToml.AccessKeys.html#keys_by_tag/1))
  """
  defdelegate keys_by_tag(tag_val),                     to: AccessKeys

  @doc """
  Update an item in toml_map, given its key and value.
  ([`...AccessData.put_item/2`](InfoToml.AccessData.html#put_item/2))
  """
  defdelegate put_item(key, item),                      to: AccessData

  @doc """
  Reload and re-index the TOML file tree.
  ([`...Server.reload/0`](InfoToml.Server.html#reload/0))
  """
  defdelegate reload(),                                 to: Server

end