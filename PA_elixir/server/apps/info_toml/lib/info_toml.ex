defmodule InfoToml do

  @moduledoc """
  This module defines the external API for the InfoToml component.  See
  `info_toml/*.ex` for the implementation code.
  
  Note: It also sets up some infrastructure for code sharing.
  """

  alias InfoToml.{Emitter,Reffer,Server,Tagger}

  # Define the public interface.

  @doc """
  Emit a TOML file.  Return path to the file.
  ([`...Emitter.emit_toml/2`](InfoToml.Emitter.html#emit_toml/2))
  """
  defdelegate emit_toml(base_path, toml_text),      to: Emitter

  @doc """
  Return the data structure for an item, given its key.
  ([`...Server.get_item/1`](InfoToml.Server.html#get_item/1))
  """
  defdelegate get_item(item_key),                   to: Server

  @doc """
  Generate an IO list containing TOML for `item_map`.
  ([`...Emitter.get_item_toml/2`](InfoToml.Emitter.html#get_item_toml/2))
  """
  defdelegate get_item_toml(gi_bases, item_map),    to: Emitter

  @doc """
  Return a list of items, given a base string for the key.
  ([`...Server.get_items/1`](InfoToml.Server.html#get_items/1))
  """
  defdelegate get_items(key_base),                  to: Server

  @doc """
  Return a sorted and trimmed list of item keys.
  ([`...Server.get_keys/1`](InfoToml.Server.html#get_keys/1))
  """
  defdelegate get_keys(levels),                     to: Server

  @doc """
  Return the entire `toml_map` data structure.
  ([`...Server.get_map/0`](InfoToml.Server.html#get_map/0))
  """
  defdelegate get_map(),                            to: Server

  @doc """
  Return a specified portion of `toml_map`.
  ([`...Server.get_part/1`](InfoToml.Server.html#get_part/1))
  """
  defdelegate get_part(key_list),                   to: Server

  @doc """
  Return a Map describing ref usage in the TOML files.
  ([`...Tagger.get_ref_info/0`](InfoToml.Reffer.html#get_ref_info/0))
  """
  defdelegate get_ref_info(),                       to: Reffer

  @doc """
  Return a Map describing tag usage in the TOML files.
  ([`...Tagger.get_tag_info/0`](InfoToml.Tagger.html#get_tag_info/0))
  """
  defdelegate get_tag_info(),                       to: Tagger

  @doc """
  Return the TOML source code, given its key.
  ([`...Server.get_toml/1`](InfoToml.Server.html#get_toml/1))
  """
  defdelegate get_toml(item_key),                   to: Server

  @doc """
  Return a list of item keys, given a tag value.
  ([`...Server.keys_by_tag/1`](InfoToml.Server.html#keys_by_tag/1))
  """
  defdelegate keys_by_tag(tag_val),                 to: Server

  @doc """
  Update an item in toml_map, given its key and value.
  ([`...Server.put_item/2`](InfoToml.Server.html#put_item/2))
  """
  defdelegate put_item(key, item),                  to: Server

  @doc """
  Reload and re-index the TOML file tree.
  ([`...Server.reload/0`](InfoToml.Server.html#reload/0))
  """
  defdelegate reload(),                             to: Server


  @doc "Set up infrastructure for code sharing."
  def common do
    quote do
      import InfoToml.Common
    end
  end

  @doc """
  Dispatch to the appropriate module (e.g., `use InfoToml, :common`).
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

end